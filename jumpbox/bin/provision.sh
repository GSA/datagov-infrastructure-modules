#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

sudo apt update

sudo apt install -y \
  git \
  python3-dev \
  python-virtualenv


# Clone the repo
git clone https://github.com/GSA/datagov-deploy.git

# Create a virtualenv
virtualenv venv
source venv/bin/activate
pip install -U setuptools
pip install -r datagov-dedupe/requirements.txt

# Configure SSH to ignore host keys
cat <<EOF > ~/.ssh/config
StrictHostKeyChecking=no
EOF
