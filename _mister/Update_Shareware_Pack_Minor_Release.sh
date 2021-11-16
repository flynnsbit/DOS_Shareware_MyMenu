#!/bin/bash
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Copyright 2019-2020 Alessandro "Locutus73" Miele

# You can download the latest version of this script from:
# https://github.com/flynnsbit/DOS_Shareware_MyMenu/tree/main/_mister

ver="v.20"

# ========= OPTIONS ==================
URL="https://github.com"
SCRIPT_URL="${URL}/flynnsbit/DOS_Shareware_MyMenu/blob/main/_mister/update/Update_Shareware_updater_minor.sh"
CURL_RETRY="--connect-timeout 15 --max-time 120 --retry 3 --retry-delay 5 --silent --show-error"
# Make sure you download the latest .ini file with this .sh script and change the basepath to where your VHDs are located.
# ini located at https://raw.githubusercontent.com/flynnsbit/DOS_Shareware_MyMenu/main/_mister/Update_Shareware_Pack_Minor_Release.ini


# ========= ADVANCED OPTIONS =========
# ALLOW_INSECURE_SSL="true" will check if SSL certificate verification (see https://curl.haxx.se/docs/sslcerts.html )
# is working (CA certificates installed) and when it's working it will use this feature for safe curl HTTPS downloads,
# otherwise it will use --insecure option for disabling SSL certificate verification.
# If CA certificates aren't installed it's advised to install them (i.e. using security_fixes.sh).
# ALLOW_INSECURE_SSL="false" will never use --insecure option and if CA certificates aren't installed
# any download will fail.
ALLOW_INSECURE_SSL="true"

# ========= CODE STARTS HERE =========
# Ansi color code variables
red="\e[0;91m"
blue="\e[0;94m"
expand_bg="\e[K"
blue_bg="\e[0;104m${expand_bg}"
red_bg="\e[0;101m${expand_bg}"
green_bg="\e[0;102m${expand_bg}"
green="\e[0;92m"
white="\e[0;97m"
bold="\e[1m"
uline="\e[4m"
reset="\e[0m"
function pause(){
 echo -en "\ec"
 echo -e "${red_bg}${reset}"
 echo -e "This script updates the ${green}(flynnsbit Shareware DOS Games pack for the AO486 Core)${reset} VHD to fix games and add features that were not included in the original version.  This script directly mounts and modifies the VHD in one step. If the script fails to find your VHD you will need to edit the script and change the User options at the top to fit your setup and re-run." 
 echo -e "${red}Please backup any changes you have made to the pack before running this update.${reset}"
 echo -e ""
 echo -e "${green}Script version ${ver}${reset}"
 read -s -n 1 -p "Press any key to continue . . ."
 echo ""
}

# get the name of the script, or of the parent script if called through a 'curl ... | bash -'
ORIGINAL_SCRIPT_PATH="${0}"
[[ "${ORIGINAL_SCRIPT_PATH}" == "bash" ]] && \
	ORIGINAL_SCRIPT_PATH="$(ps -o comm,pid | awk -v PPID=${PPID} '$2 == PPID {print $1}')"

# ini file can contain user defined variables (as bash commands)
# Load and execute the content of the ini file, if there is one
INI_PATH="${ORIGINAL_SCRIPT_PATH%.*}.ini"
if [[ -f "${INI_PATH}" ]] ; then
	TMP=$(mktemp)
	# preventively eliminate DOS-specific format and exit command  
	dos2unix < "${INI_PATH}" 2> /dev/null | grep -v "^exit" > ${TMP}
	source ${TMP}
	rm -f ${TMP}
fi

# test network and https by pinging the target website 
SSL_SECURITY_OPTION=""
curl ${CURL_RETRY} "${URL}" > /dev/null 2>&1
case $? in
	0)
		;;
	60)
		if [[ "${ALLOW_INSECURE_SSL}" == "true" ]]
		then
			SSL_SECURITY_OPTION="--insecure"
		else
			echo "CA certificates need"
			echo "to be fixed for"
			echo "using SSL certificate"
			echo "verification."
			echo "Please fix them i.e."
			echo "using security_fixes.sh"
			exit 2
		fi
		;;
	*)
		echo "No Internet connection"
		exit 1
		;;
esac

# download and execute the latest AO486 Top 300 Update pack.sh
pause
echo "Downloading and executing"
echo "${SCRIPT_URL/*\//}"
echo ""

curl \
	${CURL_RETRY} \
	${SSL_SECURITY_OPTION} \
	--fail \
	--location \
	"${SCRIPT_URL}?raw=true" | \
	bash -

exit 0
