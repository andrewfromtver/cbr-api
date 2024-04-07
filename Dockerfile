FROM node:14-alpine

LABEL org.opencontainers.image.source https://github.com/andrewfromtver/cbr_api

WORKDIR /usr/src/app
RUN npm install express express-rate-limit
RUN apk add --no-cache curl yq 
COPY ./src .
EXPOSE 80

CMD ["node", "app.js"]
