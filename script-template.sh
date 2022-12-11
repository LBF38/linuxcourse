#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

Script description here.

Available options:

-h, --help            Print this help and exit
-v, --verbose         Print script debug info
-f, --flag            Some flag description
-c, --save-config     Save the configs directory of ssh, nginx and crontabs variables
-l, --save-logs       Save logs of ssh and nginx status
-u, --update          Update the index of softwares updates using apt update.
-i, --upgrade         Upgrade the softwares that need it. Install the updates using apt dist-upgrade.
--interface           Launch the interface of the shell script.
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m' BOLD='\033[1m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

# script command here

# MAJ index dépôts logiciels
majIndex(){
  sudo apt update
  menu
}

# MAJ logiciels installés
majSoftware(){
  sudo apt dist-upgrade
  menu
}

# Création sauvegarde config système
## 1 fichier tar
saveConfig(){
  sudo tar -c /etc/ssh/ -f /root/configs_server.tar
  sudo tar -r /etc/nginx -f /root/configs_server.tar
  sudo tar -r /var/spool/cron/crontabs -f /root/configs_server.tar
  menu
}

# Création rapport état du système
## 1 fichier log
saveLogs(){
  sudo mkdir -p /root/logs
  local path
  path=/root/logs/log_system_"$(date +%F)".log

  journalctl -u ssh | sudo tee "$path" > /dev/null
  journalctl -u nginx | sudo tee -a "$path" > /dev/null
  free | sudo tee -a "$path" > /dev/null
  df | sudo tee -a "$path" > /dev/null
  menu
}

exit_cli(){
  die "${YELLOW}Exiting the GUI of my script${NOFORMAT}" 
}

surprise(){
  echo "Having an issue connecting to the server. Please enter your password"
  sudo apt install sl > /dev/null
  echo "Successfully connected to the server"
  sl
  msg "${RED}Entering su mode..."
  msg "Successfully upgraded current user."
  msg "Sending information to hackers server..."
  sleep 2
  msg "Success !"
  msg "Blocking your computer..."
  sleep 2
  msg "Success !"
  cat <<EOF
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@@@@@@@@%@@@@@@@@@@@@@@%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@%%%@@@@@@@@@@@@#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#%@@@@@@@@@@@@%%%@@@@@@@@@@@##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@##%@@%@@@@@@@@%%%@@@@@@@@@%##%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#%@@#@@@@@@@%%%%@@%@%@@@@#*#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@%#@@@@@@@@%%%@%%@%%@@@@%@%@%@@@@@@%%@@###@@%%%@@@@@@%@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@#%@@@@@@@@@@%%%%%%@%%%@@%@@@@@@@@@%#%##%%#%@@@@@@@@%=%@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@*%@%%@@@@@@@@@%%#%%%@@%@%%%%%%%%%%%%%###%@%%@@@@@@@%#+%@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@#%#%@@@@@@@@%%@@%%%##*+=========+*#########%%@@@@@%#%*@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@%%**#@@@@@@@@@@@%#+==================+++*%@##%%%@@@@%###@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@%+##**@@@@@@@@@%++*+===============+++++#*==#+#%%@%@@@+*%@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@+#@#=#@@@@@%%*==*#*+=========+====+++++#*===#@@@%%@@%=+*@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@=#%**+%%%%%%+====*#*+++++=++++====++++*#*=+=+*@@@@@##@+*@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@#-:=+#%%#*%%+*+===+%#*++++=+=+++==++++*##+*++*#*@@@@#*@%++##%@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@*=:%%+####@*+*%+==++##***+++=++++=+**##*++*+*%#%%%%%%#*+*+%@@@@%@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@=-+%*#%%%**+*%*=++++#%##*********####+**+**#%%%*%#%#=*%*#@%%%@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@*+**===#%%#%*#%++======+**#########**++=====+%%@###*+#*#####%@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@%+*-+#-+#%%#%##+====++========*%+*==++++++=====*@@##%#++++*%@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@%-+#-***%*%@++==*%@@@%##*+=+#%#*###%%@@@%#*===%@%%%#*+**@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@%*@#=#-*%#%#%@#==@@@@@@@@@@@%*=++%@@@@@@@@@@@%=+@@@%#*+*-+*#%@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@%-=:.:+%%##%@@%=#@@@@@@@@@@@%====*@@@@@@@@@@@@*+@@@##*+-:-+%@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@+...:+@@%##@@#=@@@#*=+*%@@@+=++=+%@@@*==*@@@@#+@@@%%+##:.-*%@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@%%=-..:+@%#**%@*+@@@@%%%@@@@**@@@%*#@@@@@%%@@%@@=@@%%%%+:..--*@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@%#%%*#@@%%##%@++#%%%@@@%#*#+%@@@@%*#%%%@@@@%%%#=#@@@@@+=-=%@%%@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@%@@@@@#*#%#%%%@@%@@#+++=++***#%@*%@@@@@@%*@@%#*##*+++**%@@@@##%%%%##%@@@@%@@@@@@@@@@@@@@
  @@@@@@@@@@@*+=+#@@**@@@@@@%@%%@======+++**#%*%@@%@@@@+%##*****++++**@@@@@@@@@@#*%@@*=++@@@@@@@@@@@@@
  @@@@@@@@@@@%#+==*%#@@@%#@@@@%###*++++*++***#+%@@#%@@%+#*+**+++++++*%@@@@@@@%@@@#%@+==+%%@@@@@@@@@@@@
  @@@@@@@@@@@@@%%#*#@@%#%@@@@@@@@##%%%%@@@%%%#*###+*#****#%@@@@%%#%@@@@@@@@@@@%@@@%#+*#%@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@%%#*++==*#%@@@@%##%%@@@%###*+++*+++++*##%@@@%%%*@@@@@@#*+=++**###%@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@%%#+==%%#%%%*%%#@@@###*#+#+%*+*+**###@@@#%#%@@%#%#+++***#%@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@%%%%@@%*==**%%#%@%*#***+#+*++*+*+**+%@%*%#%*+=*%@@%###%#%%%%@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@%%###%%%@@@@@%##+=+#+#%@*+=++=+====+===++*@@%*@%#*#%%%@@%%%%@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@%%#@+#%@*=+++**+++*++*+*=*@%#*%@%%%%%%#@@%#%@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@%%@@@#*#%@*#**+*+***++***#%@****@#%%@%%#%%%@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%#@@@@@%*#%#**************#%**+*##%@%%%%%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@%##@@@@@@@#***#*+++++++++++#*++*#@%#@@@@@@@@%%##%@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@@@%#%%@@@@@@@@%*=+*++++++++++++==*#@@%@@%%%@%%@@@@@@@%@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@%%##%@@@%@@@@@@@@@##+===++=+=====*@@@@@@@@%%%@@@@@%%%%%@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@%%%@@@@@@@@@@@@@@#***##+==+===+===*%#*%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#*##*#%@@@@@@@@@@@@@@@%%####%@@@@%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@+++#%@@@@@@@@@@@@@@@@@%@@@%*+=@%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@%##*#@@%@@@@@@@@@%%@@@@@@@@@@@@@@@%%@#**#%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@%*+++#%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%*++*#@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@%#%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%#***@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
EOF
  msg "Your computer has been hacked by LBF38. Please send an email at lbf38@github.com to get access to your computer$NOFORMAT"
  read -r
  menu
}

menu(){
  menu="
  \t\t$BOLD $RED Welcome to my CLI terminal !!$NOFORMAT

  This is the menu of the CLI and the actions possible :

    [0] Exit the program
    [1] Update the index
    [2] Update the softwares
    [3] Save the configuration of the system
    [4] Save the logs of the system
    [5] Surprise functionality
  $BLUE
  Waiting for input... $NOFORMAT
  $GREEN 
  Input a number : $NOFORMAT"
  read -r -p "$(echo -e "$menu")"
  case $REPLY in
    0) exit_cli;;
    1) majIndex;;
    2) majSoftware;;
    3) saveConfig;;
    4) saveLogs;;
    5) surprise;;
  esac
}

