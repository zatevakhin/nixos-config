FROM nodered/node-red:latest-debian

RUN npm install \
  node-red-contrib-ollama \
  @inductiv/node-red-openai-api \
  node-red-contrib-matrix-chat \
  node-red-contrib-counter \
  node-red-contrib-timed-counter \
  node-red-contrib-chronos \
  node-red-contrib-cron-plus \
  node-red-contrib-loop do-red \
  node-red-contrib-home-assistant-websocket \
  @digitalnodecom/node-red-contrib-generic-s3

RUN cd /usr/src/node-red && npm install --save  @node-red-contrib-themes/theme-collection

USER root
RUN apt-get update && apt-get install -y \
  ca-certificates \
  curl \
  openssl

RUN mkdir -p /usr/local/share/ca-certificates \
  && curl --insecure -o /usr/local/share/ca-certificates/step-sister.pem https://ca.homeworld.lan:8443/roots.pem \
  && update-ca-certificates

ENV NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/step-sister.pem

USER node-red
