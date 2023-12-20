#!/bin/sh

echo "running run.sh"

#wait thill the solution plug is connected :)
while ! snapctl is-connected active-solution 
do 
  sleep 5 
done

echo "active-solution is connected"

export LC_ALL=C   #Locale settings Override, MongoDB stuffs

#MyAppPersonaldir ---> Adapt for yourself
MY_FOLDERNAME=ctrlx-postgresql


#whatsMyDirAgain? better not modify this
MYDIR="$SNAP_COMMON/solutions/activeConfiguration/$MY_FOLDERNAME"

if [ ! -d "$MYDIR" ]; then
	mkdir -p $MYDIR
    echo $MYDIR
fi

#move myself in the working directory, from here enything is almost untouched
cd $MYDIR


# ensure the conf directory exists
if [ ! -d "./configuration" ]; then
	cp -r $SNAP/bin/data/configuration $MYDIR/configuration
    echo "configuration folder added to persistent data "
fi

if [ ! -f "./postgresql.log" ]; then
	cp $SNAP/bin/data/postgresql.log $MYDIR/postgresql.log
    echo "log file added to persistent data "
fi

if [ ! -d "./data_postgresql" ]; then
    cp -r $SNAP/bin/data/data_postgresql $MYDIR/data_postgresql
    echo "data folder added to persistent data "
fi

if [ ! -d "./ssl" ]; then
    cp -r $SNAP/bin/data/ssl $MYDIR/ssl
    echo "ssl folder added to persistent data "
fi



echo "Changing permissions"
chmod 777 -R "$MYDIR/configuration" # must be before chown
chmod 750 -R "$MYDIR/data_postgresql" # must be before chown

echo "Changing ownership"
chown -R snap_daemon:snap_daemon "$MYDIR"

echo "Does snap_daemon actually have the right permissions?"
ls -ld $MYDIR/configuration/postgresql.conf 
ls -ld $MYDIR/data_postgresql

echo "Let's start the server then"
exec "${SNAP}"/usr/bin/setpriv --clear-groups --reuid snap_daemon --regid snap_daemon -- $SNAP/usr/lib/postgresql/14/bin/postgres --config-file=$MYDIR/configuration/postgresql.conf

echo "<< I did not crash >>"