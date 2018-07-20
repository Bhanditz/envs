#!/usr/bin/env bash

# Bash script to set up an anaconda python-based deep learning environment
# that has support for pytorch, tensorflow, pycaffe in the same environment,
# long with juypter, scipy etc.

# This should not require root.  However, it does copy and build a lot of
# binaries into your ~/.conda directory.  If you do not want to store
# these in your homedir disk, then ~/.conda can be a symlink somewhere else.
# (At MIT CSAIL, you should symlink ~/.conda to a directory on NFS or local
# disk instead of leaving it on AFS, or else you will exhaust your quota.)

# Start from parent directory of script
cd "$(dirname "$(dirname "$(readlink -f "$0")")")"

# Default RECIPE 'p2t3' can be overridden by 'RECIPE=foo setup.sh'
RECIPE=${RECIPE:-p2t3}
# Default ENV_NAME 'p2t3' can be overridden by 'ENV_NAME=foo setup.sh'
ENV_NAME="${ENV_NAME:-${RECIPE}}"
echo "Creating conda environment ${ENV_NAME}"

if [[ ! $(type -P conda) ]]
then
    echo "conda not in PATH"
    echo "read: https://conda.io/docs/user-guide/install/index.html"
    exit 1
fi

if df "${HOME}/.conda" --type=afs > /dev/null 2>&1
then
    echo "Not installing: your ~/.conda directory is on AFS."
    echo "Use 'ln -s /some/nfs/dir ~/.conda' to avoid using up your AFS quota."
    exit 1
fi

# Uninstall existing environment
source deactivate
rm -rf ~/.conda/envs/${ENV_NAME}
rm -rf pytorch torchvision

# Build new environment: torch and torch vision from source
conda env create --name=${ENV_NAME} -f script/${RECIPE}.yml
source activate ${ENV_NAME}
export CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"
