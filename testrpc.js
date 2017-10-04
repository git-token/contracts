const TestRPC = require("ethereumjs-testrpc");
const server = TestRPC.server({
  logger: {
    log: function(msg) {
      console.log('msg', msg)
    }
  }
});

server.listen(8545, function(error, blockchain) {
  console.log('error', error)
  console.log('blockchain', blockchain)
});
