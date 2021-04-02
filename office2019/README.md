# LAMC Office 2019 VM Installer

This script is designed to enable automated deployment of virtual machine appliances to students' computers. The script downloads the .ova appliance file, imports it into VirtualBox with recommended parameters, creates a shared folder on the Desktop, and creates an initial snapshot of the newly-imported .ova file. 

## Pre-Requisites
* VirtualBox must be installed on your system.
    * [Download latest VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* __Processor__: x86_64-bit compatible CPU (2021 Apple M1 laptops are currently not supported by VirtualBox)
* __Operating System__: MacOS or Linux. 
* __Storage__: 35GB minimum free disk space. 50GB Recommended.
* __RAM__: Minimum of 8GB total system RAM 


## Instructions
1) Make sure you already have VirtualBox installed on your system. If you don't have VirtualBox installed you can find download link above as first step in Pre-Requisites.

2) Open Terminal app. On Mac: Press Command+Space, type in "Terminal" and press Enter.

3) Copy the following line, Paste(Command+V) it into the Terminal window and hit Enter:
> bash <(curl -s https://github.com/mit-gukasos/csit-student-vms/office2019/import-vm.sh)


At this point the download should start. The process can take some time, depending on your Internet connection and hardware. Make sure to keep your device from going to sleep, as this can interrupt the download process and cause errors during import. 

At the end of import process you will be asked if you want to keep or remove the .ova file. You don't need to keep .ova for the VM to function, and you can chose to remove it in order to save 9GB of your storage. If you have slow internet connection you may want to keep the file handy in case you run into any issues with VM and need to re-deploy it. 

When import process finishes VirtualBox window will open. At this point you can close Terminal and start using your VM.

On the desktop of your Mac/Linux computer you will find a folder with the same name as the virtual machine. This is a shared folder. Files inside shared folder can be transfered between your virtual and physical machines.

## FAQ

### I did something and now my virtual machine is broken! How do I recover?

After successful import process, the script takes a snapshot of a virtual machine. You can use this snapshot to "go back in time" to the original state of the virtual machine. [How to create and restore from a snapshot in VirtualBox 6](https://youtu.be/KoDCXwF5cYM?t=53) [2:27]

### I did something and now the whole VM is broken, and snapshots cannot fix it! What can I do?

If you break the VM to a point where snapshots can not fix it, you must delete problematic VM from virtualbox, and follow the guide from the begining to re-import the appliance from scratch. Re-run the command from Instructions section.

### I do not like the default VM import settings. Can I still change them after importing?

Yes. In VirtualBox, on the left hand panel, right click on the virtual machine -> **Settings**. You will find all the settings (and more) there.


### Further help

If you are having issues, or have questions beyond what's covered in this guide, feel free to contact me via email gukasos@lamission.edu
