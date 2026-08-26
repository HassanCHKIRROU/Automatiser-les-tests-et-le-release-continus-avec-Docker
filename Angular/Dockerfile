
#  1 : build de l'application Angular

FROM node:20.19.0-alpine AS build

# Dossier de travail dans le conteneur de build
WORKDIR /build

# On copie d'abord uniquement les fichiers de dépendances.
# Cela permet à Docker de mettre en cache cette étape : si package.json
# ne change pas, npm ci ne sera pas relancé lors des prochains builds.
COPY package.json package-lock.json ./

# npm ci = installation reproductible, recommandée en CI/CD (cf. README)
RUN npm ci

# On copie le reste du code source
COPY . .

# Build de production Angular (génère dist/olympic-games-starter/browser)
RUN npm run build


#  2 : image finale, Nginx qui sert les fichiers statiques

FROM nginx:1.27-alpine

# On remplace la config Nginx par défaut par la nôtre
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# On copie UNIQUEMENT les fichiers compilés depuis le stage "build"
# (pas besoin de Node ni du code source dans l'image finale)
COPY --from=build /build/dist/olympic-games-starter/browser /app

# Port sur lequel Nginx écoute (défini dans nginx.conf)
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]