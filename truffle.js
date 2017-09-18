module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*", // Match any network id
      gasPrice: 2e10, // 20 Gwei gas price; lower == slower, cheaper; higher == faster, costly
      gas: 47e5
    }
  }
};
