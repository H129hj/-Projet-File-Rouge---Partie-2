#!/bin/bash
# Recrée toute l'application à partir de zéro :
# image du site, réseau, volume et les trois conteneurs (site, db, adminer).
#
# Usage : ./lancer.sh [version]      (par défaut 1.0)

VERSION=${1:-1.0}
DB_PASSWORD=tpdocker

# options communes : redémarrage auto + rotation des logs (3 fichiers de 10 Mo max)
OPTIONS="--restart unless-stopped --log-opt max-size=10m --log-opt max-file=3"

echo "== Construction de l'image monsite:$VERSION"
docker build --build-arg APP_VERSION=$VERSION -t monsite:$VERSION . || exit 1

echo "== Suppression des anciens conteneurs"
docker rm -f site db adminer 2>/dev/null

echo "== Réseau et volume"
docker network inspect site-net > /dev/null 2>&1 || docker network create site-net
docker volume create site-db

echo "== Base de données (port non publié)"
docker run -d --name db --network site-net $OPTIONS \
  -m 512m \
  -e POSTGRES_PASSWORD=$DB_PASSWORD \
  -v site-db:/var/lib/postgresql/data \
  postgres:17

echo "== Adminer"
docker run -d --name adminer --network site-net $OPTIONS \
  -p 8081:8080 \
  adminer

echo "== Site"
docker run -d --name site --network site-net $OPTIONS \
  -m 128m --cpus 0.5 \
  -p 8080:80 \
  monsite:$VERSION

docker ps
