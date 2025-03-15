#!/bin/bash
ARTIFACT=$1
RELEASE=$2
BUILD_DIR="./builds/${ARTIFACT}"
QCOW2_FILE="${ARTIFACT}"
GZIP_FILE="${QCOW2_FILE}-${RELEASE}.qcow2.gz"

# preserve original
gzip -c ${BUILD_DIR}/${QCOW2_FILE} > ${BUILD_DIR}/${GZIP_FILE}

curl -ku "kvm:$(cat ~/.nexus_password.txt)" --upload-file ${BUILD_DIR}/${GZIP_FILE} \
    "https://nexus.infrastructure.asio:8443/repository/raw/kvm/${GZIP_FILE}"