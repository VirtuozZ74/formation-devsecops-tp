FROM node:14-alpine

#WORKDIR /app
WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD [ "node","Application.js" ]