#!/bin/bash
clear

# import-vm.sh
#
# COMPATIBILITY: OSX(x86_64) & Linux
# REQUIREMENTS: VirtualBox installation, 30GB free disk spacess
# PURPOSE: Downloads, imports, and configures a VirtualBox .ova virtual machine appliance.
#          Sets the appliance to utilize 1/2 of CPU threads, and 1/3 of total RAM, and creates 
#          initial snapshot after import. For the download to work, .ova file must be hosted on
#          HTTP(S) or (S)FTP protocol. 
#

### USER EDITABLE VARIABLES ##########################
guest_name="LAMC-OFFICE2019-VM"                             # Name of VM to be shown in VirtualBox
ova_remote_url="https://academic.lamission.edu/csw10/$guest_name.ova"         # HTTP or FTP url to .ova file
ova_local="$(echo ~/Downloads/)$guest_name.ova"             # Download path for .ova file
#### END OF USER EDITABLE VARIABLES ##################

function display_error_and_exit () {
    echo "[ Error ] "$@""
    exit 1
}

declare host_thread_count=""
declare host_mem_kb="" 
declare vbox_download_url=""
declare open_url_cmd=""
if [ $(uname) = "Darwin" ]; then # OSX
    if [ $(uname -m) = "arm64" ]; then error_and_exit "At this moment some 2020+ models of Macs (with M1 CPUs) are not supported."; fi
    vbox_download_url="https://download.virtualbox.org/virtualbox/6.1.18/VirtualBox-6.1.18-142142-OSX.dmg"
    open_url_cmd="open"
    host_thread_count=$(sysctl -n hw.logicalcpu)
    host_mem_kb=$(expr $(sysctl -n hw.memsize) / 1000)
elif [ $(uname) = "Linux" -a $(uname -m) = "x86_64" ]; then # Linux
    vbox_download_url="https://www.virtualbox.org/wiki/Linux_Downloads"
    open_url_cmd="xdg-open"
    host_thread_count=$(nproc --all)
    host_mem_kb=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
else 
    display_error_and_exit "Not supported OS $(uname) or architecture $(uname -m)."
fi

if [ -z $(which vboxmanage) ]; then 
    if [ -z $(open_url_cmd) ]; then
        read -p "VirtualBox installation not found on this computer. Would you like to download VirtualBox now? [y/n]: " -r 
        if [[ $REPLY =~ ^[Yy]$ ]]; then $(echo "$open_url_cmd $vbox_download_url"); fi
    fi 

    errormessage="Install VirtualBox and run this script again.\n"
    errormessage+=$vbox_download_url
    display_error_and_exit $errormessage
fi

echo "[ 1/5 ] Checking downloads folder..."
if [ ! -a $ova_local ]
then 
    echo "Downloading $ova_local, please wait..."
    curl $ova_remote_url -o $ova_local;
else
    read -p "$ova_local already exists. Would you like to download again? [y/n]: " 
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then 
        rm $ova_local 
        echo "Downloading $ova_local, please wait..."
        curl $ova_remote_url -o $ova_local; 
    fi
fi


echo 
echo "[ 2/5 ] Importing and configuring $guest_name in Virtual Box..."

guest_cpu_count=$(expr $host_thread_count / 2)    # Use half of available system threads
guest_mem_mb=$(expr $host_mem_kb / 1000)          # Convert KB to MB
guest_mem_mb=$(expr $guest_mem_mb / 3)            # Use 1/3 system RAM

vboxmanage import $ova_local --vsys 0 \
                             --vmname $guest_name \
                             --eula accept \
                             --cpus $guest_cpu_count \
                             --memory $guest_mem_mb
vbmExitCode=$?
if [ $vbmExitCode -eq 1 ]; then
    echo "Error importing VM. VBoxManage Exit code $vbmExitCode"
    exit 1
fi

echo
shared_folder_host="$(echo ~/Desktop/)$guest_name-Share"
echo "[ 3/5 ] Configuring a shared folder $shared_folder_host"
message="This folder can be accessed as a 'Network Drive' on a VM by opening Explorer and going to 'Computer'\n"
message+="Use this folder to transfer files across your computer and VM."

echo $message
if [ ! -d $shared_folder_host ]; then mkdir $shared_folder_host; echo $message > $shared_folder_host/readme.txt; fi

vboxmanage sharedfolder add $guest_name --name "$guest_name-Share" --hostpath $shared_folder_host --automount

echo
snapshot_name="Initial"
echo "[ 4/5 ] Import successful. Taking '"$snapshot_name"' VM snapshot... "

sbao_description='This snapshot will revert the VM to its initial "factory settings".'
sbao_description+='Revert to this snapshot if you are experiencing issues with your VM.'
sbao_description+='All data saved on the VM (except contents of Shared Folder) will be lost.'
sbao_description+='https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/snapshots.html'
vboxmanage snapshot $guest_name take $snapshot_name --description="$sbao_description"

if [ $vbmExitCode -eq 1 ]; then
    echo "Error creating a snapshot. Please try creating a snapshot manually."
    echo "https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/snapshots.html"
fi

echo
echo "[ 5/5 ] Cleanup..."

echo "Would you like to delete $ova_local? It is not required for VM to function, but can be re-imported to restore VM in case snapshots fail."
echo "$guest_name.ova can be re-downloaded by running this script again."
read -r -p "Delete? [y/n]: " 
if [[ $REPLY =~ ^[Yy]$ ]]; then rm $(echo $ova_local); fi

echo "Starting Virtual Box..."
virtualbox > /dev/null 2>&1 &

exit 0