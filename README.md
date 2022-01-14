# ennuicastr-docker
Script to set up ennuicastr in a docker instance
This was created to allow ennuicastr deployment in a closed docker environment, for those, who want to host it on their own.

## Prerequisites

You will need a Ubuntu server (tested with 21.10) running 
* docker
* ningx
* two domain names _something.xzy_ and ___jitsi____.something.xyz_ it can be anything like a subdomain, as long as the second prefixes the first with __jitsi__
* letsencrypt certificates created for the domain above

Google authentication requires Google API keys generated for the site

Paypal integration requires PayPal keys set up

## Setup

1. Use a root shell.
1. Check the code out to a place of your liking, this is where the runtimes will be kept!
2. Create the environment _.env_ file from the template and fill up the sections above with your settings
3. start the script and wait for the magic to happen, might take an hour to build..
4. If all goes well, check the created files in the run directory to see if your settings are applied properly
5. Add a symlink to the nginx/nginx.conf in /etc/nginx/sites-available and __TEST__ the config before restarting
```
ln -s (install path)/nginx/nginx.conf /etc/nginx/sites-available/<yoursite.xyz>.conf
service nginx configtest
```
6. Point your browser to your site and test

## Generating PayPal secrets
The included script doesn't work 
- you need to create your paypal Oauth2 token using the (REST API) [https://developer.paypal.com/api/rest/] 
```
curl -v POST https://api-m.sandbox.paypal.com/v1/oauth2/token \
  -H "Accept: application/json" \
  -H "Accept-Language: en_US" \
  -u "CLIENT_ID:SECRET" \
  -d "grant_type=client_credentials"
 ```
 - log onto the web instance and go to /ennuicastr-server/subscriptions
 - modify the create.js to use `Bearer access_token` from above instead of the Basic, but keep the base64 encoding of the token.
 - run create.js and put it directly in the (your install)/run/ennuicastr/config.js.template 
 - rerun setup.sh

## TROUBLESHOOTING

The embedded nginx is logging to (install path)/run/web/logs. This can be adjusted in the (install path)/jitsi-ennuicastr/defaults/meet.conf and the (install path)/nginx/internal-jitsi.conf files, than rerun setup. As it adds to the last docker layer, it will not take long to build.
- Use the browser's developer panel to see if the resources are loaded properly, and check the connections are to the right hosts.
- Make sure the names are pointing to the right server and resolve to that in your test environment.
- Update your letsencrypt certificates.
- Make sure the ports 443 and 15000-15050 are exposed and are accessible on your server.

Log onto the instances (mostly the web) and see what's happening there.
```
docker exec -it ennuicastr_web_1 bash
```

## Notes

- This is not for the faint of heart! The latest version of the projects are checked out from the repository, as all corresponding projects are under development, the changes may break the build
- The listen port range for ennuicastr-daemon was reduced to 15000-15050 to support small instances, if you need more or want to relocate them, modify the jitsi-ennuicaster/Dockerfile and the setup.sh to update accordingly NB: All exposed ports open docker socket proxies, so you should consider that before extending the port range! I don't recommend to use this as a large instance! 
- You may add/modify files served by your instance in the jitsi-ennuicastr/web directory, but note you need to rerun setup (or docker compose) for changes to take effect.

## Known issues
- Fix BOSH connection -- maybe needs to use another certificate?
- Fix secret.js creation and inclusion for creating Paypal subscription (needs to be done manually ATM, because secrets.js does not work!)

## Todo
- Modify scripts to take port range from config
- Add magic button to add more money to administrator
