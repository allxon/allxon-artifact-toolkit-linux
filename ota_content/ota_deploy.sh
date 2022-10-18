#!/bin/bash
set -e
echo -ne "Installing... \n"

cp allxon-ascii-pure.sh /usr/share/allxon-dms-agent/.
cp hello_ota.png /usr/share/allxon-dms-agent/.
cp allxonOTA.desktop /usr/share/applications/.

active_user=$(who | awk 'NR==1{print $1}')
su $active_user -c 'cp /usr/share/applications/allxonOTA.desktop $HOME/Desktop/.'
su $active_user -c 'chmod u+x $HOME/Desktop/allxonOTA.desktop'

echo -ne "Install finishded! \n"
