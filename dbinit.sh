#!/bin/bash
set -e 
set -o pipefail
# 检查db实例是否启动
#-------------------
dbstance_result=`ps -ef | grep "PostgreSQL" | grep -v grep`
if [ "${dbstance_result}" ]; then
   echo "监测到存在的数据库实例..."
   dbstance_result=true
else 
   # echo "未监测到存在的数据库实例,即将创建新的实例..."
   # /opt/pg11/bin/initdb -D /export/pg110_data
   # sed -i '' 's/#logging_collector = off/logging_collector = on/' /export/pg110_data/postgresql.conf中的logging_collector
   dbstance_result=false
   echo "未发现数据库实例, 请先手动创建"
   exit 0 
fi 
# ------------------
dbstance_result=false
if ! $dbstance_result; then
	echo "数据库实例创建失败, 请手动启动"
	exit 0 
fi
default_port=5432
default_host="localhost"
echo -n "请输入管理员账户名称:"
read admin_account
echo -n "请输入管理员密码:"
read admin_password
admin_account="postgres"
admin_password="123456"
db_status=0
# 检测是否已经有ejabberd数据库
startalk_db_result=`psql postgres://${admin_account}:${admin_password}@${localhost}:${default_port} -lqt | cut -d \| -f 1`
if fgrep postgres <<< $startalk_db_result ; then
    if egrep ejabberd <<< $startalk_db_result ; then
    	echo "数据库已存在, 将进行更新"
    	db_status=2
	else
    	echo "数据库不完整, 将进行更新"
    	db_status=1
	fi
else
    echo "数据库未建立, 将进行创建"
fi
# ------------------

if [ "${db_status}" = "0" ]; then
	echo "即将安装以下扩展:
	plpgsql
	adminpack
	btree_gist
	pg_buffercache
	pg_trgm
	pgstattuple"
   	psql postgres://${admin_account}:${admin_password}@${localhost}:${default_port} -f superUser.sql 
   	psql postgres://ejabberd:123456@${localhost}:${default_port} -f normalUser.sql
elif [ "${db_status}" = "1" ]; then
   	psql postgres://${admin_account}:${admin_password}@${localhost}:${default_port} -f superUser.sql 
   	psql postgres://ejabberd:123456@${localhost}:${default_port} -f normalUser.sql
else 
    # TODO: 对比新旧结构并且进行更新
    exit 0
fi
exit 0
