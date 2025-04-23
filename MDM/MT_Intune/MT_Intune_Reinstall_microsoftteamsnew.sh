#!/bin/sh

# Uninstallation using MacUninstaller with Dialog showing end of process

item="microsoftteamsnew" # enter the software to uninstall
# Examples: adobecreativeclouddesktop, canva, cyberduck, handbrake, inkscape, textmate, vlc

# Installation using Installomator with Dialog showing progress (and posibility of adding to the Dock)

LOGO="microsoft" # "mosyleb", "mosylem", "addigy", "microsoft", "ws1", "kandji", "filewave"

# Dialog icon
icon="https://banner2.cleanpng.com/20190506/rpw/kisspng-microsoft-teams-office-365-microsoft-office-micros-1713893207119.webp"
# icon should be a file system path or an URL to an online PNG, so beginning with either “/” or “http”.
# In Mosyle an URL can be found by copy picture address from a Custom Command icon.

# dockutil variables
addToDock="0" # with dockutil after installation (0 if not)
appPath="/Applications/Microsoft Teams.app"


# PATH declaration
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

#put reinstalled satus file or exit
Reinstalled_file="/usr/local/Installomator/reinstalled/${item}"
if [ -e "$Reinstalled_file" ]; then 
    echo "Már lefutott 1 alkalommal az újratelepítő, így kilépek"
    exit
else
    mkdir -p "/usr/local/Installomator/reinstalled"
    touch $Reinstalled_file
    echo  $icon > "$Reinstalled_file"
fi

getCustomMacUninstaller () {
    # Ensure the target directory exists
    mkdir -p /usr/local/Installomator

    if ! curl -L -# --show-error 'https://github.com/TRIMDMSupport/uninstaller/releases/latest/download/uninstaller.sh' -o '/usr/local/Installomator/uninstaller.sh' ; then
            echo "ERROR: Cannot download uninstaller script."
    else
        chmod 755 /usr/local/Installomator/uninstaller.sh
    fi
}

# Check the currently logged in user
currentUser=$(stat -f "%Su" /dev/console)
if [ -z "$currentUser" ] || [ "$currentUser" = "loginwindow" ] || [ "$currentUser" = "_mbsetupuser" ] || [ "$currentUser" = "root" ]; then
    echo "ERROR. Logged in user is $currentUser! Cannot proceed."
    exit 97
fi

# Get the current user's UID for dockutil
uid=$(id -u "$currentUser")
# Find the home folder of the user
userHome="$(dscl . -read /users/${currentUser} NFSHomeDirectory | awk '{print $2}')"

# Download custom version of uninstaller.sh
getCustomMacUninstaller

# Verify that MacUninstaller has been installed
destFile="/usr/local/Installomator/uninstaller.sh"
if [ ! -e "${destFile}" ]; then
    echo "Uninstaller not found here:"
    echo "${destFile}"
    echo "Exiting."
    exit 99
fi

# No sleeping
/usr/bin/caffeinate -d -i -m -u &
caffeinatepid=$!
caffexit () {
    kill "$caffeinatepid"
    exit $1
}

# Uninstall software using MacUninstaller
cmdOutput="$(${destFile} ${item} || true)"









# Other variables
dialog_command_file="/var/tmp/dialog.log"
dialogApp="/Library/Application Support/Dialog/Dialog.app"
dockutil="/usr/local/bin/dockutil"

installomatorOptions="LOGGING=REQ BLOCKING_PROCESS_ACTION=prompt_user_loop DIALOG_CMD_FILE=${dialog_command_file}" # Separated by space

