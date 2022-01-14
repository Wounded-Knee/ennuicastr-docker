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
3. start the script and wait for the magic to happen
4. If all goes well, check the created files in the run directory
5. Add a symlink to the nginx/nginx.conf in /etc/nginx/sites-available and __TEST__ the config before restarting
```
ln -s (install path)/nginx/nginx.conf /etc/nginx/sites-available/<yoursite.xyz>.conf
service nginx configtest
```
6. Point your browser to your site and test

## Notes

- This is not for the faint of heart! The latest version of the projects are checked out from the repository, as all corresponding projects are under development, the changes may break the build
- The listen port range for ennuicastr-daemon was reduced to 15000-15050 to support small instances
- You may add/modify files served by your instance in the jitsi-ennuicastr/web directory, but note you need to rerun setup (or docker compose) for changes to take effect.

## Todo
- Modify scripts to take port range from config
- Add magic button to add more money to administrator
