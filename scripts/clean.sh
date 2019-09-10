#!/bin/env sh

###############################################################################
#
# File: clean.sh
#
# Description:	Clean the project: removes build artifacts, coverage reports
# and other similar files.
#
###############################################################################

#######################################
#
# CONFIG:
#
#######################################

VERSION="0.2.0" # Script version.

BUILD_ARTIFACTS_DIR="build" # Path to the build artifacs.

#######################################
#
# SCRIPT:
#
#######################################

printf "\n1) Cleaning build artifacts from ${BUILD_ARTIFACTS_DIR}...\n"
[ -d "${BUILD_ARTIFACTS_DIR}" ] && rm -rf "${BUILD_ARTIFACTS_DIR}"

printf "\n=) Finished!\n"
