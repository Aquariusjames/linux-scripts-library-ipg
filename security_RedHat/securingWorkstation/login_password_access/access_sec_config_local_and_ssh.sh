#!/bin/bash

# as usual, using module pam.d, loading pam_access.so library in the section we require:

# login: to prevent a user to login in the system:
/etc/pam.d/login
account	required	pam_access.so
# the configure /etc/security/access.conf
- : john : ALL

# now with sshd services:
/etc/pam.d/sshd
account	required	pam_access.so
# access to everyone from IP 10.57.121.55 except John:
/etc/security/access.conf
+ : ALL EXCEPT john : 10.57.121.55

# it is possible to call the pam_access library module for all services that call the system wide PAM configuration files in the /etc/pam.d directory:
echo 'authconfig --enablepamaccess --update' | tee -a /etc/pam.d/*-auth

# restricting access by time: pam_time.so , /etc/security/time.conf
/etc/pam.d/login
account required pam_time.so
# example: restricting LOCAL login access from 17:30h to 08:00h except for root
/etc/security/time.conf
login ; tty* ; ALL ; !root ; !Wk1730-0800
# now in a sshd config:
/etc/security/time.conf
sshd ; tty* ; john ; Wk0800-1730 # john can only connect via sshd during working hours


### setting limits

# maxlogins:
/etc/pam.d/system-auth
session required	pam_limits.so
/etc/security/limits.conf
#<domain>      <type>  <item>         <value>
@office - maxlogins 4 # for user of group office, maxlogins=4 ... instead of @groupname can be username


