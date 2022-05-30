#!/bin/bash

function sys_info {
    echo -e "-------------------------------General system Information-----------------------"
    hostnamectl | grep -v 'ID:'
    echo ""
    echo -e "-------------------------------Memory information-------------------------------"  
    free -m
    echo ""
    echo -e "-------------------------------CPU information----------------------------------"
    echo "Threads/core: $(nproc --all)"
    echo -e "CPU Usage:\t"`cat /proc/stat | awk '/cpu/{printf("%.2f%\n"), ($2+$4)*100/($2+$4+$5)}' | awk '{print 
$0}' | head -1`
    echo ""
    echo -e "-------------------------------Disk Usage---------------------------------------"
    sudo df -H --output=source,size,used,avail
    echo ""
}

function dir_info {
    echo -e "-------------------------------Check .axelar folder---------------------------------------"    
    test -d ~/.axelar && ls -lR ~/.axelar || echo "no ~/.axelar folder found"
    echo ""
    echo -e "-------------------------------Check .axelar_testnet folder-------------------------------" 
    test -d ~/.axelar_testnet && ls -lR ~/.axelar-testnet || echo "no ~/.axelar_testnet folder found"
    echo ""
    echo -e "-------------------------------Check .axelar_testnet-2 folder-----------------------------" 
    test -d ~/.axelar_testnet-2 && ls -lR ~/.axelar_testnet-2 || echo "no ~/.axelar_testnet-2 folder found"
    echo ""
}

function process_info {
echo -e "-------------------------------Check axelard process status----------------------------------" 
    pgrep -f "axelard start" > /dev/null 2>&1  && (echo 'axelard process is running';ps -ef | grep axelard | head -n 
-1) || echo 'axelard process not found'
    echo ""
}

function sync_info {
echo -e "-------------------------------Check node sync status-----------------------------------------" 
    curl -s localhost:26657/status | jq '.result.sync_info' | grep '"catching_up": true' > /dev/null 2>&1 && echo "Node is catching up" || echo "Node is not catching up"
    echo ""
}

sys_info
dir_info
process_info
sync_info

