#!/usr/bin/env bash
set -euo pipefail

echo '>>> Update Passwall TProxy Dependencies >>>'
#sed -Ei 's/(^| )iptables-mod-socket( |$)/ /g; s/  +/ /g' package/lean/luci-app-passwall/root/usr/share/passwall/app.sh
echo '<<< Completed Update Passwall TProxy Dependencies <<<'
