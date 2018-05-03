# Common functions

UTIL="RCB"
CONFIG="rcb.conf"
CONFIGVAR=${RCBCONFIG:-}
LOGFILE="/tmp/rcb.log"
LOGTOFILE=1
VERB0SE=1
DEBUG=0


function log-ok {
    (($VERBOSE)) && printf "[OK]  $UTIL: $MESSAGE\n"
    (($LOGTOFILE)) && printf "`date "+%F %T"` [OK]  $UTIL: $MESSAGE\n" >> $LOGFILE
}

function log-dbg {
    (($DEBUG)) && printf "[DBG] $UTIL: $MESSAGE\n"
    (($DEBUG)) && (($LOGTOFILE)) && printf "`date "+%F %T"` [DBG] $UTIL: $MESSAGE\n" >> $LOGFILE
}

function log-err {
    printf "[ERR] $UTIL: $MESSAGE\n"
    (($LOGTOFILE)) && printf "`date "+%F %T"` [ERR] $UTIL: $MESSAGE\n" >> $LOGFILE
}


function read_config {
    if [[ -f /etc/$CONFIG ]]; then
	MESSAGE="  configuration: /etc/$CONFIG found."; log-ok
	. /etc/$CONFIG
    fi
    if [[ -f /usr/local/etc/$CONFIG ]]; then
	MESSAGE="  configuration: /usr/local/etc/$CONFIG found."; log-ok
	. /usr/local/etc/$CONFIG
    fi
    if [[ -f ~/.$CONFIG ]]; then
	MESSAGE="  configuration: ~/.$CONFIG found."; log-ok
	. ~/.$CONFIG
    fi
    if [[ -f ./.$CONFIG ]]; then
	MESSAGE="  configuration: ./.$CONFIG found."; log-ok
	. ./.$CONFIG
    fi
    if [ ! -z ${CONFIGVAR} ]; then
	if [ -r $CONFIGVAR ]; then
	    MESSAGE="  configuration: $CONFIGVAR found."; log-ok
	    . $CONFIGVAR
	fi
    fi
}

# EOF
