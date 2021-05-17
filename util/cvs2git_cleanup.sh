#!/usr/bin/env bash

: ${SCRIPT_DIR:="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"}
: ${BFG:="java -jar /home/smirnovd/usr/local/bin/bfg-1.13.0.jar"}
: ${GIT_REPO_DIR:="/path/to/local/git/dir"}
: ${TAGS_TO_PROTECT:="SL1* SL2*"}
#: ${TAGS_TO_PROTECT:="SL15* SL16* SL17* SL18*  SL19* SL20*"}

echo SCRIPT_DIR $SCRIPT_DIR

pushd ${GIT_REPO_DIR}
touch ${GIT_REPO_DIR}/blobs_to_keep.txt

# Add "main" branch to the list of protected references
TAGS_TO_PROTECT="main $(git tag -l ${TAGS_TO_PROTECT} | tr '\n' ' ')"
echo "TAGS_TO_PROTECT=$TAGS_TO_PROTECT"

for tag in main ${TAGS_TO_PROTECT}
do
    git ls-tree -r $tag | awk '{print $3}' >> ${GIT_REPO_DIR}/blobs_to_keep.txt
    cat ${GIT_REPO_DIR}/blobs_to_keep.txt | sort | uniq > ${GIT_REPO_DIR}/.blobs_to_keep.txt
    mv ${GIT_REPO_DIR}/.blobs_to_keep.txt ${GIT_REPO_DIR}/blobs_to_keep.txt
done

# All blobs can be saved for inspection
#git rev-list --objects --all \
#| git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
#| sed -n 's/^blob //p' \
#| sort --numeric-sort --key=2 > ${GIT_REPO_DIR}/blobs_all.txt

git rev-list --objects --all \
| git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
| sed -n 's/^blob //p' \
| grep -vF --file=${GIT_REPO_DIR}/blobs_to_keep.txt \
| grep -vF --file=${SCRIPT_DIR}/paths_to_keep.txt \
| awk '$2 >= 200000' \
| sort --numeric-sort --key=2 > ${GIT_REPO_DIR}/blobs_to_delete.txt

cat ${GIT_REPO_DIR}/blobs_to_delete.txt | awk '{print $1}'> ${GIT_REPO_DIR}/blobs_to_delete_sha.txt

${BFG} --delete-folders .git --no-blob-protection --private ${GIT_REPO_DIR}
${BFG} --delete-files .git --no-blob-protection --private ${GIT_REPO_DIR}
${BFG} --delete-files tpcPadGainT0B.*.root --no-blob-protection --private ${GIT_REPO_DIR}
${BFG} --delete-files tpcDriftVelocity.*.C --no-blob-protection --private ${GIT_REPO_DIR}
${BFG} --strip-blobs-with-ids ${SCRIPT_DIR}/blobs_to_delete_manual_sha.txt --no-blob-protection --private ${GIT_REPO_DIR}
${BFG} --strip-blobs-with-ids ${GIT_REPO_DIR}/blobs_to_delete_sha.txt  --no-blob-protection --private ${GIT_REPO_DIR}

# Final clean up
git reflog expire --expire=now --all && git gc --prune=now --aggressive

popd
