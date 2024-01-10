#!/bin/sh

echo "running run.sh"

# wait until the solution plug is connected 
# the "connect-plug-active-solution" hook will be will be run

while ! snapctl is-connected active-solution 
do 
  sleep 5 
done
echo "active-solution is connected"

# some things I am not sure if they are needed
export LC_ALL=C   #Locale settings Override, from MongoDB example

# Directory inside persistent data (SNAP_COMMON) and visible from ctrlX Web Interface
MY_FOLDERNAME=ctrlx-postgresql
MYDIR="$SNAP_COMMON/solutions/activeConfiguration/$MY_FOLDERNAME"


## SERVER ##
############

echo "<< PostgreSQL starts ... >>"

# run the binary ("$SNAP/usr/lib/postgresql/14/bin/postgres") with user snap_daemon
# using "setpriv" utility to do so
# config files (hba and ident) and data (D) path overriden in the call with flags (otherwise configured in postgresql.conf)

exec "${SNAP}"/usr/bin/setpriv --clear-groups --reuid snap_daemon --regid snap_daemon -- \
  $SNAP/usr/lib/postgresql/14/bin/postgres \
  --config-file=$MYDIR/configuration/postgresql.conf \
  --hba_file=$MYDIR/configuration/pg_hba.conf \
  --ident_file=$MYDIR/configuration/pg_ident.conf \
  -D $MYDIR/data_postgresql

echo "<< PostgreSQL has crashed. >>"
echo "<< Server will be automatically restarted ... >>"

############
## SERVER ##
