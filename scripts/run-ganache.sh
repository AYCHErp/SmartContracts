#!/bin/env sh

###############################################################################
#
# File: run-ganache.sh
#
# Description: Run a ganache-cli instance with the default configuration.
#
###############################################################################

#######################################
#
# CONFIGURATION:
#
#######################################

VERSION="0.2.0"

GANACHE_BIN="node_modules/.bin/ganache-cli" # Path to ganache-cli binary.
GANACHE_PORT="8545" # Default port for running ganache-cli.
TRUFFLE_BIN="node_modules/.bin/truffle"	# Path to truffle binary.

# 1MM eth (in wei). Needed for potential high-value tests.
GANACHE_START_ETH=1000000000000000000000000
GANACHE_NETWORK_ID=1337 # Network id used by ganache-cli.
GANACHE_GAS_LIMIT="0xfffffffffff" # Gas limit on transactions.

#######################################
##
## FUNCTIONS:
##
#######################################

trap "cleanup" INT TERM

# die will print an error message and exit with a generic error code.
function die {
  [ "${#}" -ne 0 ] && printf "${*}\n"; exit 1
}

# cleanup will perform cleanup after ganache-cli finishes
function cleanup {
  # TODO: do any remaining cleanup.
  printf "\n\n=) Finished!\n"
}

# check_port will return success if a process is running on the configured port.
function checkPort {
  command -v fuser > /dev/null 2>&1 &&
    fuser "${GANACHE_PORT}/tcp" > /dev/null 2>&1
}

# start_ganache will start a local ganache instance and set the GANACHE_PID.
function startGanache {

  # Define local accounts with starting ether.
  local accounts=(
    --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501200,${GANACHE_START_ETH}"
    --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501201,${GANACHE_START_ETH}"
    --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501202,${GANACHE_START_ETH}"
    --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501203,${GANACHE_START_ETH}"
    --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501204,${GANACHE_START_ETH}"
    --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501205,${GANACHE_START_ETH}"
    --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501206,${GANACHE_START_ETH}"
    --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501207,${GANACHE_START_ETH}"
    --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501208,${GANACHE_START_ETH}"
    --account="0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501209,${GANACHE_START_ETH}"
  )

  "${GANACHE_BIN}" --networkId "${GANACHE_NETWORK_ID}" --gasLimit "${GANACHE_GAS_LIMIT}" "${accounts[@]}"
}

#######################################
#
# SCRIPT:
#
#######################################

printf "Running ganache script: $(date -R)\n"
printf "\n1) Checking environment\n\n"

# Check dependencies:
# - node
# - ganache-cli
# - truffle
#
command -v node > /dev/null 2>&1 ||
  die "ERROR: missing node. Make sure nodejs is installed on your system.\n"
[ -x ${GANACHE_BIN} ] ||
  die "ERROR: missing ganache-cli. Make sure to run npm install.\n"
[ -x ${TRUFFLE_BIN} ] ||
  die "ERROR: missing truffle. Make sure to run npm install.\n"
printf "OK\n"

printf "\n2) Running ganache-cli instance\n\n"

if checkPort; then
  die "Existing ganache-cli instance running on port ${GANACHE_PORT}\n"
else
  startGanache
fi