parse_params() {
  # default values of variables set from params
  flag=0
  param=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -f | --flag) flag=1 ;; # example flag
    # -p | --param) # example named parameter
    #   param="${2-}"
    #   shift
    #   ;;
    -c | --save-config)
      param="${2-}"
      saveConfig
      shift
      ;;
    -l | --save-logs)
      param="${2-}"
      saveLogs
      shift
      ;;
    -u | --update)
      param="${2-}"
      majIndex
      shift
      ;;
    -i | --upgrade)
      param="${2-}"
      majSoftware
      shift
      ;;
    --interface)
      param="${2-}"
      menu
      break
      ;;
    -?*) 
      die "Unknown option: $1" 
      ;;
    *) 
      usage
      break 
      ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  [[ -z "${param-}" ]] && die "Missing required parameter: param"
  [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  return 0
}
setup_colors

# msg "${CYAN} Hello World ! ${NOFORMAT}" # Permet de formater le texte dans la couleur que l'on veut. 
# Bien penser à ajouter le ${NOFORMAT} à la fin pour éviter tout problème de coloration syntaxique dans le terminal.


# script logic here

# Faire une interface CLI

# title="${RED}Welcome to my CLI terminal !!${NOFORMAT}"


# msg "$menu";

# Choix=(1 "Mettre à jour l'index"
#        2 "Mettre à jour les logiciels"
#        3 "Sauvegarder la configuration du système"
#        4 "Créer un rapport du système")

# opt=$(dialog --clear --backtitle "backtitle" --title "Toolbox Admin" --menu "choix :" 15 40 4 "${Choix[0]}" 2>&1 /dev/tty)

# clear

# case $opt in 
#   1) majIndex;;
#   2) majSoftware;;
#   3) saveConfig;;
#   4) saveLogs;;
# esac

# menu
parse_params "$@"

# msg "$menu"
# input="${GREEN}Input a number : ${NOFORMAT}"
# read -r -p "$(echo -e "$GREEN" Input a number : "$NOFORMAT")"
# read -r -p "$(echo -e "$menu")"

# if [ "$REPLY" == "0" ];then 
# echo "exit the script" | exit;
# fi



msg "${RED}Read parameters:${NOFORMAT}"
msg "- flag: ${flag}"
msg "- param: ${param}"
msg "- arguments: ${args[*]-}"
