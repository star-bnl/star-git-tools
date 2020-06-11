#!/usr/bin/env bash
#
# This script can be run as a crontab job to sync STAR CVS repository with the
# remote Git repository github.com:star-bnl/star-cvs.git. For example, the
# following command can be added to the crontab:
# 
# 0 2,8,20 * * * CVS_HOST="rcas6010:" /path/to/cvs2git.sh &> /path/to/cvs2git_cron.log
#
# In order to push to the remote server the account running the script must be
# properly set up to authenticate with an SSH key.
#
# For test purposes one can skip the push-to-remote step by providing the DEBUG
# variable set to any value:
#
# DEBUG= /path/to/cvs2git.sh
#

echo -- Start crontab job at
date

# Set default values
: ${SCRIPT_DIR:="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"}
: ${BFG:="java -jar /home/smirnovd/usr/local/bin/bfg-1.13.0.jar"}
: ${CVS_HOST:=""}
: ${CVS_DIR:="${CVS_HOST}/afs/rhic.bnl.gov/star/packages/repository"}
: ${CVS_EXCLUDED_PATHS:="${SCRIPT_DIR}/cvs2git_paths.txt"}
: ${PREFIX:="/scratch/smirnovd/star-bnl-readonly"}
: ${LOCAL_CVS_DIR:="${PREFIX}/star-cvs-local"}
: ${LOCAL_GIT_DIR:="${PREFIX}/star-bnl/star-cvs"}


#
# Create or update a local copy of CVS repository
#
echo
echo -- Step 1. Updating local copy of CVS repository in ${LOCAL_CVS_DIR}

mkdir -p "${LOCAL_CVS_DIR}"
cmd="rsync -a --omit-dir-times --chmod=Dug=rwx,Do=rx,Fug+rw,Fo+r --delete -R ${CVS_DIR}/./CVSROOT ${LOCAL_CVS_DIR}/"
echo
echo ---\> Updating local CVSROOT in ${LOCAL_CVS_DIR}
echo $ $cmd
$cmd

mkdir -p "${LOCAL_CVS_DIR}/cvs"
cmd="rsync -a --omit-dir-times --chmod=Dug=rwx,Do=rx,Fug+rw,Fo+r --delete --delete-excluded --exclude-from=${CVS_EXCLUDED_PATHS} -R ${CVS_DIR}/./ ${LOCAL_CVS_DIR}/cvs"
echo
echo ---\> Updating local CVS modules in ${LOCAL_CVS_DIR}/cvs
echo $ $cmd
$cmd

echo -- Done

echo
echo -- Step 1a. Clean up local copy of CVS repository in ${LOCAL_CVS_DIR}/cvs
rm -fr ${LOCAL_CVS_DIR}/cvs/StarDb/Geometry/tpc/tpcPadPlanes.dev2019.C,v
echo -- Done


#
# Run cvs2git
#
echo
echo -- Step 2. Creating Git blob files from the local CVS repository
cvs2git --fallback-encoding=ascii --use-rcs --co=/usr/local/bin/co --force-keyword-mode=kept \
        --blobfile=${PREFIX}/git-blob.dat \
        --dumpfile=${PREFIX}/git-dump.dat \
        --username=cvs2git ${LOCAL_CVS_DIR}/cvs &> ${PREFIX}/cvs2git_cron_step2.log
echo -- Done


#
# (Re-)create the actual git repository from the blob and dump files created by
# cvs2git then check out the master branch and push everything to github
#
echo
echo -- Step 3. Recreating Git repository in ${LOCAL_GIT_DIR}
rm -fr ${LOCAL_GIT_DIR} && mkdir -p ${LOCAL_GIT_DIR} && cd ${LOCAL_GIT_DIR}
git init
cat ${PREFIX}/git-blob.dat ${PREFIX}/git-dump.dat | git fast-import
${BFG} --delete-folders .git --delete-files .git --no-blob-protection ./
[[ -z ${DEBUG+x} ]] && git remote add origin git@github.com:star-bnl/star-cvs.git \
                    && git push --mirror && git checkout
echo -- Done

echo
echo -- Done with crontab job at
date

exit 0
