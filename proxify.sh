
set -ex

pkcon install -y squid

sed "/^http_port/ a http_port 3129 intercept \nmaximum_object_size 2 GB " /etc/squid/squid.conf

SQUIDID=$(id -u squid)

filter="iptables -t filter"
nat="iptables -t nat"

$nat -I OUTPUT -p tcp --dport 80 -j REDIRECT --to-port 3129
$nat -I OUTPUT -m owner --uid-owner $SQUIDID -j ACCEPT

$filter -I OUTPUT -p tcp --dport 443 -j REJECT
$filter -I OUTPUT -m owner --uid-owner $SQUIDID -j ACCEPT
