# Mailcow Server With Ansible

This is an evolution from https://github.com/ruppel/myserver.

After the os upgrade to debian 12 the system had sever problems. I didn't manage to fix them so I decided to make a complete new setup. A friend recommended mailcow to me, so i gave it a try and .... it is wonderful.

These are the scripts that I used (and use) to configure my running web and mail server.
Take them as a blueprint for your needs.
Do not blindly clone them and start. Having a web and mail server in the internet needs that you understand what you are doing!!

## My architecture on the server

- Use [debian](https://www.debian.org/) 12 (bookworm) as basis OS
- Keep the system up to date automatically
- Use [docker](https://www.docker.com/) containers
- Use [traefik](https://traefik.io/) as reverse proxy for the docker containers
- Use [letsencrypt](https://letsencrypt.org/) with DNS Challenge to get SSL certificates
- Use [mailcow](https://letsencrypt.org/) dockerized for the mail ecosystem
- Use [portainer](https://www.portainer.io/) for the look inside containers if something fails
- Use [watchtower](https://containrrr.dev/watchtower/) to keep the docker images up to date
- Use [ansible](https://www.ansible.com/) for (nearly) everything to be setup on the server

Apps added:

- [Joplin-Server](https://github.com/laurent22/joplin/blob/dev/packages/server/README.md) as Sync Server for [Joplin](https://joplinapp.org/)
- [Wireguard](https://www.wireguard.com/) as VPN entry point
- [Nextcloud](https://nextcloud.com/) to store files, sync contacts and calendars (and bookmarks)
- [Vaultwarden](https://github.com/dani-garcia/vaultwarden) to store and sync credentials over all my clients
- (more to come)

## My architecture on the dev side (the captains chair)

- Use [Visual Studio Code](https://code.visualstudio.com/)
- Use ansible in a docker container, i.e. [podman](https://podman.io/) container
- Use a few simple scripts (Unix Shell, working under MacOS) to start ansible
- Use [ansible vault](https://docs.ansible.com/ansible/latest/cli/ansible-vault.html) to encrypt my inventory file
  - The password is stored in file `.vault-pass.txt` (which is listed in `.gitignore`)
  - The file `ansible.cfg` references that file, so to encrypt your inventory file use
    `./podman-ansible/ansible-vault encrypt inv-server.yml`
  - I didn't manage to get implicit vault decryption working in docker container ansible...
    - so before you use your inventory you should decrypt it with
      `./podman-ansible/ansible-vault decrypt inv-server.yml`

## !!!!CAVEAT!!!!

_Check the scripts! You need to understand what's going on._
_Use the scripts at your own risk! I do not take any responsibility for damages or data losses!_
_As said before, in my opinion an administrator of a internet facing server should ALWAYS know, what he is doing!_

# Setup

## Setup your ansible controller machine

You might install [ansible](https://www.ansible.com/) on your desktop computer.

I prefer using the ansible docker image `cytopia/ansible:latest-tools` and instead of calling `ansible-playbook ...` I use my script here `./podman-ansible/ansible-playbook ...`

Things can be sooooo easy :-)

Podman sometime looses the link to the volume. If podman returns
`Error: statfs /Users/xxxx/.ssh: no such file or directory`
do a
`podman machine stop; podman machine start`

## Setup server OS

This is based on [Debian](https://www.debian.org/) Bookworm (12) installation. There are tutorials on how to install that.

## Setup ansible on the server

- Install ansible
  - See `010-install-ansible-controller.sh` for simple script that installs pipx and ansible on debian

## Enable server user to do sudo and use ssh-key

If you want to use a user other than root:

- Connect to host using ssh with root user
- Install sudo: `apt install sudo`
- Have a non-root user on the host, who is allowed to call `sudo`
  (On debian `adduser username`, give password and data and do a `usermod -aG sudo username`)
- Additionally connect to host using your now user `username`

For the root user, or the user you created above:

- Copy your public ssh key to file `~/.ssh/authorized_keys` to use Public/Private Key SSH Connection
- Do the ssh connection to the server (to check if it works and to get the fingerprint of the server)

## Initial Setup variables

- Copy file `inv-example.yml` to `inv-myserver.yml`
- Change values in `inv-myserver.yml` to your needs, for the first test you need
  - `ansible_host`
  - `ansible_user` and
  - `ansible_become_password` to be set correctly
- Set `ansible_port` to 22, which is the default ssh port. Or directly to the port you configured your server

## Check the ansible connection

- `ansible-playbook -i inv-myserver.yml pingtest.yml`

It should return a "OK"

## Configure your inventory

- Change vars in file `inv-myserver.yml` to your needs. Especially you are encouraged to change the ssh port to something other than 22, take 22401 for example.

## Ensure SSH port

- `ansible-playbook -i inv-myserver.yml 020-ensure-target-ssh-port.yml`
  This checks the ssh port and changes it if needed

## Check the ansible connection

- `ansible-playbook -i inv-myserver.yml pingtest.yml`
  This is the same test above, but it's now using the other ssh port.
- Check the SSH connection to the new port with a terminal, also.

## Set the stage

- `ansible-playbook -i inv-myserver.yml 030-set-the-stage.yml`
  This sets the hostname, enhances the sources for apt, installs required ansible tools, updates the system, does a restart, changed dash to bash and disabled sendmail

## Install the service applications

- `ansible-playbook -i inv-myserver.yml 040-install-service-apps.yml`
  This will install ntp, automatic security updates, fail2ban, docker, traefik, portainer and a docker demo nginx app
- Check, whether you can access the docker demo app in your browser
- Wait a while to see, whether traefik and letsencrypt obtained a certificate (might take few minutes)
- Check whether traefik and portainer are running
- Only move to the next step, if all works

## Install Mailcow

- `ansible-playbook -i inv-myserver.yml 050-install-mailcow.yml`
  This will install and startup mailcow (and all containers in that family)
- Check, whether you can access the webinterface of mailcow (may take a few seconds)
- Login using startpassword (see https://docs.mailcow.email/i_u_m/i_u_m_install/#start-mailcow)
- Change your Password
- Add "127.0.0.0/8" (as well as your local ip and or your dyndns-domain) to the fail2ban whitelist
  System > Configuration > Options > Fail2Ban parameters
- Check the logs (i.e. using portainer) whether there is still a problem
- Add E-mail Domains and Mailboxes (of course check out the mailcow documentation)

Congrats! You have a working mailserver!

## Install additional applications

These are my additional application. Use or don't use them, as you like.

- `ansible-playbook -i inv-myserver.yml 060-install-additional-apps.yml`
  This will install
  - Joplin Server
  - Wireguard
  - Nextcloud
  - Vaultwarden
  - Watchtower

## DNS, DKIM and DMARC

- Configure your DNS as documented in https://docs.mailcow.email/prerequisite/prerequisite-dns/
- Have entries for DKIM and DMARC
- (let the servers a little time to syncronize over the world...)

# Move to another server

Information on how to move all your services from Server A-SRC to Server B-DST

## Checks / thoughts before you start

- A-SRC and B-DST should have been setup using the scripts from here
- You have a working inventory file for A-SRC (e.g. `inv-A-SRC.yml`) and for B-DST (e.g. `inv-B-DST.yml`)
- Data in B-DST will get lost! (You might want to backup them...)
- The scripts actually backup and restore the following apps
  - traefik
  - mailcow
  - joplin
  - wireguard
  - vaultwarden
  - nextcloud
- Check if you have the same versions of that apps in A-SRC and B-DST
- For joplin: Force the clients to "Re-upload local data to sync target"
  - This can be found in Preferences > Synchronization > Show Advanced Settings
  - (I needed days to find out, that this is necessary)
- The scripts will create a SSH-Key on the B-DST server and transfer it to the A-SRC server. Having that we cat SFTP the data from there without a password

## Steps to do to move your data from A-SRC to B-DST

- Setup the destination server using the scripts above
- We need a direct file transfer from A-SRC to B-DST, so ensure to have a ssh-key on B-DST:
  - `ansible-playbook -i inv-B-DST.yml 101-MOVE-prepare-dst.yml`
- Add this key to the authorized keys in A-SRC with command
  - `ansible-playbook -i inv-A-SRC.yml 102-MOVE-prepare-src.yml`
- now you should be able to SSH from B-DST to A-SRC. Check this out, using the correct port
  - really do this to get the fingerprint of the server
- Now we create the backup bundle using
  - `ansible-playbook -i inv-A-SRC.yml 110-MOVE-backup-src.yml`
- Copy the backup to the destination and restore the data there
  - `ansible-playbook -i inv-B-DST.yml 120-MOVE-restore-dst.yml`
- MAILCOW... BY NOW, AUTOMATED RESTORE DOESN'T WORK
  - You need to restore manually
  - Shell in B-DST
  - `cd /opt/mailcow`
  - `./helper-scripts/backup_and_restore.sh restore`
  - Asked for the backup location give the value from the inventory file `inv-B-DST.yml` for `backup.restore_from` followed by `/mailcow/`
  - Answer the other questions
    - Restore point should be only one available, so answer 1
    - Dataset to restore, answer 0 to restore all
    - Force a resync,... (I don't know, but I think it is a good idea), so I answer y
    - Stop and restart mailcow ==> answer y
  - After that I shutdown mailcow using `docker compose down` and restart it using `docker compose up -d`
  - This should restore mailcow completely without error messages
- Check, if everything is working and no data is missing
