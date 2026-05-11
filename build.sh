#!/usr/bin/env bash
set -euo pipefail

# absolute path to script's directory not where you ran it
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR"

# activate python venv
source "$SCRIPT_DIR/.venv/bin/activate"

# source Zephyr SDK env
source "$SCRIPT_DIR/zephyr_env.sh"

# make sure west to use repo dir
cd "$ROOT_DIR"

# start timer
SECONDS=0

build_target() {
  local build_dir="$1"
  local shield="$2"
  local controller="$3"

  west build \
    -d "$build_dir" \
    -p always \
    -b "$controller" \
    -s zmk/app \
    -- \
    -DSHIELD="$shield" \
    -DZMK_CONFIG="$ROOT_DIR/config" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
}

build_target build/left charybdis_left nice_nano_v2
build_target build/right charybdis_right nice_nano_v2
# build_target build/settings_reset settings_reset nice_nano_v2

mkdir -p output

# copy firmware files to output directory
cp build/left/zephyr/zmk.uf2 output/charybdis_left.uf2
cp build/right/zephyr/zmk.uf2 output/charybdis_right.uf2

[ -f build/settings_reset/zephyr/zmk.uf2 ] && cp build/settings_reset/zephyr/zmk.uf2 output/settings_reset.uf2

echo -e "\n----------------------------------------------"
echo -e "\n Build done. (took ${SECONDS}s)"
echo -e "\n uf2 files are copied to the output directory."
echo -e "\n----------------------------------------------"
