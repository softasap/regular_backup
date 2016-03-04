#!/bin/bash -e
###
### Script to restore Jenkins data generated by jenkins_backup.sh script
###
### NOTE:
###   - Requires passwordless sudo
###   - Works on Debian/Ubuntu
###
### Inpired by:
###   https://github.com/sue445/jenkins-backup-script
###

### Display usage

JENKINS_HOME=/var/lib/jenkins

usage() {
 cat << EOF &&
Usage:
  $0 <backup archive>.tgz
EOF

 return
}

### Start the ball
if [[ $# -ne 1 ]]; then
  echo "Wrong number of arguments, provide path to backup"
  usage
  exit 1
fi

readonly BACKUP_FILE="${1}"

### Keep environment clean
export LC_ALL="C"
readonly TMP_DIR="/tmp"
readonly BACKUP_DIR_NAME="jenkins-backup"
trap 'rm -rf ${TMP_DIR}/${BACKUP_DIR_NAME}' EXIT 1 2 3 13 15

### Check if ${JENKINS_HOME} is accessible
if [[ ! -d "${JENKINS_HOME}" ]]; then
  echo "Cannot access ${JENKINS_HOME}, exiting..."
  exit 1
fi

### Check if ${BACKUP_FILE} is accessible
if [[ ! -r "${BACKUP_FILE}" ]]; then
  echo "Cannot access ${JENKINS_HOME}, exiting..."
  exit 1
fi

### Check if we have jenkins user
if [[ ! `id jenkins 2> /dev/null` ]]; then
  echo "User 'jenkins' doesn't exist, please check Jenkins installation."
  exit 1
fi

### Print out what we shall do
echo "Starting Jenkins restore on `hostname -s` at `date +'%d-%b-%Y %H:%M:%S %Z'`"

### Stop Jenkins
echo "Stopping Jenkins service..."
sudo service jenkins stop || echo "Jenkins failed to stop or is not running, it's okay for now."
### Unarchive ${BACKUP_FILE}
echo "Unarchive backup file..."
cd ${TMP_DIR}
tar -zxf ${BACKUP_FILE}
### Copy to ${JENKINS_HOME}
echo "Copy archive contents to ${JENKINS_HOME}..."
sudo cp -R ${BACKUP_DIR_NAME}/* ${JENKINS_HOME}
sudo cp -R ${BACKUP_DIR_NAME}/.ssh ${JENKINS_HOME}/.ssh
### Check if we have jenkins user
echo -n "Change owner and group to 'jenkins'... "
sudo chown jenkins:jenkins -R ${JENKINS_HOME}
echo "done."

### Start Jenkins
echo "Starting Jenkins service..."
sudo service jenkins start

### Done
echo "Finished Jenkins restore on `hostname -s` at `date +'%d-%b-%Y %H:%M:%S %Z'`"
exit 0

### EOF
