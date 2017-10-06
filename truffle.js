module.exports = {
  networks: {
    development: {
      host: "138.68.225.133",
      port: 8745,
      network_id: "*", // Match any network id
      gasPrice: 4e9, // 20 Gwei gas price; lower == slower, cheaper; higher == faster, costly
      gas: 47e5
    }
  }
};
