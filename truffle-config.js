/**********************************************************************************************************************
 *
 * File:        truffle-config.js
 * Description:	Truffle configuration file.
 *
 *********************************************************************************************************************/

require("dotenv").config();

const ProviderEngine = require("web3-provider-engine");
const { GanacheSubprovider } = require("@0x/subproviders");
const HDWalletProvider = require("truffle-hdwallet-provider");
const { toWei, toHex } = require("web3-utils");

const compilerConfig = require("./compiler"); // Truffle configuration for solc.
const ganacheLocalPort = 8545;

/**************************************
 *
 * FUNCTIONS:
 *
 *************************************/

/**
 * getDefaultAddress will return the default contract interaction address.
 * This is currently confugured as the first account from ganache-cli.
 *
 * @returns Hex address string.
 */
async function getDefaultAddress() {
  const web3 = new Web3(new web3.providers.HttpProvider(`http://localhost:${ganacheLocalPort}`));
  const addrs = await web3.eth.getAccounts();
  return addrs[0];
}

/**
 * checkEnvKey will make sure that either a private key or a mnemonic seed are defined in the environment.
 * Aborts the script otherwise.
 */
function checkEnvKey() {
  if (!process.env.PRIVATE_KEY && !process.env.MNEMONIC) {
    console.log("ERROR: PRIVATE_KEY or MNEMONIC not found in environment. Please check your .env file.");
    process.exit(1);
  }
}

/**
 * newInfuraProvider will return a new HDWallet provider based on the given network name.
 * The provider will attempt to form a https connection via the Infura network.
 *
 * @param network Name of the network on Infura.
 * @returns HDWalletProvider
 */
function newInfuraProvider(network) {
  if (!process.env.INFURA_API_KEY) {
    console.log("ERROR: INFURA_API_KEY not found in environment. Please check your .env file.");
  }
  return () => {
    return new HDWalletProvider(
      process.env.PRIVATE_KEY || process.env.MNEMONIC,
      `https://${network}.infura.io/v3` + process.env.INFURA_API_KEY,
    )
  }
}

/**
 * newNodesmithProvider will return a new HDWallet provider based on the given network name.
 * The provider will attempt to form a https connection via the Nodesmith network.
 *
 * @param network Name of the network on Nodesmith.
 * @returns HDWalletProvider
 */
function newNodesmithProvider(network) {
  if (!process.env.NODESMITH_API_KEY) {
    console.log("ERROR: INFURA_API_KEY not found in environment. Please check your .env file.");
  }
  return () => {
    return new HDWalletProvider(
      process.env.PRIVATE_KEY || process.env.MNEMONIC,
      `https://ethereum.api.nodesmith.io/v1/${network}/jsonrpc?apiKey=${process.env.NODESMITH_API_KEY}`,
    )
  }
}

/**
 * newNetworkProvider will return a new HDWallet provider based on the given provider name.
 *
 * Supported names are:
 * - "nodesmith"
 * - "infura"
 *
 * The function deafults to "nodesmith".
 *
 * @param providerName Name of the network provider.
 * @param network Name of the network (mainnet, ropsten, etc.)
 * @returns HDWalletProvider
 */
function newNetworkProvider(providerName, network) {
  checkEnvKey();
  switch(providerName) {
    case "infura":
      return newInfuraProvider(network);
    case "nodesmith":
    default:
      // TODO: establish default as self hosted node?
      return newNodesmithProvider(network);
  }
}


/**************************************
 *
 * SCRIPT:
 *
 *************************************/

/*
 * Confirgure the ProviderEngine, add ganache subprovider.
 * Run the provider engine.
 */
const providerEngine = new ProviderEngine();
const ganacheSubprovider = new GanacheSubprovider();
providerEngine.addProvider(ganacheSubprovider);
providerEngine.start((err) => {
  if (!err) {
    console.log(err);
    process.exit(1);
  }
});

/**
 * HACK: Truffle providers should have `send` function, while `ProviderEngine` creates providers with `sendAsync`,
 * but it can be easily fixed by assigning `sendAsync` to `send`.
 */
providerEngine.send = providerEngine.sendAsync.bind(providerEngine);

/**
 * Determine provider from the environment.
 * Can be:
 * - nodesmith
 * - infura
 **/
const networkProvider = process.env.NETWORK_PROVIDER;

const rinkebyProvider = newNetworkProvider(networkProvider,"rinkeby");
const ropstenProvider = newNetworkProvider(networkProvider, "ropsten");
const goerliProvider = newNetworkProvider(networkProvider, "goerli");

module.exports = {
  compilers: {
    solc: {
      version: compilerConfig.version,
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
        evmVersion: "petersburg",
        },
    },
  },
  mocha: {
    bail: true,
    enableTimeounts: false,
    reporter: "spec",
  },
  networks: {
    development: {
      provider: providerEngine,
      gas: 6500000,
      gasPrice: toHex(toWei('1', 'gwei')),
      port: ganacheLocalPort,
      network_id: "*", // eslint-disable-line camelcase
    },
    ganache: {
      host: "localhost",
      port: 8545,
      network_id: "*"
    },
    docker: {
      // provider: ganacheSubprovider,
      host: "localhost",
      gas: 6500000,
      gasPrice: toHex(toWei('1', 'gwei')),
      port: ganacheLocalPort,
      network_id: process.env.NETWORK_ID, // eslint-disable-line camelcase
    },
    ropsten: {
      provider: ropstenProvider,
      gas: 6000000,
      gasPrice: toHex(toWei('10', 'gwei')),
      network_id: '3', // eslint-disable-line camelcase
      skipDryRun: true,
    },
    rinkeby: {
      provider: rinkebyProvider,
      gas: 6000000,
      gasPrice: toHex(toWei('10', 'gwei')),
      network_id: '4', // eslint-disable-line camelcase
      skipDryRun: true,
    },
    goerli: {
      provider: goerliProvider,
      gas: 6000000,
      gasPrice: toHex(toWei('10', 'gwei')),
      network_id: '5', // eslint-disable-line camelcase
      skipDryRun: true,
    },
 }
};
