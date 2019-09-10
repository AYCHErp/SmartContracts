const fs = require("fs");
const BN = require("bn.js");
const ethers = require("ethers");

const Token = artifacts.require("DisberseToken");
const ExchangeLogger = artifacts.require("ExchangeLogger");

// seed data
const SRC_CURRENCY = "EUR"
const DST_CURRENCY = "MWK"
const BIN_NAME = "0x" + Buffer.from("121-project").toString("hex")
const TOKEN_DECIMALS = new BN(18);
const MAX_UINT = new BN('2').pow(new BN('256')).sub(new BN('1'));

const configPath = "migrationsConfig.json";
let config;
if (fs.existsSync("../" + configPath)) {
  config = JSON.parse(fs.readFileSync("../" + configPath, "utf8"));
} else {
  config = {};
}

module.exports = async function(deployer, network, accounts) {
  const root = accounts[1];
  const user = accounts[2];
  const userBin = ethers.utils.keccak256(BIN_NAME);

  // deploy token contract
  const tokenName = "Foo";
  await deployer.deploy(Token, tokenName, SRC_CURRENCY, {from:root});
  const token = await Token.deployed();

  // deploy exchange logger
  await deployer.deploy(ExchangeLogger, {from:root});
  const exchangeLogger = await ExchangeLogger.deployed();

  // mint tokens
  await token.methods["mint(address,uint256,bytes32)"]
    (user, MAX_UINT, userBin, {from:root});

  const addresses = {
    "userAddr": user,
    "tokenAddr": token.address,
    "exchangeLoggerAddr": exchangeLogger.address
  }

  if (process.env.MIGRATION === '1') {

    updateConfig(1, addresses)

    const srcValue = 10000;
    const dstValue = 8198860;

    const userBal = new BN(srcValue).mul(new BN(10).pow(TOKEN_DECIMALS));

    // burn tokens
    const burnReceipt = await token.methods["burn(address,uint256,bytes32)"]
      (user, userBal, userBin, {from:root});

    // TODO: is this how we want to do the burn hash?
    const burnEvent = burnReceipt.receipt.rawLogs[0];
    const burnEventData = {
      "transactionHash": burnEvent.transactionHash,
      "address": burnEvent.address,
      "topics": burnEvent.topics
    }

    const burnHash = ethers.utils.keccak256(
      "0x" + Buffer.from(JSON.stringify(burnEventData)).toString("hex")
    );

    // the logger takes the currency symbol as bytes32 so it can be indexed
    // within the LogExchange event
    const dstSymbolBytes32 = ethers.utils.formatBytes32String(DST_CURRENCY);
    const exchangeValue = new BN(dstValue).mul(new BN(10).pow(TOKEN_DECIMALS));

    await exchangeLogger.logExchange(burnHash, dstSymbolBytes32, exchangeValue, {from:root});

    // send some transactions so there are more blocks mined
    for (let i = 0; i < 5; i++) {
      await web3.eth.sendTransaction({to:accounts[3], from:accounts[4], value:1});
    }

  }

  if (process.env.MIGRATION === '2') {

    updateConfig(2, addresses);

    const burnVals = [ 10000, 13000, 25000 ];
    const dstSymbols = [ "FOO", "BAR", "BAZ" ];
    const dstVals = [ 563124, 786567, 35901 ];

    for (let i = 0; i < burnVals.length; i++) {
      // burn tokens
      const burnReceipt = await token.methods["burn(address,uint256,bytes32)"]
        (user, burnVals[i], userBin, {from:root});

      const burnEvent = burnReceipt.receipt.rawLogs[0];
      const burnEventData = {
        "transactionHash": burnEvent.transactionHash,
        "address": burnEvent.address,
        "topics": burnEvent.topics
      }

      const burnHash = ethers.utils.keccak256(
        "0x" + Buffer.from(JSON.stringify(burnEventData)).toString("hex")
      );

      const dstSymbolBytes32 = ethers.utils.formatBytes32String(dstSymbols[i]);
      const exchangeValue = new BN(dstVals[i]).mul(new BN(10).pow(TOKEN_DECIMALS));

      await exchangeLogger.logExchange(burnHash, dstSymbolBytes32, exchangeValue, {from:root});

      await web3.eth.sendTransaction({to:accounts[3], from:accounts[4], value:1});
    }

    // send some transactions so there are more blocks mined
    for (let i = 0; i < 5; i++) {
      await web3.eth.sendTransaction({to:accounts[3], from:accounts[4], value:1});
    }

  }
}

function updateConfig(migration, obj) {
    const migrationId = "migration_" + migration
    config[migrationId] = obj;
    fs.writeFileSync("./" + configPath, JSON.stringify(config), "utf8")
}

function toTokenAmt(amt) {
  return new BN(amt).mul(new BN(10).pow(TOKEN_DECIMALS));
}
