# Projet fil rouge - Partie 2 : commandes utilisées

Hugo BERTON - B2 Info. Les captures et les réponses aux questions sont dans le rapport PDF.

## Étape 1 - L'image du site

```bash
docker build --build-arg APP_VERSION=1.0 -t monsite:1.0 .
docker run -d --name site -p 8080:80 monsite:1.0
docker ps                                                      # site -> (healthy)
docker image inspect -f '{{json .Config.Labels}}' monsite:1.0  # "version":"1.0"
docker inspect -f '{{json .State.Health}}' site

# suppression + recréation : la page est toujours là (elle est dans l'image)
docker rm -f site && docker run -d --name site -p 8080:80 monsite:1.0
curl -s http://localhost:8080 | grep '<title>'

# bonus : site-dev avec un bind mount en lecture seule
docker run -d --name site-dev -p 8090:80 -v "$(pwd)/site:/usr/share/nginx/html:ro" monsite:1.0
# modif de site/index.html sur l'hôte -> visible tout de suite sur :8090, pas sur :8080
docker rm -f site-dev
```

## Étape 2 - La base de données

```bash
docker network create site-net
docker volume create site-db
docker run -d --name db --network site-net -e POSTGRES_PASSWORD=tpdocker -v site-db:/var/lib/postgresql/data postgres:17
docker run -d --name adminer --network site-net -p 8081:8080 adminer
docker rm -f site && docker run -d --name site --network site-net -p 8080:80 monsite:1.0
```

Dans Adminer (http://localhost:8081, système PostgreSQL, serveur `db`, utilisateur `postgres`) :

```sql
CREATE TABLE contacts (
  id SERIAL PRIMARY KEY,
  nom VARCHAR(100) NOT NULL
);
INSERT INTO contacts (nom) VALUES ('Marie Dupont');
```

```bash
# on supprime db et on le recrée avec la même commande : la table est toujours là
docker rm -f db
docker run -d --name db --network site-net -e POSTGRES_PASSWORD=tpdocker -v site-db:/var/lib/postgresql/data postgres:17
docker exec db psql -U postgres -c "SELECT * FROM contacts;"

docker network inspect site-net | grep -E '"Name"|IPv4Address'   # adminer, db, site
docker port db                                                  # rien : port non publié

# où sont les données ?
docker volume inspect -f '{{.Mountpoint}}' site-db               # /var/lib/docker/volumes/site-db/_data
docker run --rm -v site-db:/data alpine:3.20 ls /data

# résolution du nom db : OK sur site-net, pas sur le bridge par défaut
docker run --rm --network site-net alpine:3.20 ping -c 1 db
docker run --rm alpine:3.20 ping -c 1 db                         # bad address 'db'
```

## Étape 3 - La mise en production

```bash
./lancer.sh                       # recrée tout (image 1.0, réseau, volume, 3 conteneurs)
docker desktop restart            # sur Mac (sur Linux : sudo systemctl restart docker)
docker ps                         # les 3 conteneurs sont Up
docker stats --no-stream          # site 128MiB, db 512MiB

# nouvelle version : modif de site/index.html puis
docker build --build-arg APP_VERSION=2.0 -t monsite:2.0 .
docker rm -f site
docker run -d --name site --network site-net --restart unless-stopped \
  --log-opt max-size=10m --log-opt max-file=3 -m 128m --cpus 0.5 -p 8080:80 monsite:2.0
docker image inspect -f '{{json .Config.Labels}}' monsite:2.0    # "version":"2.0"
```
