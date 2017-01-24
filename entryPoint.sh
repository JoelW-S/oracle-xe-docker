#!/bin/bash
sed -i -E "s/HOST = [^)]+/HOST = $HOSTNAME/g" $ORACLE_HOME/network/admin/listener.ora
sed -i -E "s/HOST = [^)]+/HOST = $HOSTNAME/g" $ORACLE_HOME/network/admin/tnsnames.ora

/etc/init.d/oracle-xe start
echo "Oracle Express ready."

# Give oracle time to bootup
sleep 30
        ##
        ## Workaround for graceful shutdown.
        ##
while [ "$END" == '' ]; do
    sleep 1
    trap "/etc/init.d/oracle-xe stop && END=1" INT TERM
done
