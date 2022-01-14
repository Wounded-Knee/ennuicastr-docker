#!/bin/bash
PWD=$(pwd)
if [ ! -e ${PWD}/.env ]; then
	cp .env.template .env
	echo "PLEASE SET UP THE ENVIRONMENT VARIABLES IN ENV TO PROCEED!!" >&2
	exit
fi
sed -r 's+(^[~=])*=[ \t]*([^"].*)+\1="\2"+;/^#/d;/^$/d' .env >.bashenv;source .bashenv;rm .bashenv
if [ -z "$JVB_AUTH_PASSWORD" ]; then
	curl https://raw.githubusercontent.com/jitsi/docker-jitsi-meet/master/gen-passwords.sh -o ${PWD}/gen-passwords.sh
	chmod +x ${PWD}/gen-passwords.sh
	${PWD}/gen-passwords.sh
	rm ${PWD}/gen-passwords.sh
fi
if [ ! -e ${PWD}/run/ennuicastr/config.json.example ]; then
	mkdir -p ${PWD}/run/ennuicastr
	chown www-data.www-data -R ${PWD}/run/ennuicastr/
	curl https://raw.githubusercontent.com/ennuicastr/ennuicastr-server/master/config.json.example -o ${PWD}/run/ennuicastr/config.json.example
fi

sed -r \
"s+https://ennuicastr.com+https://${PUBLIC_SITE}+g;
 s+r.ennuicastr.com+${PUBLIC_SITE}/rec+g;
 s+l.ennuicastr.com+${PUBLIC_SITE}/rec/lobby+g;
 s+ez.ennuicastr.com+${PUBLIC_SITE}/ennuizel+g;
 s+~/cert+/external/cert+g;
 s+~/ennuicastr-server/(db|rec|sound)+/external/\1+g; 
 s+~/ennuicastr+/ennuicastr+g; 
 s+/tmp/ennuicastr-server.sock+/external/ennuicastr-server.sock+g; 
 /google/ {n;s+\"\"+\"${GOOGLE_CLIENT_ID}\"+g;n;s+\"\"+\"${GOOGLE_CLIENT_SECRET}\"+g;}; 
 /paypal/ {n;s+api.paypal+api.sandbox.paypal+;n;s+\"\"+\"${PAYPAL_CLIENT_ID}\"+;n;s+\"\"+\"${PAYPAL_CLIENT_SECRET}\"+;n;s+: \".*\"+: ${PAYPAL_SUBSCRIPTION}+;}; 
" \
${PWD}/run/ennuicastr/config.json.example > ${PWD}/run/ennuicastr/config.json

sed -r "s+\\$\\{PUBLIC_SITE\\}+${PUBLIC_SITE}+g;" ${PWD}/nginx/internal-jitsi.conf > ${PWD}/run/web/nginx/site-confs/jitsi.conf

#docker-compose down
docker-compose pull
docker-compose build
docker-compose up --no-start

sed -r "s+\\$\\{PUBLIC_SITE\\}+${PUBLIC_SITE}+g;" ${PWD}/nginx/internal-jitsi.conf > ${PWD}/run/web/nginx/site-confs/jitsi.conf

# set up hosts for nginx
rm ${PWD}/run/web/logs/*
sed -r \
"s+ennuicastr.com+${PUBLIC_SITE}+g;
 s+r.ennuicastr.com+${PUBLIC_SITE}/rec+g;
 s+l.ennuicastr.com+${PUBLIC_SITE}/rec/lobby+g;
 s+ez.ennuicastr.com+${PUBLIC_SITE}/ennuizel+g;
" \
${PWD}/nginx/nginx.conf.template > ${PWD}/nginx/nginx.conf

#for jibri recording -- not needed
#if [ -z $(grep 'snd-aloop' /etc/modules) ]; then
#    apt -y install linux-image-extra-virtual
#    # configure 5 capture/playback interfaces
#    echo "options snd-aloop enable=1,1,1,1,1 index=0,1,2,3,4" > /etc/modprobe.d/alsa-loopback.conf
#    # setup autoload the module
#    echo "snd-aloop" >> /etc/modules
#    modprobe snd-aloop
#fi

#for local jitsi recording -- not needed
#if [ -z "$(grep 'config.localRecording' ${PWD}/run/web/config.js)" ]; then
#    echo -e "config.localRecording = {enabled: true, format: 'flac' };\n\
#config.toolbarButtons.splice(4,0,'localrecording');" >> ${PWD}/run/web/config.js
#fi

docker stop ennuicastr_web_1
docker start ennuicastr_web_1

#initialize DB
if [ ! -e ${PWD}/run/ennuicastr/db ]; then
  docker exec -ti ennuicastr_web_1 sh -c ' \
    mkdir -p /external/db; \
    cd /external/db; \
    sqlite3 ennuicastr.db < /ennuicastr-server/db/ennuicastr.schema;\
    sqlite3 log.db < /ennuicastr-server/db/log.schema;\
    chown www-data.www-data *.db
  '
  mkdir -p ${PWD}/run/ennuicastr/rec
  mkdir -p ${PWD}/run/ennuicastr/sounds
  chown www-data.www-data -R  ${PWD}/run/ennuicastr
fi
## COPY CERTIFICATES
if [ ! -e ${PWD}/run/ennuicastr/cert ]; then
  mkdir -p ${PWD}/run/ennuicastr/cert
  cp /etc/letsencrypt/live/${PUBLIC_SITE}/fullchain.pem ${PWD}/run/ennuicastr/cert
  cp /etc/letsencrypt/live/${PUBLIC_SITE}/privkey.pem ${PWD}/run/ennuicastr/cert
  chown www-data.www-data -R  ${PWD}/run/ennuicastr
fi
if [ ! -e ${PWD}/run/prosody/config/certs/jitsi.${PUBLIC_SITE}.key ]; then
  cp /etc/letsencrypt/live/jitsi.${PUBLIC_SITE}/cert.pem ${PWD}/run/prosody/config/certs/jitsi.${PUBLIC_SITE}.crt
  cp /etc/letsencrypt/live/jitsi.${PUBLIC_SITE}/privkey.pem ${PWD}/run/prosody/config/certs/jitsi.${PUBLIC_SITE}.key
  sed -i "s+https://meet.jitsi+https://jitsi.${PUBLIC_SITE}+g;s+/certs/meet.jitsi+/certs/jitsi.${PUBLIC_SITE}+g" ${PWD}/run/prosody/config/conf.d/jitsi-meet.cfg.lua
  chown www-data.www-data -R  ${PWD}/run/prosody
fi

docker exec -ti ennuicastr_web_1 sh -c " 
    sed -ri  's+server_name.*$+server_name ${PUBLIC_SITE}\;+g' /defaults/meet.conf; 
# TODO -- generate and install paypal subscriptions
#    cd /ennuicastr-server/subscription;
#    if [ ! -e /external/subscriptions.json ]; then 
#      node create.js >> /external/subscriptions.json.new;
#      echo -n '\"subscription\": \"'>/external/subscriptions.json && \
#      cat /external/subscriptions.json.new >> /external/subscriptions.json && \
#      echo '\"' >>/external/subscriptions.json; 
#    fi
"

docker-compose up -d
docker system prune -af

service nginx reload
