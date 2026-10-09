# Projet fil rouge - Partie 2 : le site passe en production

Conteneurisation (B2 Info, Ynov) - Hugo BERTON

- `projet-site/Dockerfile` : image `monsite` basée sur `nginx:1.27-alpine` (label version, healthcheck)
- `projet-site/.dockerignore`
- `projet-site/lancer.sh` : recrée toute l'application (image, réseau `site-net`, volume `site-db`, conteneurs site / db / adminer)
- `projet-site/site/index.html` : la page du site (version 2.0)
- `projet-site/commandes.md` : les commandes utilisées
- `rapport/BERTON_Hugo_fil_rouge_partie2.pdf` : le rapport avec les captures et les réponses aux questions

Lancement :

```bash
cd projet-site
./lancer.sh 2.0
```

Site : http://localhost:8080 - Adminer : http://localhost:8081 (serveur `db`, utilisateur `postgres`)
