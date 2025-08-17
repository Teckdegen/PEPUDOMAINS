require("@nomicfoundation/hardhat-toolbox");

module.exports = {
    solidity: "0.8.20",
    networks: {
        'pepe-unchained-mainnet': {
            url: 'https://rpc-pepu-v2-mainnet-0.t.conduit.xyz',
            chainId: 97741,
            accounts: ["private-key"],
        },
    },
    etherscan: {
        apiKey: {
            'pepe-unchained-mainnet': 'empty'
        },
        customChains: [{
            network: "pepe-unchained-mainnet",
            chainId: 97741,
            urls: {
                apiURL: "https://explorer-pepu-v2-mainnet-0.t.conduit.xyz/api",
                browserURL: "https://explorer-pepu-v2-mainnet-0.t.conduit.xyz:443"
            }
        }]
    }
}