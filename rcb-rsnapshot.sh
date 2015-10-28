#!/usr/local/bin/bash

source /usr/local/etc/rcb.conf

USAGE="$(basename "$0") [-h|--help] [-i|--increment=[hourly,daily,weekly,monthly]] -- rsnapshot backup
where:
    -h --help show this help text
    -i --increment is one of the options: hourly,daily,weekly or monthly"

EXPECTED_ARGS=1
if [ $# -ne $EXPECTED_ARGS ]; then
    echo "$USAGE"
    exit
fi

for i in "$@"; do
    case $i in
	-h*|--help*)
	    echo "$USAGE"
	    exit
	    ;;
	-i=*|--increment=*)
	    INC="${i#*=}"
	    ;;
	--default)
	    INC="hourly"
	    ;;
	*)
	    # unknown option
	    ;;
    esac
done

printf "$(date) [OK] *** $INC backup started\n" >> $RCB_LOG
if ($RSNAPSHOT $RSNAPSHOT_PARAM $INC >$RCB_LOG_TEMP 2>&1); then
    printf "$(date) [OK] *** $INC backup finished\n" >> $RCB_LOG
    rm $RCB_LOG_TEMP
else
    printf "$(date) [ERR] $INC backup finished with error\n" >> $RCB_LOG
    cat $RCB_LOG_TEMP >> $RCB_LOG
    cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST $INC backup finished with error" $RCB_EMAIL
    rm $RCB_LOG_TEMP
    exit 1
fi

exit
