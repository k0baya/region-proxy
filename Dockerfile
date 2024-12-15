FROM node:latest
EXPOSE 8443
WORKDIR /app
COPY . .

RUN apt-get update &&\
    apt-get install -y iproute2 bash curl wget tar tor vim &&\
    npm install && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT [ "node", "server.js" ]