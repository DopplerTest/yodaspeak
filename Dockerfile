FROM node:lts-alpine

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
LABEL maintainer="Ryan Blunden <ryan.blunden@doppler.com>"

# Ensure DNS resolution works everywhere
# See https://github.com/gliderlabs/docker-alpine/issues/539#issuecomment-607159184
RUN apk add --no-cache bind-tools

# Use to cache bust system dependencies
ENV LAST_UPDATED 2020-12-16

RUN (curl -Ls https://cli.doppler.com/install.sh || wget -qO- https://cli.doppler.com/install.sh) | sh

WORKDIR /usr/src/app
COPY package.json package-lock.json ./
RUN npm clean-install --only=production --silent --no-audit && mv node_modules ../
COPY . .

USER node

EXPOSE 8080 8443

HEALTHCHECK --interval=5s --timeout=5s --retries=3 CMD wget http://localhost:8080/healthz -q -O - || exit 1

CMD ["npm", "start"]
