#!/bin/bash

set -euo pipefail

if [[ $# -le 1 ]]; then
  echo "Invalid arguments. Use: $0 [SRC REPOSITORY] \
[CONVERTED REPOSITORY] (--redirect-fast-export-stderr FILE)"
  exit 1
fi

SRC_REPOSITORY="$1"
CONVERTED_REPOSITORY="$2"
shift 2

if [[ ! -d "$SRC_REPOSITORY" ]]; then
  echo "Invalid argument. $SRC_REPOSITORY has to be a directory."
  exit 1
fi

if [[ -e "$CONVERTED_REPOSITORY" ]]; then
  echo "Invalid argument. $CONVERTED_REPOSITORY may not exist."
  exit 1
fi

TEMP_DIR="$(mktemp -d)"
echo "Storing intermediate repository under $TEMP_DIR"
# Generate a path to a non-existing temporary directory.
INTERMEDIATE_REPOSITORY="$TEMP_DIR/intermediate"
BASE=$(realpath $(dirname $(readlink -f $0)))
SETUP_CLEANUP="${BASE}/setup-cleanup.sh"
SETUP_CONVERSION="${BASE}/setup-conversion.sh"
RUN_CLEANUP="${BASE}/run-cleanup.sh"
RUN_CONVERSION="${BASE}/run-conversion.sh"

if ! /bin/bash ${SETUP_CLEANUP}; then
  echo "Error during the setup for the cleaning script."
  exit 2
fi

if ! /bin/bash ${SETUP_CONVERSION}; then
  echo "Error during the setup for the conversion script."
  exit 2
fi

if ! ${RUN_CLEANUP} "$SRC_REPOSITORY" "$INTERMEDIATE_REPOSITORY"; then
  echo "Cleanup failed."
  exit 2
fi

if ! ${RUN_CONVERSION} "$INTERMEDIATE_REPOSITORY" "$CONVERTED_REPOSITORY" $@; then
  echo "Conversion failed."
  exit 2
fi

echo "Removing intermediate repository."
rm -r "$TEMP_DIR"
