#!/bin/bash

if [ ! -e /etc/default/mydyns-update ]; then
	exit 0
fi

. /etc/default/mydyns-update

if [ -z "$HOST" ] || [ -z "$TOKEN" ]; then
	exit 0
fi

SPREEDBOX_RELEASE="0.0"
if [ -e /etc/spreedbox-release ]; then
	. /etc/spreedbox-release
fi

# URL's. If you want to validate the certificate, remote the -k.
CURL="/usr/bin/curl -k -A spreedbox/$SPREEDBOX_RELEASE"
IP4=`$CURL -4 -s "https://$HOST/update?token=$TOKEN&check" 2>/dev/null`
IP6=`$CURL -6 -s "https://$HOST/update?token=$TOKEN&check" 2>/dev/null`
TIME=`date "+%Y/%m/%d %H:%M:%S"`
# If you run multiple, make sure to use different prefixes.
PREFIX="mydyns"

OLD_IP4=""
STATUS_IP6=""
if [ -e /tmp/$PREFIX-update4 ]; then
	OLD_IP4=`cat /tmp/$PREFIX-update4`
fi
if [ -n "$IP4" ]; then
	if [ "$IP4" != "$OLD_IP4" ]; then
		STATUS_IP4=`$CURL -4 -s "https://$HOST/update?token=$TOKEN&myip=$IP4" 2>/dev/null`
		if [ "$STATUS_IP4" == "accepted" ]; then
			echo "$TIME - IPv4 update status $STATUS_IP4:$IP4"
			echo $IP4 > /tmp/$PREFIX-update4
		else
			echo "$TIME - IPv4 update status failed:$STATUS_IP4"
		fi
	fi
fi

OLD_IP6=""
STATUS_IP6=""
if [ -e /tmp/$PREFIX-update6 ]; then
	OLD_IP6=`cat /tmp/$PREFIX-update6`
fi
if [ -n "$IP6" ]; then
	if [ "$IP6" != "$OLD_IP6" ]; then
		STATUS_IP6=`$CURL -6 -s "https://$HOST/update?token=$TOKEN&myip=$IP6" 2>/dev/null`
		if [ "$STATUS_IP6" == "accepted" ]; then
			echo "$TIME - IPv6 update status $STATUS_IP6:$IP6"
			echo $IP6 > /tmp/$PREFIX-update6
		else
			echo "$TIME - IPv6 update status failed:$STATUS_IP6"
		fi
	fi
fi

