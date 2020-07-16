#!/bin/bash

BASE="$(dirname "$(readlink -f "$0")")"
SETUP_CLEANUP="${BASE}/setup-cleanup.sh"
FAST_EXPORT_REPO="${BASE}/data/fast-export"
FAST_EXPORT_VERSION="v200213-23-g44c50d0"


if ! /bin/bash "${SETUP_CLEANUP}"; then
  echo "Error during Mercurial setup."
fi

if ! command -v git > /dev/null; then
    echo "Missing requirement: git"
    exit 2
fi

echo "Setup fast-export"
if [[ ! -d "${FAST_EXPORT_REPO}" ]]; then
    git clone https://github.com/frej/fast-export.git "${FAST_EXPORT_REPO}"
    git -C "${FAST_EXPORT_REPO}" checkout "${FAST_EXPORT_VERSION}"
fi