# Other installomatorOptions:
#   LOGGING=REQ
#   LOGGING=DEBUG
#   LOGGING=WARN
#   BLOCKING_PROCESS_ACTION=ignore
#   BLOCKING_PROCESS_ACTION=tell_user
#   BLOCKING_PROCESS_ACTION=tell_user_then_quit
#   BLOCKING_PROCESS_ACTION=prompt_user
#   BLOCKING_PROCESS_ACTION=prompt_user_loop
#   BLOCKING_PROCESS_ACTION=prompt_user_then_kill
#   BLOCKING_PROCESS_ACTION=quit
#   BLOCKING_PROCESS_ACTION=kill
#   IGNORE_APP_STORE_APPS=yes
#   INSTALL=force
######################################################################
# To be used as a script sent out from a MDM.
# Fill the variable "item" above with a label.
# Script will run this label through Installomator.
######################################################################
# v. 10.0.5 : Support for FileWave, and previously Kandji
# v. 10.0.4 : Fix for LOGO_PATH for ws1, and only kill the caffeinate process we create
# v. 10.0.3 : A bit more logging on succes, and change in ending Dialog part.
# v. 10.0.2 : Improved icon checks and failovers
# v. 10.0.1 : Improved appIcon handling. Can add the app to Dock using dockutil
# v. 10.0   : Integration with Dialog and Installomator v. 10
# v.  9.2.1 : Better logging handling and installomatorOptions fix.
######################################################################

# Mark: Script
# PATH declaration
#export PATH=/usr/bin:/bin:/usr/sbin:/sbin

#put installed satus file or exit
#Installed_file="/usr/local/Installomator/installed/${item}"
#if [ -e "$Installed_file" ]; then 
#    echo "Már lefutott 1 alkalommal a telepítő, így kilépek"
#    exit 1
#else
#    mkdir -p "/usr/local/Installomator/installed"
#    touch $Installed_file
#    echo  $icon > "$Installed_file"
#fi

#forget uninstall pkg
#sudo pkgutil --forget "com.github.payload_free.${item}.uninstall"

#check running other Installomator script.
#PID_FILE="/tmp/Intune_Installomator_script.pid" 

#if [ -e "$PID_FILE" ]; then 
#    PID=$(cat "$PID_FILE") 
#    while ps -ef | grep $PID | grep -v grep | grep -v ps; do 
#        echo "Other Installomator script is already running. Waiting 5 sec" 
#        sleep 5
#    done
#    rm "$PID_FILE"
#fi 


#echo $$ > "$PID_FILE" 

echo "$(date +%F\ %T) [LOG-BEGIN] $item"

dialogUpdate() {
    # $1: dialog command
    local dcommand="$1"

    if [[ -n $dialog_command_file ]]; then
        echo "$dcommand" >> "$dialog_command_file"
        echo "Dialog: $dcommand"
    fi
}
checkCmdOutput () {
    local checkOutput="$1"
    exitStatus="$( echo "${checkOutput}" | grep --binary-files=text -i "exit" | tail -1 | sed -E 's/.*exit code ([0-9]).*/\1/g' || true )"
    if [[ ${exitStatus} -eq 0 ]] ; then
        echo "${item} succesfully installed."
        selectedOutput="$( echo "${checkOutput}" | grep --binary-files=text -E ": (REQ|ERROR|WARN)" || true )"
        echo "$selectedOutput"
    else
        echo "ERROR installing ${item}. Exit code ${exitStatus}"
        echo "$checkOutput"
        #errorOutput="$( echo "${checkOutput}" | grep --binary-files=text -i "error" || true )"
        #echo "$errorOutput"
    fi
    #echo "$checkOutput"
}
getCustomInstallomator () {
    # Ensure the target directory exists
    mkdir -p /usr/local/Installomator

    if ! curl -L -# --show-error 'https://github.com/TRIMDMSupport/InstallomatorMT/releases/latest/download/Installomator.sh' -o '/usr/local/Installomator/Installomator.sh' ; then
            echo "ERROR: Cannot download Installomator script."
    else
        chmod 755 /usr/local/Installomator/Installomator.sh
    fi
}

# Check the currently logged in user
currentUser=$(stat -f "%Su" /dev/console)
if [ -z "$currentUser" ] || [ "$currentUser" = "loginwindow" ] || [ "$currentUser" = "_mbsetupuser" ] || [ "$currentUser" = "root" ]; then
    echo "ERROR. Logged in user is $currentUser! Cannot proceed."
    exit 97
