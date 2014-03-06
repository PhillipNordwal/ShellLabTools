#!/bin/sh

timeout=1
date=`date '+%Y.%m.%d.%H:%M:%S'`

# XXX: there is an error here if two jobs are run in the same second
# XXX: there is an error here if two backgrounded jobs write to the error file at the same time
if [ $# -lt 2 ]; then
    echo "Usage: $0 hostfile 'cmdlist' [-B ] [optional ssh flags]"
    echo "  Hostfile contains a newline seperated list for hostnames to run the cmdlist on"
    echo "  -b will cause the individual ssh sessions to be backgrounded"
    echo "  ssh will be called with at least the following flags '-t -q -o connecttimeout=$timeout"
    echo "  Errors connecting to a host are logged to an errorfile if there are any."
    exit 1
fi
hostfile=$1
cmd=$2
errorfile=~/error/$date.cononlinux.`basename $hostfile`
# the shift cmd pops the first argument off of the argument list
shift
shift
if [ $# -gt 0 -a "-B" = "$1" ]; then
    background=1
    shift
fi

for host in `cat $hostfile`; do
    if [ $background ]; then
        (ssh -t -q -o connecttimeout=$timeout $* $host $cmd || (echo error connecting to \'$host\' as $user and running \'$cmd\' >> $errorfile))&
    else
        ssh -t -q -o connecttimeout=$timeout $* $host $cmd || (echo error connecting to \'$host\' as $user and running \'$cmd\' >> $errorfile)
    fi
done
wait

if [ -e $errorfile ]; then
    cat $errorfile 1>&2;
fi
