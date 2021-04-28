const HDWalletProvider = require("@truffle/hdwallet-provider");

module.exports = {
  networks: {
    // Ganache Local Network
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // Match any network id
    },
    // Rinkeby Network
    rinkeby: {
      provider: function() {
          return new HDWalletProvider("6feaee469276be907bdf9f5d3d214193c41093e23103820ef7153d8e1e17774a","https://rinkeby.infura.io/v3/9cd939c36f80494e811fa83b60ae1b9a")
        },

        network_id: "4",
        from:"0xcc16aCD23883f96dEA4c48B40A2338Cb07278eB8"

       }
    }
};