fi
# Get the current user's UID for dockutil
uid=$(id -u "$currentUser")
# Find the home folder of the user
userHome="$(dscl . -read /users/${currentUser} NFSHomeDirectory | awk '{print $2}')"

# Download custom version of Installomator.sh
getCustomInstallomator

# Verify that Installomator has been installed
destFile="/usr/local/Installomator/Installomator.sh"
if [ ! -e "${destFile}" ]; then
    echo "Installomator not found here:"
    echo "${destFile}"
    echo "Exiting."
    exit 99
fi

# Check if new version of label is available
output=$("$destFile" "$item" "LOGGING=INFO" "CHECK_VERSION=1")

if echo "$output" | grep -q "no newer version"; then
    echo "No newer version."
    exit $1
fi

installomatorOptions="LOGGING=DEBUG BLOCKING_PROCESS_ACTION=prompt_user_loop DIALOG_CMD_FILE=${dialog_command_file}" # Separated by space

# Mark: Installation begins
installomatorVersion="$(${destFile} version | cut -d "." -f1 || true)"

if [[ $installomatorVersion -lt 10 ]] || [[ $(sw_vers -buildVersion | cut -c1-2) -lt 20 ]]; then
    echo "Skipping swiftDialog UI, using notifications."
    #echo "Installomator should be at least version 10 to support swiftDialog. Installed version $installomatorVersion."
    #echo "And macOS 11 Big Sur (build 20A) is required for swiftDialog. Installed build $(sw_vers -buildVersion)."
    installomatorNotify="NOTIFY=all"
else
    installomatorNotify="NOTIFY=silent"
    # check for Swift Dialog
    if [[ ! -d $dialogApp ]]; then
        echo "Cannot find dialog at $dialogApp"
        # Install using Installlomator
        cmdOutput="$(${destFile} dialog LOGO=$LOGO BLOCKING_PROCESS_ACTION=ignore LOGGING=REQ NOTIFY=silent || true)"
        checkCmdOutput "${cmdOutput}"
    fi

    # Configure and display swiftDialog
    itemName=$( ${destFile} ${item} RETURN_LABEL_NAME=1 LOGGING=REQ INSTALL=force | tail -1 || true )
    if [[ "$itemName" != "#" ]]; then
        message="Installing ${itemName}…"
    else
        message="Installing ${item}…"
    fi
    echo "$item $itemName"

    #Check icon (expecting beginning with “http” to be web-link and “/” to be disk file)
    #echo "icon before check: $icon"
    if [[ "$(echo ${icon} | grep -iE "^(http|ftp).*")" != ""  ]]; then
        #echo "icon looks to be web-link"
        if ! curl -sfL --output /dev/null -r 0-0 "${icon}" ; then
            echo "ERROR: Cannot download ${icon} link. Reset icon."
            icon=""
        fi
    elif [[ "$(echo ${icon} | grep -iE "^\/.*")" != "" ]]; then
        #echo "icon looks to be a file"
        if [[ ! -a "${icon}" ]]; then
            echo "ERROR: Cannot find icon file ${icon}. Reset icon."
            icon=""
        fi
    else
        echo "ERROR: Cannot figure out icon ${icon}. Reset icon."
        icon=""
    fi
    #echo "icon after first check: $icon"
    # If no icon defined we are trying to search for installed app icon
    if [[ "$icon" == "" ]]; then
        appPath=$(mdfind "kind:application AND name:$itemName" | head -1 || true)
        appIcon=$(defaults read "${appPath}/Contents/Info.plist" CFBundleIconFile || true)
        if [[ "$(echo "$appIcon" | grep -io ".icns")" == "" ]]; then
            appIcon="${appIcon}.icns"
        fi
        icon="${appPath}/Contents/Resources/${appIcon}"
        #echo "Icon before file check: ${icon}"
        if [ ! -f "${icon}" ]; then
            # Using LOGO variable to show logo in swiftDialog
            case $LOGO in
                appstore)
                    # Apple App Store on Mac
                    if [[ $(sw_vers -buildVersion) > "19" ]]; then
                        LOGO_PATH="/System/Applications/App Store.app/Contents/Resources/AppIcon.icns"
                    else
                        LOGO_PATH="/Applications/App Store.app/Contents/Resources/AppIcon.icns"
                    fi
                    ;;
                jamf)
                    # Jamf Pro
                    LOGO_PATH="/Library/Application Support/JAMF/Jamf.app/Contents/Resources/AppIcon.icns"
                    ;;
                mosyleb)
                    # Mosyle Business
                    LOGO_PATH="/Applications/Self-Service.app/Contents/Resources/AppIcon.icns"
                    ;;
                mosylem)
                    # Mosyle Manager (education)
                    LOGO_PATH="/Applications/Manager.app/Contents/Resources/AppIcon.icns"
                    ;;
                addigy)
                    # Addigy
                    LOGO_PATH="/Library/Addigy/macmanage/MacManage.app/Contents/Resources/atom.icns"
                    ;;
                microsoft)
                    # Microsoft Endpoint Manager (Intune)
                    LOGO_PATH="/Library/Intune/Microsoft Intune Agent.app/Contents/Resources/AppIcon.icns"
                    ;;
                ws1)
                    # Workspace ONE (AirWatch)
                    LOGO_PATH="/Applications/Workspace ONE Intelligent Hub.app/Contents/Resources/AppIcon.icns"
                    ;;
                kandji)
                    # Kandji
                    LOGO="/Applications/Kandji Self Service.app/Contents/Resources/AppIcon.icns"
                    ;;
                filewave)
                    # FileWave
                    LOGO="/usr/local/sbin/FileWave.app/Contents/Resources/fwGUI.app/Contents/Resources/kiosk.icns"
                    ;;
            esac
            if [[ ! -a "${LOGO_PATH}" ]]; then
                printlog "ERROR in LOGO_PATH '${LOGO_PATH}', setting Mac App Store."
                if [[ $(/usr/bin/sw_vers -buildVersion) > "19" ]]; then
                    LOGO_PATH="/System/Applications/App Store.app/Contents/Resources/AppIcon.icns"
                else
                    LOGO_PATH="/Applications/App Store.app/Contents/Resources/AppIcon.icns"
                fi
            fi
            icon="${LOGO_PATH}"
        fi
    fi
    echo "LOGO: $LOGO"
    echo "icon: ${icon}"

    # display first screen
    open -a "$dialogApp" --args \
        --title none \
        --icon "$icon" \
        --message "$message" \
        --ontop \
        --progress 100 \
        --position bottomright \
        --mini \
        --commandfile "$dialog_command_file"

    # give everything a moment to catch up
    sleep 0.1
