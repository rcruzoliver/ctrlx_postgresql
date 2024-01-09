#!/bin/sh

echo "running run.sh"

#wait thill the solution plug is connected :)
while ! snapctl is-connected active-solution 
do 
  sleep 5 
done

echo "active-solution is connected"

export LC_ALL=C   #Locale settings Override, MongoDB stuffs

MY_FOLDERNAME=ctrlx-postgresql
MYDIR="$SNAP_DATA/$MY_FOLDERNAME"

exec "${SNAP}"/usr/bin/setpriv --clear-groups --reuid snap_daemon --regid snap_daemon -- $SNAP/usr/lib/postgresql/14/bin/postgres \
  --config-file=$MYDIR/configuration/postgresql.conf \
  --hba_file=$MYDIR/configuration/pg_hba.conf \
  --ident_file=$MYDIR/configuration/pg_ident.conf \
  -D $MYDIR/data_postgresql

echo "<< I did not crash >>"