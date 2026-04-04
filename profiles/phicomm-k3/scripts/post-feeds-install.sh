#!/usr/bin/env bash
set -euo pipefail

CONFIG_GENERATE='package/base-files/files/bin/config_generate'
AUTOCORE_INDEX='package/lean/autocore/files/arm/index.htm'
ARGON_SCRIPT='package/lean/luci-theme-argon/htdocs/luci-static/argon/js/script.js'
MINIUPNPD_CONFIG='feeds/packages/net/miniupnpd/files/upnpd.config'

if [[ -n "${MODIFY_HOSTNAME:-}" ]]; then
  echo '>>> Update Hostname >>>'
  sed -i "s/hostname='OpenWrt'/hostname='${MODIFY_HOSTNAME}'/g" "${CONFIG_GENERATE}"
  grep -n "hostname='${MODIFY_HOSTNAME}'" "${CONFIG_GENERATE}"
  echo '<<< Completed Update Hostname <<<'
fi

echo '>>> Remove Autocore Benchmark Display >>>'
sed -i 's/ <%=luci.sys.exec("cat \/etc\/bench.log") or ""%>//g' "${AUTOCORE_INDEX}"
echo '<<< Completed Remove Autocore Benchmark Display <<<'

echo '>>> Remove Argon Console Log >>>'
sed -i '/console.log(mainNodeName);/d' "${ARGON_SCRIPT}"
echo '<<< Completed Remove Argon Console Log <<<'

echo '>>> Update MiniUPnPd Lease Path >>>'
sed -i 's/\/var\/upnp.leases/\/tmp\/upnp.leases/g' "${MINIUPNPD_CONFIG}"
grep -n 'upnp_lease_file=/tmp/upnp.leases' "${MINIUPNPD_CONFIG}"
echo '<<< Completed Update MiniUPnPd Lease Path <<<'
