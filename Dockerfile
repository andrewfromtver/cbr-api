FROM node:alpine

LABEL org.opencontainers.image.source https://github.com/andrewfromtver/cbr-api

WORKDIR /usr/src/app

RUN npm install express express-rate-limit shell-quote
RUN apk add --no-cache curl tar
RUN curl -LJO https://github.com/mikefarah/yq/releases/download/v4.43.1/yq_linux_amd64.tar.gz \
    && tar -xzf yq_linux_amd64.tar.gz -C /usr/local/bin/ \
    && mv /usr/local/bin/yq_linux_amd64 /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq \
    && rm yq_linux_amd64.tar.gz

COPY ./src .

RUN adduser -D apiuser
RUN chown -R apiuser:apiuser /usr/src/app

USER apiuser

EXPOSE 80

CMD ["node", "app.js"]
