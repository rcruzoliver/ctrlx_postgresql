#!/bin/sh

#wait thill the solution plug is connected :)
while ! snapctl is-connected active-solution 
do 
  sleep 5 
done

export LC_ALL=C   #Locale settings Override, MongoDB stuffs

#MyAppPersonaldir ---> Adapt for yourself
MY_FOLDERNAME=ctrlx-postgresql


#whatsMyDirAgain? better not modify this
MYDIR="$SNAP_COMMON/solutions/activeConfiguration/$MY_FOLDERNAME"

if [ ! -d "$MYDIR" ]; then
	mkdir $MYDIR
    echo $MYDIR
fi

#move myself in the working directory, from here enything is almost untouched
cd $MYDIR


# ensure the conf directory exists
if [ ! -f "./postgresql.conf" ]; then
	cp $SNAP/bin/conf/postgresql.conf ./postgresql.conf
    echo "file conf "
fi

if [ ! -f "./postgresql.log" ]; then
	cp $SNAP/bin/conf/postgresql.log ./postgresql.log
    echo "file "
fi

if [ ! -d "./postgresql" ]; then
	mkdir ./postgresql
    echo "folder "
fi

exec sudo -u postgres $SNAP/usr/lib/postgresql/14/bin/postgres -D ./postgresql -c ./postgresql.conf
