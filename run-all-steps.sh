#!/bin/bash

set -euo pipefail

if [[ $# -le 1 ]]; then
  echo "Invalid arguments. Use: $0 SRC_REPOSITORY \
CONVERTED_REPOSITORY [--redirect-fast-export-stderr FILE]"
  exit 1
fi

SRC_REPOSITORY="$1"
CONVERTED_REPOSITORY="$2"
shift 2

if [[ ! -d "${SRC_REPOSITORY}" ]]; then
  echo "Invalid argument. ${SRC_REPOSITORY} has to be a directory."
  exit 1
fi

if [[ -e "${CONVERTED_REPOSITORY}" ]]; then
  echo "Invalid argument. ${CONVERTED_REPOSITORY} may not exist."
  exit 1
fi

TEMP_DIR="$(mktemp -d)"
echo "Storing intermediate cleaned-up repository under ${TEMP_DIR}"
# Generate a path to a non-existing temporary directory.
CLEANED_REPOSITORY="${TEMP_DIR}/cleaned"
BASE="$(realpath "$(dirname "$(readlink -f "$0")")")"
SETUP_MERCURIAL="${BASE}/setup-mercurial.sh"
SETUP_FAST_EXPORT="${BASE}/setup-fast-export.sh"
RUN_CLEANUP="${BASE}/run-cleanup.sh"
RUN_CONVERSION="${BASE}/run-conversion.sh"

if ! /bin/bash "${SETUP_MERCURIAL}"; then
  echo "Error during the Mercurial setup."
  exit 2
fi

if ! /bin/bash "${SETUP_FAST_EXPORT}"; then
  echo "Error during the 'fast-export' setup."
  exit 2
fi

if ! "${RUN_CLEANUP}" "${SRC_REPOSITORY}" "${CLEANED_REPOSITORY}"; then
  echo "Cleanup failed."
  exit 2
fi

if ! "${RUN_CONVERSION}" "${CLEANED_REPOSITORY}" "${CONVERTED_REPOSITORY}" $@; then
  echo "Conversion failed."
  exit 2
fi

echo "Removing intermediate cleaned-up repository."
rm -r "${TEMP_DIR}"
