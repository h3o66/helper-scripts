#!/bin/bash
basepath="/var/www/repo/nobara/iso"
downloadlog="/var/log/nobara_iso_download.log"
dlfilelist="/tmp/nobara_iso_filelist.tmp"

ariaconn=4
checksumt="sha-256"
checksumft=".sha256"

webuser="nginx"
webgroup="nginx"

if [ -f "${dlfilelist}" ]; then
	rm -f "${dlfilelist}"
fi

cd "${basepath}"
for url in $(curl -s "https://nobaraproject.org/download-nobara/" | egrep -o "https://nobaraproject.org/.*.iso\"" | sed 's/"$//g')
do
	filename=$(basename "${url}")
	echo "${filename}" >> "${dlfilelist}"
	checksumurl="${url}.sha256sum"
	checksumfile="${filename}.sha256sum"
	checksumres="${filename}.result"
	# delete checksum file if it exists
	if [ -f "${checksumfile}" ]; then
		rm -f "${checksumfile}"
	fi
	# download checksum file
	wget -N -c -a "${downloadlog}" "${checksumurl}"
	# get checksum from file
	checksum=$(awk '{print $1}' "${checksumfile}")
	# download file with aria2c
	aria2c --quiet=true --remote-time=true --conditional-get=true -j ${ariaconn} --log-level=notice -l "${downloadlog}" --checksum=${checksumt}=${checksum} "${url}"
	# old download by wget
	#wget -N -c -a "${downloadlog}" "${url}"
	# download checksum file
#	wget -N -c -a "${downloadlog}" "${checksumurl}"
	if [ ! -f "${checksumres}" ]; then
		# check for file integrity
		sha256sum -c "${checksumfile}" &> "${checksumres}"
	fi
done

# fix folder permissions
chown -R "${webuser}:${webgroup}" "${basepath}"
