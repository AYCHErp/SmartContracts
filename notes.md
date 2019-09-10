# Disberse Identities

## Usage
### Dependencies
It is currently in a [Dapptools](https://dapp.tools/) project, so you will need to install dapptools to run it. Their website/Github have more info on installation, but on Unix-based systems you can download and install it by running:  
`curl https://dapp.tools/install | sh`

### Overview
The contracts are all in the src/ directory. The test contracts are in src/test/

### Clone and Use
`git clone git@github.com:nsward/disberse-identities.git`

#### Compile
`make build`
#### Test
`make test`
#### Deploy
`export ETH_FROM=0x1e1e0b9af1f65473878c41361385b19762751e5a`  
`make build`  
`make deploy`  
  
By default, contract(s) are deployed on a local testchain running on localhost port 8545, and the ETH_FROM address shoould be an unlocked account provided by the testchain. To deploy to a testchain on a different port, set `ETH_RPC_URL` in the Makefile. To use a local keystore account, comment out the `ETH_RPC_ACCOUNTS` line in the Makefile and export ETH_KEYSTORE=/path/to/keystore. Currently, make deploy only deploys the base Identity contract.
