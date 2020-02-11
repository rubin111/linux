


#!/bin/bash
yum install samba samba-winbind samba-winbind-clients pam_krb5 krb5-workstation mailx -y

rm -rf /etc/krb5.conf

echo '# Configuration snippets may be placed in this directory as well
includedir /etc/krb5.conf.d/
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
 default_realm = LOCAL.DOMAIN
 proxiable = true
 ccache_type = 4
# default_ccache_name = KEYRING:persistent:%{uid}
[realms]
 LOCAL.DOMAIN = {
  kdc = dc1.LOCAL.DOMAIN dc2.LOCAL.DOMAIN dc3.LOCAL.DOMAIN
  admin_server = dc1.LOCAL.DOMAIN dc2.LOCAL.DOMAIN dc3.LOCAL.DOMAIN
 }
[domain_realm]
 .LOCAL.DOMAIN = LOCAL.DOMAIN
 LOCAL.DOMAIN = DOMAIN_NAME' >> /etc/krb5.conf

chmod 644 /etc/krb5.conf

chown root:root /etc/krb5.conf

rm -rf /etc/samba/smb.conf

echo '
# See smb.conf.example for a more detailed config file or
# read the smb.conf manpage.
# Run 'testparm' to verify the config is correct after
# you modified it.
[global]
security = ads
kerberos method = secrets and keytab
dedicated keytab file = /etc/krb5.keytab
realm = LOCAL.DOMAIN
password server = dc1.LOCAL.DOMAIN dc2.LOCAL.DOMAIN dc3.LOCAL.DOMAIN
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
        directory mask = 0775' >> /etc/samba/smb.conf

chmod 644 /etc/samba/smb.conf

chown root:root /etc/samba/smb.conf

echo -e "$(hostname -i)" "$(hostname)" "$(hostname -s)" >> /etc/hosts
echo -e "$(hostname -i)" "$(hostname).LOCAL.DOMAIN" "$(hostname -s)" >> /etc/hosts

sed -i 's/.*passwd:.*/passwd: compat winbind/' /etc/nsswitch.conf
sed -i 's/.*shadow:.*/shadow: compat winbind/' /etc/nsswitch.conf
sed -i 's/.*group:.*/group: compat winbind/' /etc/nsswitch.conf

sed -i '2i\auth        sufficient    pam_winbind.so\' /etc/pam.d/system-auth
echo 'session     required      pam_mkhomedir.so umask=0022 skel=/etc/skel' >> /etc/pam.d/system-auth
sed -i '2i\auth        sufficient    pam_winbind.so\' /etc/pam.d/sshd
echo 'session     required      pam_mkhomedir.so umask=0022 skel=/etc/skel' >> /etc/pam.d/sshd
echo 'require_membership_of=linux_users,linux_admins' >> /etc/security/pam_winbind.conf
echo '%linux_admins   ALL=(ALL)       ALL' >> /etc/sudoers
sed -i 's/.*PasswordAuthentication no.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/.*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

net ads join -U username_whichcanADD_Domain%HIS_PASSWORD
net ads keytab create -U username_whichcanADD_Domain%HIS_PASSWORD

service smb start
service winbind start
service sshd restart
chkconfig smb on
chkconfig winbind on

 echo "$(hostname) in your DOMAIN $(date)" | mail -s "$(hostname) was addes in AD" -r $(hostname)@DOMAIN_NAME.ru Useremail@DOMAIN_NAME.ru




