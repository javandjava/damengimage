#!/bin/bash
# create dmdb or start db when running container

DM_HOME=/home/dmdba/dmdbms/bin
DATA_DIR=/dbdata
dbcmd=$DM_HOME/dmserver

function create_db {
    echo "Initializing DM database..."
    rm -rf /dbdata/*
    $DM_HOME/dminit path=$DATA_DIR charset=${CHARSET:-1} page_size=${PAGE_SIZE:-32} \
    case_sensitive=${CASE_SENSITIVE:-0} PORT_NUM=${PORT_NUM:-5236} \
    SYSDBA_PWD=${SYSDBA_PWD:-Dameng123} SYSAUDITOR_PWD=${SYSAUDITOR_PWD:-Dameng123}
}

function start_db {
    echo "Starting DM database..."
    nohup $dbcmd $DATA_DIR/DAMENG/dm.ini -noconsole > /home/dmdba/dmdbms/log/DmServiceDM.log 2>&1 &
    if [ $? -eq 0 ]; then
        echo "Database started successfully."
    else
        echo "Database start failed."
    fi
}

# 判断是否已存在数据库
if [ -d $DATA_DIR/DAMENG ]; then
    start_db
else
    create_db
    start_db
fi

# 保持容器运行
tail -f /dev/null
