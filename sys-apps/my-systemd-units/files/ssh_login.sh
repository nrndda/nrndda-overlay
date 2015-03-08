#!/bin/bash
export DISPLAY=:0
notify-send "Security Warning" "Occured Login as user \"$USER\" $(echo $SSH_CONNECTION | sed 's/\(.*\) \(.*\) \(.*\) \(.*\) \(.*\)/using SSH connection at \5 from \1:\2 to \3:\4/')" -u critical -i /usr/local/sbin/stock_dialog_warning_48.png > /dev/null 2>&1
#kdialog --title "Security Warning" --passivepopup "Occured Login as user \"$USER\" $(echo $SSH_CONNECTION | sed 's/\(.*\) \(.*\) \(.*\) \(.*\) \(.*\)/using SSH connection at \5 from \1:\2 to \3:\4/')" 5
wall " Occured Login as user \"$USER\" $(echo $SSH_CONNECTION | sed 's/\(.*\) \(.*\) \(.*\) \(.*\) \(.*\)/using SSH connection at \5 from \1:\2 to \3:\4/')"
#aplay -q /usr/local/sbin/KDE-Im-Phone-Ring.wav

#sleep 3
#killall -s 9 aplay
#killall -s 9 ssh_login.sh
