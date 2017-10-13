FROM node:6.11.0

RUN npm i -g truffle

WORKDIR /gittoken-contracts

ADD . .

RUN npm install

CMD ["truffle", "test"]
