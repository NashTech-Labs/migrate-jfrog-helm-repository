#!/bin/bash

set -e
ARTIFACTORY_URL=""
ARTIFACTORY_PATH=""
USERNAME=""
PASSWORD=""
HELM_PACKAGE_LOCATION="/tmp/helm_charts"
NEW_ARTIFACTORY_PATH=""

# Download existing helm charts repository
curl -o helm_repo.zip -u${USERNAME}:${PASSWORD} \
${ARTIFACTORY_URL}/api/archive/download/${ARTIFACTORY_PATH}?archiveType=zip

if [ ! -d ${HELM_PACKAGE_LOCATION} ] ; then
    mkdir ${HELM_PACKAGE_LOCATION} #To store helm charts packages
fi

# Unzip the existing helm repo charts
unzip helm_repo.zip -d ${HELM_PACKAGE_LOCATION}

for file in $HELM_PACKAGE_LOCATION/*; do
    if [[ $file == *.tgz ]] ; then
        PACKAGE_NAME=$(basename $file)

        # calculate checksums
        sha256=$(openssl dgst -sha256 ${file}|sed 's/^SHA256.*= //')
        sha1=$(openssl dgst -sha1 ${file}|sed 's/^SHA.*= //')
        md5=$(openssl dgst -md5 ${file}|sed 's/^MD5.*= //')

        # Upload Chart
        curl -u${USERNAME}:${PASSWORD} \
        -T ${file} \
        -H "X-Checksum-Sha256:${sha256}" -H "X-Checksum-Sha1:${sha1}" -H "X-Checksum-md5:${md5}"\
        "${ARTIFACTORY_URL}/${NEW_ARTIFACTORY_PATH}/${PACKAGE_NAME}"

    elif [[ $file == *.yaml ]] ; then
        INDEX_FILE=$(basename $file)

        # calculate checksums
        sha256=$(openssl dgst -sha256 ${file}|sed 's/^SHA256.*= //')
        sha1=$(openssl dgst -sha1 ${file}|sed 's/^SHA.*= //')
        md5=$(openssl dgst -md5 ${file}|sed 's/^MD5.*= //')

        # Upload Index File
        curl -u${USERNAME}:${PASSWORD} \
        -T ${file} \
        -H "X-Checksum-Sha256:${sha256}" -H "X-Checksum-Sha1:${sha1}" -H "X-Checksum-md5:${md5}"\
        "${ARTIFACTORY_URL}/${NEW_ARTIFACTORY_PATH}/${INDEX_FILE}"

    fi
done

# Reindex index.yaml
curl -X POST -u-u${USERNAME}:${PASSWORD} ${ARTIFACTORY_URL}/api/helm/${NEW_ARTIFACTORY_PATH}/reindex

rm helm_repo.zip
