FROM nginx:1.27-alpine

# version de l'application, passée au build avec --build-arg
ARG APP_VERSION=dev
LABEL version=$APP_VERSION

# configuration nginx récupérée en partie 1
COPY nginx.conf /etc/nginx/nginx.conf
# contenu du site
COPY site/ /usr/share/nginx/html/

EXPOSE 80

# toutes les 10 secondes on vérifie que la page répond
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q --spider http://localhost/ || exit 1
