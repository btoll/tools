#!/bin/bash

# $ ./create_cert.sh \
#     -d benjamintoll.com \
#     -d www.benjamintoll.com \
#     -d benjamintoll.io \
#     -d www.benjamintoll.io \
#     -d italy.benjamintoll.com \
#     -d theowlsnest.farm \
#     -d www.theowlsnest.farm \
#     -d theowlsnestfarm.com \
#     -d www.theowlsnestfarm.com \
#     -e minorsevenflatfive@proton.me \
#     -p

set -e

trap cleanup EXIT

cleanup() {
    docker-compose down
}

D=()
DRYRUN=true
EMAIL=root@localhost

usage() {
    echo "$0 -d DOMAIN [ -d DOMAIN ... ] -e EMAIL -p"
    exit "$1"
}

while getopts "c:d:e:hp" opt
do
    case "$opt" in
        d)
            D+=("$OPTARG")
            ;;
        e)
            EMAIL="$OPTARG"
            ;;
        h)
            usage 0
            ;;
        p)
            DRYRUN=false
            ;;
        ?)
            echo "Invalid option: -$OPTARG."
            exit 2
            ;;
        *)
            echo "Invalid flag: -$OPTARG."
            exit 2
            ;;
    esac
done

#if ! netstat -4tlpn &> /dev/null | ag 80
#then
#    echo "[WARNING] Another process is already using port 80, exiting..."
#    exit 1
#fi

if [ "${#D[*]}" -eq 0 ]
then
    echo "[ERROR] Missing required parameter DOMAIN"
    usage 2
fi

if $DRYRUN
then
    OPTIONS="--staging --register-unsafely-without-email"
else
    OPTIONS="--email $EMAIL --no-eff-email"
fi

for domain in "${D[@]}"
do
    LIST_DOMAINS+="$domain "
    DOMAINS+="-d $domain "
done

echo -------------------------------
echo "DOMAINS: $LIST_DOMAINS"
echo "EMAIL:   $EMAIL"
echo "DRYRUN:  $DRYRUN"
echo -------------------------------

mkdir -p letsencrypt/{etc,var/{lib,log}}

docker-compose up -d

docker run --rm -it \
    --name letsencrypt-certbot \
    -v "$(pwd)/www:/data/letsencrypt" \
    -v "$(pwd)/letsencrypt/etc/letsencrypt:/etc/letsencrypt" \
    -v "$(pwd)/letsencrypt/var/lib/letsencrypt:/var/lib/letsencrypt" \
    -v "$(pwd)/letsencrypt/var/log/letsencrypt:/var/log/letsencrypt" \
    certbot/certbot \
    certonly --webroot \
    --agree-tos --webroot-path=/data/letsencrypt \
    $OPTIONS $DOMAINS

docker run --rm -it \
    --name letsencrypt-certbot \
    -v "$(pwd)/www:/data/letsencrypt" \
    -v "$(pwd)/letsencrypt/etc/letsencrypt:/etc/letsencrypt" \
    -v "$(pwd)/letsencrypt/var/lib/letsencrypt:/var/lib/letsencrypt" \
    certbot/certbot \
    certificates

