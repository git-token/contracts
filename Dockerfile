FROM node:6.11.0

RUN npm i -g truffle
RUN npm i -g pm2
RUN npm i -g mocha

WORKDIR /gittoken-contracts

ADD . .

RUN npm install

CMD ["truffle", "test"]
