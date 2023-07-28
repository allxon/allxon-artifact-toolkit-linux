#!/bin/bash

set -e

VERSION=1.0.0

WORKDIR=${PWD}

IS_NVIDIA_JETSON=0
HOST_ARCH=UNKNOW
DISTRIB_ID=UNKNOW
TARGET_ARCH=

print_err() {
    echo -ne "\033[0;31m$1\n"
}

show_uage() {
  echo -ne "Usage: --package or --test <path_to_file>\n"
  echo -ne '\t  [ --arch <ARCH|all>] --package \t create ota package file with <ARCH>. --arch all for all architecture\n'
  echo -ne '\t  --test path_to_file  \t\t\t test <path_to_file> ota package on local device\n'
        
  exit 2
}

check_host_dist() {

    local dist=`uname -s`
    echo $dist
    if [ ! $dist = "Linux" ]; then
        print_err "This tool is for Linux platform only!!!\n"
        exit 2
    fi

    DISTRIB_ID=`awk -F "=" 'NR==1{print $2 ; eixt}' /etc/*-release`
    
    if [ -f "/etc/nv_tegra_release" ]; then
        IS_NVIDIA_JETSON=1
    fi
}

check_host_arch() {
    arch=`uname -m`
    if [ -n ${arch} ]; then
        HOST_ARCH=${arch}
    fi
}

show_versio_info() {
    echo -ne "********************************************************************* \n"
    echo -ne "\t Allxon package tool : ${VERSION}\n"
    if [ $IS_NVIDIA_JETSON -eq 0 ]; then
        echo -ne "\t Host : ${DISTRIB_ID}\n";
    else
        echo -ne "\t Host : Jetson\n";
    fi

    echo -ne "\t Architecture : ${HOST_ARCH}\n";
    
    TARGET_ARCH=${HOST_ARCH}

	echo -ne "********************************************************************* \n"
}

create_host_info_at_pwd() {
    uname -a > .host_info
    echo "ota_tool_ver=${VERSION}" >>.host_info
    echo "command=${USER_COMMAND}" >>.host_info
}

do_package() {

    echo -ne "Creating Allxon OTA Artifact ...\n"
    
    echo -ne "Using Architecture : *****[${TARGET_ARCH}]*****\n"

    local PKG_NAME=Allxon_OTA_Artifact-L-${TARGET_ARCH}.tar.gz
    local NEW_PKG_NAME=

    if [ -f "${PKG_NAME}" ]; then 
        rm ${PKG_NAME}
    fi

    cd ota_content
    
    create_host_info_at_pwd

    echo -ne "Packing all files in ota_content...\n"
    tar cvzf ../${PKG_NAME} *
    
    cd ${WORKDIR}

    FILE_HASH=`md5sum ${PKG_NAME} | awk '{ print $1 }'`
    FILE_NAME_HASH=`echo -ne ${FILE_HASH}-${PKG_NAME} | md5sum | awk '{print $1}'`

    NEW_PKG_NAME="${FILE_NAME_HASH}-${PKG_NAME}"
    mv ${PKG_NAME} ${NEW_PKG_NAME}

    echo -ne "Allxon OTA Artifact Created : ${NEW_PKG_NAME} \n"

    exit 0
}

do_install() {

    OTA_PAYLOAD_PACKAGE=$1;
    if [ ! -f "${OTA_PAYLOAD_PACKAGE}" ]; then
        print_err "$1 not exists. \n"
        exit 1
    fi
    FILENAME=$(basename ${OTA_PAYLOAD_PACKAGE})
    FILE_HASH=`md5sum ${FILENAME} | awk '{ print $1 }'`
    local ORI_PKG_NAME=${FILENAME: 33}
    echo "Origin name : ${ORI_PKG_NAME}"

    FILE_NAME_HASH=`echo -ne ${FILE_HASH}-${ORI_PKG_NAME} | md5sum | awk '{print $1}'`
    NEW_FILE_NAME=${FILE_NAME_HASH}-${ORI_PKG_NAME}
    
    if [ ! "${NEW_FILE_NAME}" = "${FILENAME}" ]; then
        print_err "Package is not intact\n"
        exit 1
    fi

    TARGET_ARCH=${FILENAME: 55: -7}

    if  [ ${TARGET_ARCH} != "all" ] && [ ${TARGET_ARCH} != ${HOST_ARCH} ] ; then
        print_err "Packge is not supported on this machine\n"
        exit 1
    fi

    echo -ne "Extarcting Allxon OTA Artifact : ${OTA_PAYLOAD_PACKAGE} \n"
    
    NOW_TS=$(date +%s)
    DESTDIR=/tmp/${NOW_TS}
    mkdir -p /tmp/${NOW_TS}

    echo "Extract ${OTA_PAYLOAD_PACKAGE} to "$DESTDIR""
    if ! tar xzvf "${OTA_PAYLOAD_PACKAGE}" -C "${DESTDIR}" >/dev/null 2>&1; then
        print_err "Failed to run \"tar xzvf ${OTA_PAYLOAD_PACKAGE} -C ${DESTDIR}\"\n"
        exit 1
    fi

    echo -ne "\n\nRuning install.sh in Allxon OTA Artifact ... \n"

    cd ${DESTDIR} && su root -c "/bin/bash ./ota_deploy.sh" 1>/dev/null 2>&1 0>&1

    cd ${WORKDIR}

    echo "Running install is finished. Check the result."
    exit 0
}

set_target_arch() {
    TARGET_ARCH=$1
}

echo "$@"

USER_COMMAND=`echo "$0 $*"`

check_host_arch
check_host_dist

show_versio_info

# Make sure that this script is running in root privilege
USERID=$(id -u)
if [ "${USERID}" -ne 0 ]; then
       print_err "Please run this tool as root.\n"
       exit 1
fi

while [ True ]; do
if [ "$1" = "--package" -o "$1" = "-p" ]; then
    do_package
elif [ "$1" = "--test" -o "$1" = "-t" ]; then
    do_install $2
elif [ "$1" = "--arch" -o "$1" = "-a" ]; then
    set_target_arch $2
    shift 2
else
    show_uage
fi
    
done
