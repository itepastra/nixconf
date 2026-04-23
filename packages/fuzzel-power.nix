{
  writeShellScriptBin,
  fuzzel,
  lib,
  hyprlock,
  stdenvNoCC,
  inputs,
}:
writeShellScriptBin "fuzzel-power" ''
  lock="Lock"
  poweroff="Poweroff"
  reboot="Reboot"
  sleep="Suspend"
  logout="Log out"
  selected_option=$(echo -e "$poweroff\n$reboot\n$logout\n$sleep\n$lock" | ${lib.getExe fuzzel} --dmenu -i -p "Power ➜  ")

  if [ "$selected_option" == "$lock" ]
  then
  echo "lock"
  ${hyprlock}/bin/hyprlock
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
  ${
    lib.getExe inputs.niri.packages.${stdenvNoCC.hostPlatform.system}.default
  } msg action quit --skip-confirmation
  else
  echo "No match"
  fi
''
