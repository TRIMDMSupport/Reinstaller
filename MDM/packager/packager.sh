#!/bin/sh

pkgname="$1"
pkgid="$2"
pkgvers="$3"
directory="$4"
scriptfile="${directory}/MT_Intune_Reinstall_${pkgname}.sh"

pkgname="${pkgname}_Reinstaller"

loggedInUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

rm -rf "/tmp/${pkgname}"
rm -rf "/Users/${loggedInUser}/Downloads/${pkgname}.pkg"
mkdir "/tmp/${pkgname}"
mkdir "/tmp/${pkgname}/scripts"
mkdir "/tmp/${pkgname}/nopayload"

cp $scriptfile "/tmp/${pkgname}/scripts/postinstall"

#Set the postinstall script to be executable
	
chmod a+x "/tmp/${pkgname}/scripts/postinstall"

#Build the payload-free package
	
pkgbuild --identifier "${pkgid}" --version "${pkgvers}" --root "/tmp/${pkgname}/nopayload" --scripts "/tmp/${pkgname}/scripts" "/tmp/${pkgname}/${pkgname}.pkg"
	
cp /tmp/${pkgname}/${pkgname}.pkg ~/Downloads
chmod 777 "/Users/${loggedInUser}/Downloads/${pkgname}.pkg"