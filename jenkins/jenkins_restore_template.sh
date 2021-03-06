#!/bin/bash -e
###
### Script to restore Jenkins data generated by jenkins backup script
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


### Keep environment clean
export LC_ALL="C"
readonly BACKUP_DIR_NAME="$PWD"

### Check if ${JENKINS_HOME} is accessible
if [[ ! -d "${JENKINS_HOME}" ]]; then
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

### Copy to ${JENKINS_HOME}
sudo cp -R ${BACKUP_DIR_NAME}/* ${JENKINS_HOME}
sudo rm ${JENKINS_HOME}/restore.sh || true
sudo rm ${JENKINS_HOME}/*.tar.gz || true
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
