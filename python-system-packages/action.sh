#!/usr/bin/env bash

set -euo pipefail

py_version="${PYTHON_VERSION:-}"
if [ -z "$py_version" ]; then
  echo "PYTHON_VERSION is empty. Skipping system package installation."
  exit 0
fi

py_mm="$(echo "$py_version" | awk -F. '{print $1 "." $2}')"
py_dev_pkg="python${py_mm}-dev"

sudo apt-get update
sudo apt-get install -y libcairo2-dev pkg-config
if apt-cache show "$py_dev_pkg" >/dev/null 2>&1; then
  sudo apt-get install -y "$py_dev_pkg"
else
  # Try deadsnakes for newer Python versions on Ubuntu 22.04
  sudo apt-get install -y software-properties-common
  sudo add-apt-repository -y ppa:deadsnakes/ppa
  sudo apt-get update
  if apt-cache show "$py_dev_pkg" >/dev/null 2>&1; then
    sudo apt-get install -y "$py_dev_pkg"
  else
    sudo apt-get install -y python3-dev
  fi
fi

py_inc="$(python -c 'import sysconfig; print(sysconfig.get_path("include"))')"
sys_inc="/usr/include/python${py_mm}"
echo "Python include (active): $py_inc"
echo "Python include (system): $sys_inc"
if [ -d "$py_inc" ]; then
  ls -la "$py_inc"
fi
if [ -d "$sys_inc" ]; then
  ls -la "$sys_inc"
fi
if [ -f "$sys_inc/Python.h" ] && [ ! -f "$py_inc/Python.h" ]; then
  sudo mkdir -p "$py_inc"
  sudo cp -a "$sys_inc/." "$py_inc/"
fi
if [ ! -f "$py_inc/Python.h" ]; then
  echo "Python.h not found for Python ${py_mm}."
  echo "Expected at: $py_inc/Python.h or $sys_inc/Python.h"
  exit 1
fi
if [ -f "$sys_inc/Python.h" ]; then
  {
    echo "PYTHON_SYS_INCLUDE=$sys_inc"
    echo "CFLAGS=-I$sys_inc"
    echo "CPPFLAGS=-I$sys_inc"
    echo "C_INCLUDE_PATH=$sys_inc"
    echo "CPATH=$sys_inc"
  } >> "$GITHUB_ENV"
fi
