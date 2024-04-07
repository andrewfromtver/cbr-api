FROM node:alpine

LABEL org.opencontainers.image.source https://github.com/andrewfromtver/cbr_api

WORKDIR /usr/src/app
RUN apk add --no-cache curl yq
RUN npm install express express-rate-limit shell-quote
COPY ./src .
RUN apk update --no-cache && \
    apk upgrade --available --no-cache
EXPOSE 80

CMD ["node", "app.js"]
