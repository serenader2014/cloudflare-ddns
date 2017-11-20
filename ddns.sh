#!/bin/sh

CONFIG=$1

if [ ! -f "$CONFIG" ]; then
  echo "ERROR! Config not found"
  exit 1
fi

. "$CONFIG"

if [ -f "$LAST_IP_FILE" ]; then
  . "$LAST_IP_FILE"
fi

IP_LIST=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
echo "ip list: $IP_LIST"

REAL_IP=$(curl -s https://api.ipify.org)
echo "real ip: $REAL_IP"

for ip in $IP_LIST
do
  if [ "$ip" == "$REAL_IP" ]; then
    public_ip="$ip"
  fi
 done


if [ "$public_ip" == "$LAST_IP" ];then
  echo "$(date) --- Already updated."
  exit 0
fi

URL_PREFIX="https://api.cloudflare.com/client/v4"

DOMAIN_LIST=$(curl -s -H "X-Auth-Key:$API_KEY" -H "X-Auth-Email:$EMAIL" $URL_PREFIX/zones)

DOMAIN_ID=$(echo $DOMAIN_LIST | grep -o "id\":\"[0-9a-fA-F]\{32\}\",\"name\":\"$DOMAIN"|grep -o "[0-9a-fA-F]\{32\}"|head -n1)

echo "$DOMAIN domain id: $DOMAIN_ID"

RECORD_LIST=$(curl -s -H "X-Auth-Key:$API_KEY" -H "X-Auth-Email:$EMAIL" $URL_PREFIX/zones/$DOMAIN_ID/dns_records )

for HOST in $HOSTS
do
  RECORD_ID=$(echo $RECORD_LIST | grep -o "id\":\"[0-9a-fA-F]\{32\}\",\"type\":\"A\",\"name\":\"$HOST.$DOMAIN"|grep -o "[0-9a-fA-F]\{32\}"|head -n1 )
  echo "host $HOST.$DOMAIN record id: $RECORD_ID"

  if [ "$RECORD_ID" != "" ]; then
    URL="$URL_PREFIX/zones/$DOMAIN_ID/dns_records/$RECORD_ID"
    PARAM_BODY="{\"type\":\"A\",\"name\":\"$HOST\",\"content\":\"$public_ip\"}"
    echo $PARAM_BODY
    RESULT=$(curl -X PUT -s -H "X-Auth-Key:$API_KEY" -H "X-Auth-Email:$EMAIL" -H "Content-Type: application/json" -d "$PARAM_BODY" $URL)
    echo $RESULT

    if [ "$(printf "%s" "$RESULT"|grep -c -o "success\":true")" = 1 ];then
        echo "$(date) -- Update success"
        echo "LAST_IP=\"$public_ip\"" > "$LAST_IP_FILE"
    else
        echo "$(date) -- Update failed"
    fi
  fi
done