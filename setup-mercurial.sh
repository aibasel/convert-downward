#!/bin/bash

# Check requirements for installing the right Mercurial version in a
# Python virtual environment.
MISSING_REQUIREMENTS=""

if ! command -v python3 > /dev/null; then
    MISSING_REQUIREMENTS="${MISSING_REQUIREMENTS}\nMissing requirement: python3.6+"
elif [[ `python3 -c "import sys; print(sys.version_info < (3,6))"` = "True" ]];then
    MISSING_REQUIREMENTS="${MISSING_REQUIREMENTS}\nMissing requirement: python3.6+"
fi

if ! `python3 -c "import ensurepip" 2> /dev/null`; then
    MISSING_REQUIREMENTS="${MISSING_REQUIREMENTS}\nMissing requirement: \
ensurepip module missing for python3. For Debian/Ubuntu use \
'sudo apt install python3-venv'"
fi

if [[ ${MISSING_REQUIREMENTS} != "" ]]; then
    echo -e ${MISSING_REQUIREMENTS}
    exit 2
fi

# Setup a Python virtual environment with the right Mercurial version
BASE="$(realpath "$(dirname "$(readlink -f "$0")")")"
VIRTUALENV="${BASE}/data/py3-env"
MERCURIAL_VERSION="mercurial==5.2"

echo "Setup python virtual environment."
if [[ ! -d "${VIRTUALENV}" ]]; then
    python3 -m venv "${VIRTUALENV}"
    source "${VIRTUALENV}/bin/activate"
    pip install --upgrade pip wheel
    pip install "${MERCURIAL_VERSION}"
    echo `hg --version | grep "version"`
fi
echo "Done."
