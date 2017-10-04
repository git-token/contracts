FROM node:6.11.0

RUN npm i -g truffle
RUN npm i -g ethereumjs-testrpc
RUN npm i -g pm2

WORKDIR /gittoken-contracts

ADD . .

RUN npm install

RUN node testrpc.js

ENTRYPOINT truffle test
