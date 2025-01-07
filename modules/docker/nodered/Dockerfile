FROM nodered/node-red

RUN npm install \
  node-red-contrib-ollama \
  @inductiv/node-red-openai-api \
  node-red-contrib-matrix-chat \
  node-red-contrib-counter \
  node-red-contrib-timed-counter \
  node-red-contrib-chronos \
  node-red-contrib-cron-plus \
  node-red-contrib-loop do-red \
  node-red-contrib-home-assistant-websocket

RUN cd /usr/src/node-red && npm install --save  @node-red-contrib-themes/theme-collection

