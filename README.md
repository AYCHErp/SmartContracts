# 121 Smart Contracts
An abbreviated version of the Disberse smart contract system used to generate a docker image for the 121 Project testing ([disberse/121-bchain](https://cloud.docker.com/repository/registry-1.docker.io/disberse/121-bchain)).

The current seed data options are defined in [migrations/2\_deploy\_contracts](./migrations/2_deploy_contracts.js). You can add your own seed data, or we are happy to add any data that's needed for testing.

#### Contracts overview
- [DisberseToken](./contracts/DisberseToken.sol): Matches the API of the contracts used to manage and trace funds within the Disberse platform.

- [ExchangeLogger](./contracts/ExchangeLogger.sol): Used to log information on exchanges rates for currency exchanges performed outside of the Disberse platform.

# Usage

#### Generate the docker image
- `npm run dockerize`

#### Run a specific migration
- `npm run migrate:{migration_number}`
- where `{migration_number}` represents the specific seed data you would like to deploy. You must be running an Ethereum node locally on port 8545.