fi

# Install software using Installomator
cmdOutput="$(${destFile} ${item} LOGO=$LOGO ${installomatorOptions} ${installomatorNotify} || true)"
checkCmdOutput "${cmdOutput}"

# Mark: dockutil stuff
if [[ $addToDock -eq 1 ]]; then
    dialogUpdate "progresstext: Adding to Dock"
    if [[ ! -d $dockutil ]]; then
        echo "Cannot find dockutil at $dockutil, trying installation"
        # Install using Installlomator
        cmdOutput="$(${destFile} dockutil LOGO=$LOGO BLOCKING_PROCESS_ACTION=ignore LOGGING=REQ NOTIFY=silent || true)"
        checkCmdOutput "${cmdOutput}"
    fi
    echo "Adding to Dock"
    $dockutil  --add "${appPath}" "${userHome}/Library/Preferences/com.apple.dock.plist" || true
    sleep 1
else
    echo "Not adding to Dock."
fi

# Mark: Ending
if [[ $installomatorVersion -ge 10 && $(sw_vers -buildVersion | cut -c1-2) -ge 20 ]]; then
    # close and quit dialog
    dialogUpdate "progress: complete"
    dialogUpdate "progresstext: Done"

    # pause a moment
    sleep 0.5

    dialogUpdate "quit:"

    # let everything catch up
    sleep 0.5

    # just to be safe
    #killall "Dialog" 2>/dev/null || true
fi

echo "[$(DATE)][LOG-END]"

caffexit $exitStatus