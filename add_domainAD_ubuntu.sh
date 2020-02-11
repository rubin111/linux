#!/bin/bash

sudo timedatectl set-timezone Europe/Moscow
sudo apt-get install krb5-user samba winbind libpam-krb5 libpam-winbind libnss-winbind -y

sudo rm -rf /etc/krb5.conf


sudo bash -c "echo '# Configuration snippets may be placed in this directory as well
#includedir /etc/krb5.conf.d/
[logging]
 default = FILE:/var/log/krb5libs.log
# kdc = FILE:/var/log/krb5kdc.log
# admin_server = FILE:/var/log/kadmind.log
[libdefaults]
# dns_lookup_realm = false
 clockskew = 300
 ticket_lifetime = 4h
 kdc_timesync = 1
 renew_lifetime = 7d
 forwardable = true
# rdns = false
 default_realm = local.domain
 proxiable = true
 ccache_type = 4
# default_ccache_name = KEYRING:persistent:%{uid}
[realms]
 local.domain = {
  kdc = dc1.local.domain dc2.local.domain dc3.local.domain
  admin_server = dc1.local.domain dc2.local.domain dc3.local.domain
 }
[domain_realm]
 .local.domain = local.domain
 local.domain = DOMAIN_NAME' >> /etc/krb5.conf"

sudo chmod 644 /etc/krb5.conf

sudo chown root:root /etc/krb5.conf

sudo rm -rf /etc/samba/smb.conf

sudo bash -c "echo '
# See smb.conf.example for a more detailed config file or
# read the smb.conf manpage.
# Run 'testparm' to verify the config is correct after
# you modified it.
[global]
winbind offline logon = yes  
winbind cache time = 300  
security = ads
kerberos method = secrets and keytab
dedicated keytab file = /etc/krb5.keytab
realm = local.domain
password server = dc1.local.domain dc2.local.domain dc3.local.domain
workgroup = DOMAIN_NAME
winbind separator = +
idmap uid = 10000-20000
idmap gid = 10000-20000
winbind enum users = yes
winbind enum groups = yes
template homedir = /home/%D/%U
template shell = /bin/bash
client use spnego = yes
client ntlmv2 auth = yes
encrypt passwords = yes
winbind use default domain = yes
restrict anonymous = 2
[homes]
       comment = Home Directories
        valid users = %S, %D%w%S
        browseable = No
        read only = No
        inherit acls = Yes
[printers]
        comment = All Printers
        path = /var/tmp
        printable = Yes
        create mask = 0600
        browseable = No
[print$]
        comment = Printer Drivers
        path = /var/lib/samba/drivers
        write list = @printadmin root
        force group = @printadmin
        create mask = 0664
        directory mask = 0775' >> /etc/samba/smb.conf"

sudo chmod 644 /etc/samba/smb.conf

sudo chown root:root /etc/samba/smb.conf

sudo bash -c "echo -e "$(hostname -i)" "$(hostname)" "$(hostname -f)" >> /etc/hosts"

sudo bash -c "sed -i 's/.*passwd:.*/passwd: compat winbind/' /etc/nsswitch.conf"
sudo bash -c "sed -i 's/.*shadow:.*/shadow: compat winbind/' /etc/nsswitch.conf"
sudo bash -c "sed -i 's/.*group:.*/group: compat winbind/' /etc/nsswitch.conf"

sudo bash -c "sed -i '2i\auth        sufficient    pam_winbind.so\' /etc/pam.d/common-auth"
sudo bash -c "echo 'session     required      pam_mkhomedir.so umask=0022 skel=/etc/skel' >> /etc/pam.d/common-auth"
sudo bash -c "sed -i '2i\auth        sufficient    pam_winbind.so\' /etc/pam.d/sshd"
sudo bash -c "echo 'session     required      pam_mkhomedir.so umask=0022 skel=/etc/skel' >> /etc/pam.d/sshd"

sudo bash -c "echo '
# pam_winbind configuration file  
#  
# /etc/security/pam_winbind.conf  
#  
[global]  
# turn on debugging  
debug = no  
# request a cached login if possible  
# (needs winbind offline logon = yes in smb.conf)  
cached_login = yes  
# authenticate using kerberos  
krb5_auth = yes  
# when using kerberos, request a  krb5 credential cache type  
# (leave empty to just do krb5 authentication but not have a ticket  
# afterwards)  
krb5_ccache_type = FILE  
# make successful authentication dependend on membership of one SID  
# (can also take a name)  
require_membership_of =  linux_users,linux_admins
silent = yes'  >> /etc/security/pam_winbind.conf"
PasswordAuthentication no.*/PasswordAuthentication yes/' /etc/ssh/sshd_config"
sudo bash -c "sed -i 's/.*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config"
sudo net ads join -U username_whichcanADD_Domain%HIS_PASSWORD
sudo net ads keytab create -U username_whichcanADD_Domain%HIS_PASSWORD
sudo systemctl enable winbind
sudo systemctl enable smbd
sudo passwd -l ubuntu
sudo reboot




sudo bash -c "echo '%linux_admins   ALL=(ALL)       ALL' >> /etc/sudoers"
sudo bash -c "sed -i 's/.*
