FROM node:lts-alpine

WORKDIR /home/node

RUN npm i -g npx ganache-cli

ENV NETWORK_ID 1337
ENV MNEMONIC "gentle leisure predict alpha margin wisdom lucky kitten define define damage badge"
ENV GAS_PRICE "10000000000"
ENV GAS_LIMIT "0xfffffffffff"
ENV NODE_PORT 8545
ENV ADDRESS_NO 11

# Copy the built artifacts
RUN mkdir -p artifacts
COPY build/contracts/* artifacts/
VOLUME artifacts

# Copy the built database with the deployed contracts and seed data
RUN mkdir -p ganache-db
COPY build/db/* ganache-db/
VOLUME ganache-db

# Copy the config file to make the deployed contract addresses available
RUN mkdir -p config
COPY migrationsConfig.json config/
VOLUME config

EXPOSE ${NODE_PORT}

ENTRYPOINT npx ganache-cli \
  --networkId "${NETWORK_ID}" \
  --mnemonic  "${MNEMONIC}"   \
  --accounts  "${ADDRESS_NO}" \
  --gasPrice  "${GAS_PRICE}"  \
  --gasLimit  "${GAS_LIMIT}"  \
  --db   ganache-db \
  --host 0.0.0.0    \
  --port ${NODE_PORT}
