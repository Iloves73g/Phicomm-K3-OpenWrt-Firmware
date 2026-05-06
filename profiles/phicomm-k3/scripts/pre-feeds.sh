#!/usr/bin/env bash
set -euo pipefail

append_feed_if_missing() {
  local line="$1"
  grep -qxF "$line" feeds.conf.default || echo "$line" >> feeds.conf.default
}

clone_repo() {
  local repo_url="$1"
  local branch="$2"
  local dst="$3"

  rm -rf "$dst"

  if [[ -n "$branch" ]]; then
    git clone -b "$branch" --single-branch --depth 1 "$repo_url" "$dst"
  else
    git clone --depth 1 "$repo_url" "$dst"
  fi
}

FIRMWARE_VARIANT='69027'
FIRMWARE_PATH='package/lean/k3-brcmfmac4366c-firmware/files/lib/firmware/brcm/brcmfmac4366c-pcie.bin'

echo '>>> Add Passwall Feed >>>'
append_feed_if_missing 'src-git passwall https://github.com/openwrt-passwall/openwrt-passwall-packages'
echo '<<< Completed Add Passwall Feed <<<'

echo '>>> Clone Passwall Package >>>'
clone_repo 'https://github.com/openwrt-passwall/openwrt-passwall' 'main' 'package/lean/luci-app-passwall'
echo '<<< Completed Clone Passwall Package <<<'

echo '>>> Clone Argon Theme >>>'
clone_repo 'https://github.com/jerrykuku/luci-theme-argon' 'master' 'package/lean/luci-theme-argon'
echo '<<< Completed Clone Argon Theme <<<'

echo '>>> Clone K3 Screen App >>>'
clone_repo 'https://github.com/yangxu52/luci-app-k3screenctrl.git' '' 'package/lean/luci-app-k3screenctrl'
echo '<<< Completed Clone K3 Screen App <<<'

echo '>>> Clone K3 Screen Driver >>>'
clone_repo 'https://github.com/yangxu52/k3screenctrl_build.git' '' 'package/lean/k3screenctrl'
echo '<<< Completed Clone K3 Screen Driver <<<'

echo '>>> Replace Wireless Firmware >>>'
mkdir -p "$(dirname "$FIRMWARE_PATH")"
wget -nv "https://github.com/yangxu52/Phicomm-k3-Wireless-Firmware/raw/master/brcmfmac4366c-pcie.bin.${FIRMWARE_VARIANT}" -O "$FIRMWARE_PATH"
echo '<<< Completed Replace Wireless Firmware <<<'
