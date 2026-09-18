# Expo Mela — production image for /opt/apps multi-app host
FROM node:20-bookworm-slim

WORKDIR /app

COPY package.json package-lock.json ./
COPY server/package.json server/package-lock.json ./server/
COPY client/package.json client/package-lock.json ./client/

RUN npm install --omit=dev \
  && npm --prefix server install --omit=dev \
  && npm --prefix client install

COPY . .

RUN npm --prefix client run build \
  && sed -i 's/\r$//' /app/deploy/docker-entrypoint.sh \
  && chmod +x /app/deploy/docker-entrypoint.sh

ENV NODE_ENV=production
ENV PORT=4000
EXPOSE 4000

ENTRYPOINT ["/app/deploy/docker-entrypoint.sh"]
CMD ["npm", "--prefix", "server", "start"]
