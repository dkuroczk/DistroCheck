#!/bin/bash

#this variable will hold the name of the linux distribution
LINUX_DIST=


#checks if user has root privileges
checkIfUserHasRootPrivileges()
{
        #This script needs to be run as a sudo user
        if [[ $EUID -ne 0 ]]; then
           echo  "ERROR" "ERROR: This script must be run as root."
           exit 1
        fi
}

#check if supported operating system
checkIfSupportedOS()
{
        getOs

        LINUX_DIST_IN_LOWER_CASE=$(echo $LINUX_DIST | tr "[:upper:]" "[:lower:]")

        case "$LINUX_DIST_IN_LOWER_CASE" in
                *"ubuntu"* )
                echo "INFO: Operating system is Ubuntu."
                ;;
                *"redhat"* )
                echo "INFO: Operating system is Red Hat."
                ;;
                *"centos"* )
                echo "INFO: Operating system is CentOS."
                ;;
                *"amazon"* )
                echo "INFO: Operating system is Amazon AMI."
                ;;
                *"darwin"* )
                #if the OS is mac then exit
                logMsgToConfigSysLog "ERROR" "ERROR: This script is for Linux systems, and Darwin or Mac OSX are not currently supported. You can find alternative options here: https://www.loggly.com/docs"
                exit 1
                ;;
                * )
                logMsgToConfigSysLog "WARN" "WARN: The linux distribution '$LINUX_DIST' has not been previously tested with Loggly."
                while true; do
                        read -p "Would you like to continue anyway? (yes/no)" yn
                        case $yn in
                                [Yy]* )
                                break;;
                                [Nn]* )
                                exit 1
                                ;;
                                * ) echo "Please answer yes or no.";;
                        esac
                done
                ;;
        esac
}
getOs()
{
        # Determine OS platform
        UNAME=$(uname | tr "[:upper:]" "[:lower:]")
        # If Linux, try to determine specific distribution
        if [ "$UNAME" == "linux" ]; then
                # If available, use LSB to identify distribution
                if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
                        LINUX_DIST=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
                # If system-release is available, then try to identify the name
                elif [ -f /etc/system-release ]; then
                        LINUX_DIST=$(cat /etc/system-release  | cut -f 1 -d  " ")
                # Otherwise, use release info file
                else
                        LINUX_DIST=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
                fi
        fi

        # For everything else (or if above failed), just use generic identifier
        if [ "$LINUX_DIST" == "" ]; then
                LINUX_DIST=$(uname)
        fi
}

echo $LINUX_DIST;
checkIfUserHasRootPrivileges
checkIfSupportedOS
