
set -ex

pkcon install -y squid

sed "/^http_port/ a http_port 3129 intercept \nmaximum_object_size 2 GB " /etc/squid/squid.conf

systemctl enable squid
systemctl start squid

SQUIDID=$(id -u squid)

#filter="iptables -t filter"
#nat="iptables -t nat"

fwl="firewall-cmd --direct --${WAY:-add}-rule"

for INET in ipv4 ipv6;
do
for CHAIN in OUTPUT;
do
  $fwl $INET nat $CHAIN 0 -m owner --uid-owner $SQUIDID -j ACCEPT
  $fwl $INET nat $CHAIN 1 -p tcp --dport 80 -j REDIRECT --to-port 3129

  $fwl $INET filter $CHAIN 0 -m owner --uid-owner $SQUIDID -j ACCEPT
  $fwl $INET filter $CHAIN 1 -p tcp --dport 443 -j REJECT
done
done
