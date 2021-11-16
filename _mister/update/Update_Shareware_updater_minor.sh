#!/bin/bash
set -e
ver="v.20.3"

# ======== BEGIN USER OPTIONS ========

# Specifies the Games/Programs subdirectory where core specific directories will be placed.
# SHAREWAREDIR="" for letting the script choose between /media/fat and /media/fat/games when it exists,
# otherwise the subdir you prefer (i.e. SHAREWAREDIR="/Programs").
SHAREWAREDIR=""

# Base directory for all script’s tasks, "/media/fat" for SD root, "/media/usb0" for USB drive root.
BASE_PATH="/media/fat"

# Overwrite user variables with values from optional ini file
source_ini()
{
	original_script_path="$0"
	if [ $original_script_path == "bash" ]
	then
		original_script_path=$(ps | grep "^ *$PPID " | grep -o "[^ ]*$")
	fi
	ini_path=${original_script_path%.*}.ini
	if [[ -f "${ini_path}" ]] ; then
		tmp=$(mktemp)
		dos2unix < "${ini_path}" 2> /dev/null | grep -v "^exit" > ${tmp} || true
		set +u
		source ${tmp}
		set -u
		rm -f ${tmp}
	fi
}
source_ini

# ========= END USER OPTIONS =========


#main repo and disk image name
github_repo="flynnsbit/DOS_Shareware_MyMenu"
primary_disk_image="Shareware Pack-fbit.vhd"

#main repo temp locations for sync changes into VHD
mount_dir=/tmp/shareware_vhd
extract_dir=/tmp/dos_extract

#3rd party addons repos
fastdoom_repo="viti95/FastDoom"
wolfmidi_repo="ericvids/wolfmidi"
#wolfdosmpu_repo="ericvids/wolfdosmpu"

#3rd party zip extraction temp locations used to sync changes into VHD
fastdoom_dir=/tmp/fastdoom
wolfmidi_dir=/tmp/wolfmidi
#wolfdosmpu_dir=/tmp/wolfdosmpu

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

# Arg $1: GitHub repo name, e.g. "username/repo"
# Can we grab the file names and insert them into a variable ex. FastDoom_0.7.zip so it is not hard coded in the execution part below
get_latest_release()
{
	local api_url="https://api.github.com/repos/${1}/releases/latest"
	local download_url

	read -r tag_name download_url < <(echo $(curl -k -s "${api_url}" | jq -r ".tag_name, .assets[0].browser_download_url"))
	echo Downloading "${tag_name}"...
	cd /tmp && { curl -k -L "${download_url}" -O ; cd -; }
}

# Arg $1: Path to image
# Arg $2: Partition number 
# Arg $3: Mount point

mount_pimage()
{
	# Get next free loop device
	loop_dev_p=$(losetup -f)

	# Associate next free loop device with image
	losetup -f "${1}"

	# Mount the partition
	mount "${loop_dev_p}p${2}" "${3}"
}



# Arg $1: Primary Mount point
unmount_pimage()
{
	loop_dev_p=$(losetup -a | awk -F: -v IMG="${1}" '{gsub(/^[\t ]+[0-9]+[\t ]+/,"",$2); if($2 == IMG) { print $1; }}')

	# Unmount partition
	sync
	umount "${2}"
	
	# Disassociate loop device
	if [ ! -z "$loop_dev_p" -a "$loop_dev_p" != " " ]; then
		losetup -d "${loop_dev_p}"
	fi
}


find_primary_disk_image()
{
	# Similar logic to MiSTer update.sh script
	ao486_dir="${SHAREWAREDIR}/AO486"
	if [ "${SHAREWAREDIR}" == "" ]; then
		if [ "$(find ${BASE_PATH}/games -type f -print -quit 2> /dev/null)" == "" ] && [ "$(find ${BASE_PATH}/AO486 -type f -print -quit 2> /dev/null)" != "" ]; then
			ao486_dir="${BASE_PATH}/AO486"
		else
			ao486_dir="${BASE_PATH}/games/AO486"
		fi
	fi

	primary_disk_image="${ao486_dir}/${primary_disk_image}"
	
	if [ ! -f "${primary_disk_image}" ]; then
		echo "Couldn't find disk image: \"${primary_disk_image}\"."
		exit 1
	fi
}

# Look for disk image in user's games directory
find_primary_disk_image
echo ""
echo -e "${white}Disk image found at \"${primary_disk_image}\".${reset}"
echo ""

#Cleaning up any bad updates or failed updates before running again
echo -en "\ec"
echo ""
echo -e "${blue}Cleaning up any previous failed updates, ignore any errors...${reset}"
echo ""
#get rid of this hacky cleanup or dont show users the error when the command could not complete
set +e
rm /tmp/minor.zip 2>/dev/null
unmount_pimage "${primary_disk_image}" "${mount_dir}/C" 2>/dev/null
rm -r "${mount_dir}" 2>/dev/null
rm -r "${extract_dir}" 2>/dev/null

set -e

# Download latest release zip
get_latest_release "${fastdoom_repo}"
get_latest_release "${github_repo}"
#get_latest_release "${wolfdosmpu_repo}"
#get_latest_release "{wolfmidi_repo}"

# Mount partition 2 for secondary and 1 for primary in the disk image for C and E
mkdir "${mount_dir}"
mkdir "${extract_dir}"
mkdir "${mount_dir}/C"
echo "${primary_disk_image}"
mount_pimage "${primary_disk_image}" 1 "${mount_dir}/C"
echo ""

# Extract updates from repos, rsync files to both vhds
unzip -o /tmp/minor.zip -d "${extract_dir}/"
unzip -o "/tmp/FastDoom*.zip" -d "${fastdoom_dir}/"
#unzip -o "/tmp/wolfmidi*.zip" -d "${wolfmidi_dir}/"
#unzip -o "/tmp/wolfdosmpu*.zip" -d "${wolfdosmpu_dir}/"

#Rsync 3rd party game mods
rsync '/tmp/fastdoom/' /tmp/shareware_vhd/C/GAMES/DOOM/  -r -I -v
#rsync '/tmp/wolfmidi/' /tmp/shareware_vhd/C/GAMES/Wolfenstein\ 3d//  -r -I -v
#rsync '/tmp/wolfdosmpu/' /tmp/shareware_vhd/C/GAMES/Wolfenstein\ 3d/  -r -I -v


#Rsync all the updates to the VHDs that are mounted
rsync -crv "${extract_dir}"/ "${mount_dir}/C" 
echo ""

# Clean up everything
rm /tmp/minor.zip
rm /tmp/FastDoom*.zip
#rm /tmp/wolfmidi*.zip
#rm /tmp/S*.EXE
#rm /tmp/W*.EXE

#sync VHD and unmount
sync
unmount_pimage "${primary_disk_image}" "${mount_dir}/C"

rm -r "${mount_dir}"
rm -r "${extract_dir}"
rm -r "${fastdoom_dir}"
#rm -r "${wolfmidi}"
#rm -r "${wolfdosmpu}"

echo ""
echo -e "${green}Successfully updated to ${tag_name}!${reset}"
