#!/usr/bin/env sh

NODE_HOME=`dirname "$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"`
source "$NODE_HOME/.env";

NETWORK_ID=${NETWORK_ID:-1337}
MNEMONIC=${MNEMONIC:-gentle leisure predict alpha margin wisdom lucky kitten define define damage badge}
GAS_PRICE=${GAS_PRICE:-10000000000}
GAS_LIMIT=${GAS_LIMIT:-0xfffffffffff}
NODE_HOST=${NODE_HOST:-0.0.0.0}
NODE_PORT=${NODE_PORT:-8545}
GANACHE_DB_PATH=${GANACHE_DB_PATH:-qrac}
ADDRESS_NO=${ADDRESS_NO:-11}
# CONFIG_PATH=${CONFIG_PATH}:-config

GANACHE_PID=

echo "GANAHCE_DN_PATH: ${GANACHE_DB_PATH}"

trap "cleanup" INT TERM

# die will print an error message and exit with a generic error code.
function die {
  [ "${#}" -ne 0 ] && printf "${*}\n"; exit 1
}

# cleanup will perform cleanup after ganache-cli finishes
function cleanup {
  kill $GANACHE_PID;
  printf "\n\n=) Finished!\n"
}

# check_port will return success if a process is running on the configured port.
function checkPort {
  netstat -ltun | grep ":$NODE_PORT " > /dev/null 2>&1
}

function killGanache {
  echo "Shutting down node..."
  kill $GANACHE_PID;
}

function startGanache {
  echo "Ganache directory cleanup"
  rm -rf "${NODE_HOME}/${GANACHE_DB_PATH}/*";

  # TODO@pax: NPX maybe?
  "$NODE_HOME/node_modules/.bin/ganache-cli" \
    --networkId "${NETWORK_ID}" \
    --mnemonic  "${MNEMONIC}"   \
    --accounts  "${ADDRESS_NO}" \
    --gasPrice  "${GAS_PRICE}"  \
    --gasLimit  "${GAS_LIMIT}"  \
    --db   "${NODE_HOME}/${GANACHE_DB_PATH}" \
    --host "${NODE_HOST}" \
    --port "${NODE_PORT}" &

  GANACHE_PID=$!
  echo "Ganache running as PID $GANACHE_PID";

  echo "Waiting for Ganache to initialize";
  while ! checkPort ; do sleep .5; echo -n "."; done; echo;
}

function runMigrations {
    for migration in ${MIGRATIONS[@]}; do
        export MIGRATION=$migration
        echo "Running migration $MIGRATION"
        "${NODE_HOME}/scripts/migrate.sh"
    done
}

if checkPort; then
  die "Existing ganache-cli instance running on port ${NODE_PORT}\n"
else
  mkdir -p "${NODE_HOME}/${GANACHE_DB_PATH}"
  # mkdir -p "${NODE_HOME}/${CONFIG_PATH}"
  startGanache
fi

echo "Deploying contracts to node..."
if [ ! -f ./migrationsList.sh ]; then
    die "No migrationsList.sh file exists";
else
    source "./migrationsList.sh"
    runMigrations
fi

killGanache

echo "Building Docker image with the generated data"
docker build -t disberse/121-bchain:latest "$NODE_HOME"
