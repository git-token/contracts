module.exports = {
  networks: {
    torvalds: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*", // Match any network id
      gasPrice: 4e9,
      gas: 47e5
    },
    development: {
      host: "138.68.225.133",
      port: 8745,
      network_id: "*", // Match any network id
      gasPrice: 4e9,
      gas: 47e5
    }
  }
};
