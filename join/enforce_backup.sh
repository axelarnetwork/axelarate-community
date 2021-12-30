#!/bin/bash

PATH=$1
OK=0
ERR=1

STATUS=$OK

while [ -f "$PATH" ]; do
    read -p "Please backup you mnemonic from $PATH, delete the file and press Ok (O), or Cancel (C): " oc
    case $oc in
        [Oo]* ) ;;
        [Cc]* ) STATUS=$ERR; break;;
        * ) echo "Please answer Ok (O) or Cancel (C).";;
    esac
done

exit $STATUS
