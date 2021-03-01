#!/usr/bin/env bash
#
# This script can be run as a crontab job to sync STAR CVS repository with the
# remote Git repository github.com:star-bnl/star-sw For example, the
# following command can be added to the crontab:
# 
# 0 2,8,20 * * * CVS_HOST="rcas6010" /path/to/cvs2git.sh &> /path/to/cvs2git_cron.log
#
# In order to push to the remote server the account running the script must be
# properly set up to authenticate with an SSH key.
#
# For test purposes one can skip the push-to-remote step by providing the DEBUG
# variable set to any value:
#
# DEBUG= /path/to/cvs2git.sh
#

echo -- Start job at
date

# Set default values
: ${SCRIPT_DIR:="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"}
: ${GIT_REPO:="star-sw"}
: ${PREFIX:="/scratch/smirnovd/cvs2git_readonly"}
: ${CVS_ROOT_DIR:="${PREFIX}/cvs"}
: ${CVS_REPO_DIR:="${PREFIX}/cvs/${GIT_REPO}"}
: ${GIT_REPO_DIR:="${PREFIX}/${GIT_REPO}"}
: ${CVS_DIR:="${CVS_HOST:+$CVS_HOST:}/afs/rhic/star/packages/repository"}
: ${CVS_EXCLUDED_PATHS:="${SCRIPT_DIR}/cvs2git_paths_${GIT_REPO}.txt"}
: ${CVS2GIT_OPTIONS:="${SCRIPT_DIR}/cvs2git_options.py"}
: ${CVS2GIT_CLEANUP="${SCRIPT_DIR}/cvs2git_cleanup.sh"}
: ${CVS2GIT_TMP_DIR:="${CVS_REPO_DIR}-tmp"}


#
# Create or update a local copy of CVS repository
#
echo
echo -- Step 1: Creating/updating local copy of CVS repository in ${CVS_REPO_DIR}

mkdir -p "${CVS_ROOT_DIR}"
cmd=(rsync -a --omit-dir-times --chmod=Dug=rwx,Do=rx,Fug+rw,Fo+r --delete -R ${CVS_DIR}/./CVSROOT ${CVS_ROOT_DIR}/)
echo
echo ---\> Updating local CVSROOT in ${CVS_ROOT_DIR}
echo "${cmd[@]}"
time "${cmd[@]}"

mkdir -p "${CVS_REPO_DIR}"
cmd=(rsync -a --omit-dir-times --chmod=Dug=rwx,Do=rx,Fug+rw,Fo+r --delete --delete-excluded --filter "merge ${CVS_EXCLUDED_PATHS}" -R ${CVS_DIR}/./ ${CVS_REPO_DIR})
echo
echo ---\> Updating local CVS modules in ${CVS_REPO_DIR}
echo "${cmd[@]}"
time "${cmd[@]}"

echo -- Step 1: Done


#
# Run cvs2git
#
echo
echo -- Step 2: Creating Git blob files from the local CVS repository
CVS2GIT_OPTIONS_TMP=${CVS_REPO_DIR}_options.py
cat ${CVS2GIT_OPTIONS} | sed -e "s|@CVS2GIT_TMP_DIR@|${CVS2GIT_TMP_DIR}|g; s|@CVS_REPO_DIR@|${CVS_REPO_DIR}|g;" > ${CVS2GIT_OPTIONS_TMP}
cmd=(cvs2git --options=${CVS2GIT_OPTIONS_TMP})
echo "${cmd[@]}  &> ${CVS_REPO_DIR}_cvs2git_step2.log"
time "${cmd[@]}" &> ${CVS_REPO_DIR}_cvs2git_step2.log
echo -- Step 2: Done


#
# (Re-)create the actual git repository from the blob and dump files created by
# cvs2git then check out the main branch and push everything to github
#
echo
echo -- Step 3: Recreating Git repository in ${GIT_REPO_DIR}
rm -fr ${GIT_REPO_DIR} && mkdir -p ${GIT_REPO_DIR} && cd ${GIT_REPO_DIR}
git init -b main
time cat ${CVS2GIT_TMP_DIR}/git-blob.dat ${CVS2GIT_TMP_DIR}/git-dump.dat | git fast-import
git branch -m master main
[[ -n "${CVS2GIT_CLEANUP}" ]] && GIT_REPO_DIR="${GIT_REPO_DIR}" ${CVS2GIT_CLEANUP}
[[ -z "${DEBUG+x}" ]] && git remote add origin git@github.com:star-bnl/${GIT_REPO}.git \
                      && git push --mirror && git checkout
echo -- Step 3: Done

echo
echo -- Done with job at
date

exit 0
