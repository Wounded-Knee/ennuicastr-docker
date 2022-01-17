FROM jitsi/web:latest
WORKDIR .
EXPOSE 80 443 15000-15050
RUN apt -q update && apt -qy upgrade && apt -q clean
RUN apt -q update && apt -qy install curl ffmpeg flac vorbis-tools opus-tools sqlite3 git && apt -q clean
RUN \
 apt -y install make g++ npm && \
 git clone https://github.com/ennuicastr/ennuicastr-server.git && \
 cd ennuicastr-server && \
 sed -i 's+https://github.com/mapbox/node-sqlite3/tarball/master+^4.1.1+g' package.json && \
 sed -i '/tryPort =/ {s+36678+15000+;s+16384+50+;}' server/ennuicastr.ts &&\
 make && \
 apt -y remove --purge make g++ && \
 apt -y autoremove --purge && \
 apt clean && \
 ln -s /external/config.json /ennuicastr-server/config.json && \
 chown www-data.www-data -R /ennuicastr-server
RUN \
 apt -y install  make g++ && \
 git clone https://github.com/ennuicastr/ennuicastr.git && \
 cd ennuicastr && \
 sed -r 's/libavVersion = ".*";/libavVersion = "3.6.4.4.1"/g' src/avloader.ts -i && \
 sed -r 's/libavVersion = ".*";/libavVersion = "3.6.4.4.1"/g' awp/ennuicastr-worker.ts -i && \
 make && \
 apt -y remove --purge make g++ && \
 apt -y autoremove --purge && \
 apt clean && \
 chown www-data.www-data -R /ennuicastr
RUN \
 apt -y install make g++ cmake pkgconf unzip meson emscripten fftw3-dev lv2-dev && \
 emconfigure; \
 cd /ennuicastr &&\
 git clone https://github.com/ennuizel/ennuizel.git &&\
 cd ennuizel && \
 sed -i "s+2.5.4.4-fat+3.6.4.4.1-fat+g" src/main.ts && \
 make && \
# git clone https://github.com/ennuizel/ennuizel-noise-repellent-plugin.git &&\
# cd ennuizel-noise-repellent-plugin &&\
# cp ../../noise-repellent/noise-repellent-m.* . && make && cd .. &&\
 git clone https://github.com/ennuizel/ennuizel-better-normalization-plugin &&\
 cd ennuizel-better-normalization-plugin && make && cd .. &&\
 git clone https://github.com/Yahweasel/ennuizel-ennuicastr-plugin.git &&\
 cd ennuizel-ennuicastr-plugin && make && cd .. &&\
 rm -rf /ennuicastr/noise-repellent/noise-repellent.js &&\
 cd /ennuicastr/noise-repellent && \
 git clone https://github.com/Yahweasel/noise-repellent.js.git && \
 cd /ennuicastr/noise-repellent/noise-repellent.js && \
 meson build && \
 make && \
# make && \
 cp noise-repellent-m.js noise-repellent-m.asm.js noise-repellent-m.wasm.js noise-repellent-m.wasm.wasm .. &&\
 cd .. && rm -rf /ennuicastr/noise-repellent/noise-repellent.js &&\
 cd /ennuicastr/libav && \
 wget https://github.com/Yahweasel/libav.js/releases/download/v3.6.4.4.1/libav.js-3.6.4.4.1.zip && \
 unzip libav.js-3.6.4.4.1.zip && cd libav.js-3.6.4.4.1 &&\
 cp libav-3.6.4.4.1-fat.* /ennuicastr/ennuizel/libav && \
 cp libav-3.6.4.4.1-fat.asm.js libav-3.6.4.4.1-ennuicastr.asm.js && \
 cp libav-3.6.4.4.1-fat.js libav-3.6.4.4.1-ennuicastr.js && \
 cp libav-3.6.4.4.1-fat.wasm.js libav-3.6.4.4.1-ennuicastr.wasm.js && \
 cp libav-3.6.4.4.1-fat.wasm.wasm libav-3.6.4.4.1-ennuicastr.wasm.wasm && \
 cp libav-*-ennuicastr.* .. && \
 cd .. && rm -r libav.js* && \
 sed -i 's+libav-3.6.4.4.1-fat+libav-3.6.4.4.1-ennuicastr+g' libav-3.6.4.4.1-ennuicastr.* && \
 sed -r 's/libavVersion = ".*";/libavVersion = "3.6.4.4.1"/g' /ennuicastr/ennuicastr.js -i && \
 apt -y remove --purge make g++ ninja-build meson cmake pkgconf fftw-dev lv2-dev unzip emscripten && apt -y autoremove --purge && apt clean
RUN \
 apt -y install xutils-dev && \
 lndir /ennuicastr-server/web /var/www/html && \
 lndir /ennuicastr /var/www/html/rec && \
 lndir /ennuicastr/ennuizel /var/www/html/ennuizel && \
 lndir /ennuicastr/libav /var/www/html/ennuizel/libav && \
 lndir /ennuicastr-server/web/rec /var/www/html/rec && \
 ln -s /ennuicastr-server/ws/client/* /ennuicastr-server/ws/ && \
 ln -s /ennuicastr-server/web/assets/fa /var/www/html/rec && \
 ln -s /ennuicastr-server/web/assets/fa /var/www/html/ennuizel && \
 rm -r /var/www/html/rec/.gitignore* /var/www/html/rec/.es* /var/www/html/rec/*.md /var/www/html/rec/node_modules && \
 rm -r /var/www/html/rec/libav-configs /var/www/html/rec/src &&\
 rm -r /var/www/html/rec/Makefile /var/www/html/rec/*.json &&\
 apt -y remove --purge unzip xutils-dev;  apt -y autoremove --purge;apt clean &&\
 chown www-data.www-data -R /var/www

COPY ./s6/ /etc/services.d/
COPY ./defaults/ /defaults/
COPY ./web/ /var/www/html/

VOLUME /config
VOLUME /external
VOLUME /var/log/nginx
VOLUME /usr/share/jitsi-meet/transcripts
VOLUME /var/spool/cron/crontabs