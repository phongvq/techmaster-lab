FROM node:18-alpine

ENV NODE_ENV=development
ENV PORT=3000

WORKDIR /app

# RUN apk add supervisor=4.2.5-r5

COPY package-lock.json .
COPY package.json .

RUN npm ci

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
