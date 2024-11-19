{ pkgs, ... }:
pkgs.writeShellScriptBin "fuzzel-power" ''
  lock="Lock"
  poweroff="Poweroff"
  reboot="Reboot"
  sleep="Suspend"
  logout="Log out"
  selected_option=$(echo -e "$lock\n$sleep\n$reboot\n$logout\n$poweroff" | ${pkgs.fuzzel}/bin/fuzzel --dmenu -i -p "Powermenu")

  if [ "$selected_option" == "$lock" ]
  then
  echo "lock"
  swaylock
  elif [ "$selected_option" == "$poweroff" ]
  then
  echo "poweroff"
  poweroff
  elif [ "$selected_option" == "$reboot" ]
  then
  echo "reboot"
  reboot
  elif [ "$selected_option" == "$sleep" ]
  then
  echo "sleep"
  suspend
  elif [ "$selected_option" == "$logout" ]
  then
  echo "logout"
  niri msg quit --skip-confirmation
  else
  echo "No match"
  fi
''
