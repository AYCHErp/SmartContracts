#!/usr/bin/env sh

###############################################################################
#
# File: migrate.sh
#
# Description: Migration script. Run truffle migrate to the given network.
#
###############################################################################

#######################################
#
# CONFIGURATION:
#
#######################################

VERSION="0.2.0" # Script version.

TRUFFLE_BIN="node_modules/.bin/truffle" # Path to truffle binary.

#######################################
#
# FUNCTIONS:
#
#######################################

# die will print an error message and exit with a generic error code.
function die {
  [ ${#} -ne 0 ] && printf "${*}\n"; exit 1;
}

#######################################
#
# SCRIPT:
#
#######################################

printf "Starting migration at: $(date -R)\n";

printf "\n1) Setting up environment\n\n"

command -v node > /dev/null 2>&1 ||
  die "ERROR: node not found. Make sure to install nodejs or run nvm"

[ -x "${TRUFFLE_BIN}" ] ||
  die "ERROR: could not find truffle binary. Make sure to run npm install"

NETWORK="${1:-docker}"

printf "OK\n"

printf "\n1) Running migration to the '${NETWORK}' network\n\n"

"${TRUFFLE_BIN}" migrate --reset --network "${NETWORK}"

printf "\n\n=) Finished!\n"

