FROM node:14-alpine

WORKDIR /usr/src/app
RUN npm install express
RUN apk add --no-cache curl yq 
COPY ./src .
EXPOSE 80

CMD ["node", "app.js"]
