#!/bin/bash

# http://serverfault.com/questions/144939/multi-select-menu-in-bash-script
# using this bash script rather than dialog or whiptail to make the script lightweight, portable
# and able to run if dialog or whiptail are not preinstalled

options=("basic_package.sh - install common utilities and programs needed across the board, e.g. node, python, etc"
         "smile_preparation.sh - install packages needed by Smile (redis, hiredis, couchdb)"
         "smile_setup.sh - install and implement Smile, including scripts to autostart services"
         "kiwix_wikipedia_setup.sh - install wikipedia")

bashscripts=("basic_package.sh"
             "smile_preparation.sh"
             "smile_setup.sh"
             "kiwix_wikipedia_setup.sh")

menu() {
  clear
  echo " "
  echo "Stanford GSE-IT Raspberry Pi Installation Kit "
  echo " "
  echo "Available options:"
  for i in ${!options[@]}; do
    printf "%3d%s) %s\n" $((i+1)) "${choices[i]:- }" "${options[i]}"
  done
	[[ "$msg" ]] && echo "$msg" || echo " ";
  echo " "
}

prompt="Check an option (again to uncheck, ENTER when done): "
while menu && read -rp "$prompt" num && [[ "$num" ]]; do
  [[ "$num" != *[![:digit:]]* ]] &&
  (( num > 0 && num <= ${#options[@]} )) ||
  { msg="Invalid option: $num"; continue; }
  ((num--)); msg="${bashscripts[num]} was ${choices[num]:+un}checked"
  [[ "${choices[num]}" ]] && choices[num]="" || choices[num]="+"
done

clear

totalchoices="nothing"
for i in ${!options[@]}; do
  [[ "${choices[i]}" ]] && { totalchoices=""; }
done
if [ "$totalchoices" == "nothing" ]; then
  echo ""
  echo "Exiting rpi3_install script. A selection was not made. Rerun this script when package selection is made."
  echo ""
  exit 1
fi

echo "You selected to install and run the following:"
for i in ${!options[@]}; do
  [[ "${choices[i]}" ]] && { echo "${options[i]}"; }
done
echo " "

#http://stackoverflow.com/questions/1885525/how-do-i-prompt-a-user-for-confirmation-in-bash-script
#https://gist.github.com/agsdot/1df63a328be1f01bda23ec1aa7942a45
read -p "Are you sure you want to proceed (y/n)? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo "Now let's run the the install scripts!"
  for i in ${!options[@]}; do
    [[ "${choices[i]}" ]] && { sh ${bashscripts[i]}; }
  done
else
  echo "Exiting rpi3_install script, run again at your convenience"
  echo " "
  exit 1
fi
