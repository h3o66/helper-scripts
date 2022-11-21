#!/bin/bash
destdir="/var/www/repo/nobara"
repopath="${destdir}/repo"

logfile="/var/log/nobara_sync_mirror.log"

releases=(36)
repos=(fedora nobara)
basearch="x86_64"
repoidlist=(nobara-obs-studio nobara-custom)
repoid=0
localpath=('fedora/$releasever/$basearch/obs-studio-nobara/' 'nobara/$releasever/$basearch/')

function logger() {
	echo "[ $(date +"%F %T") ] $@" >> "${logfile}"
}

logger "Start repo sync"
for lpath in ${localpath[@]}; do
	repoidname="${repoidlist[${repoid}]}"
	for releasever in ${releases[@]}; do
		downloadpath="$(eval echo "${repopath}/${lpath}")"
		mkdir -p "${downloadpath}"
		dnf reposync --refresh --delete --download-metadata --remote-time --norepopath --repoid=${repoidname} --releasever ${releasever} -p "${downloadpath}" &>> "${logfile}"
	done
	repoid+=1
done
logger "End repo sync"

chown -R nginx:nginx "${destdir}"
