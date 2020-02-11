# linux
some_usefull_scripts

 ---add_domainAD_Ubuntu.sh - скрипт по добавлению в AD Ubuntu
    username_whichcanADD_Domain - username which can add to domain AD object
    HIS_PASSWORD - his password
  dc1.local.domain:
    dc1 -Domain Controller
    local.domain - fqdn your domain
    DOMAIN_NAME - short name your domain, as example, LOCAL
    linux_admins - your AD security global group, member this group can use sudo
    linux_users - your AD security global group, member this group can login and work on linux hosts

run as root.
You need chmod +x add_domainAD_Ubuntu.sh before start
then ./add_domainAD_Ubuntu.sh

 ---add_domainAD_centos.sh - скрипт по добавлению в AD Centos
    username_whichcanADD_Domain - username which can add to domain AD object
    HIS_PASSWORD - his password
  dc1.local.domain:
    dc1 -Domain Controller
    local.domain - fqdn your domain
    DOMAIN_NAME - short name your domain, as example, LOCAL
    linux_admins - your AD security global group, member this group can use sudo
    linux_users - your AD security global group, member this group can login and work on linux hosts
You need chmod +x add_domainAD_centos.sh before start
then ./add_domainAD_centos.sh
