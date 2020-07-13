#!/bin/bash
# Varying number of leading zeros
# for ((i=1;i<=6;i=i+1)); do ((j=10**$i)); seq 0 $(expr $j \- 1) | parallel --halt now,success=1 ./btc-pintest.sh {} $i; done
PIN=${1}
DIGITS=${2}
if [ -f ./pin*.txt ]; then
    echo "PIN already found. Exiting..."
    exit 0
fi

if [ -z ${PIN} ]; then
    echo "Error: no PIN given to test."
    exit 1
fi

if [ ! -z ${DIGITS} ]; then
    printf -v PIN %0${DIGITS}d ${PIN}
fi

#tmpwallet is a mount point for a ramdisk.
# mkdir ${HOME}/tmpwallet
# sudo mount -t tmpfs -o size=128M tmpfs ${HOME}/tmpwallet
WALLET_PATH="${HOME}/tmpwallet/bitcoin-wallet-decrypted-backup"
WTOOL_CMD="java -jar wallet-tool.jar"
TMPFILE="wallet_${PIN}"
TMPDIR="./${TMPFILE}"

mkdir -p ${TMPDIR}
cp ${WALLET_PATH} ${TMPDIR}/${TMPFILE}

if [ ! -z "$(${WTOOL_CMD} decrypt --wallet=${TMPDIR}/${TMPFILE} --password=${PIN} 2>&1 | grep 'Password incorrect.')" ]; then
    echo "Tested PIN ${PIN} without success"
    rm -rf ${TMPDIR}
    exit 1
else
    echo "PIN is ${PIN}" > pin_${PIN}.txt
    echo "PIN found"
    exit 0
fi

