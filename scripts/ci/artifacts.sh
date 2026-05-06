#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/ci/lib.sh
source "${SCRIPT_DIR}/lib.sh"

OPENWRT_ROOT="${GITHUB_WORKSPACE}/openwrt"

resolve_firmware_dir() {
  : "${TARGET:?TARGET is required}"
  : "${SUBTARGET:?SUBTARGET is required}"

  local dir="${OPENWRT_ROOT}/bin/targets/${TARGET}/${SUBTARGET}"

  if [[ ! -d "$dir" ]]; then
    dir="$(find "${OPENWRT_ROOT}/bin/targets" -mindepth 2 -maxdepth 2 -type d | head -n1)"
  fi

  [[ -n "$dir" && -d "$dir" ]] || {
    log_error "Firmware directory not found"
    exit 1
  }

  echo "$dir"
}

collect_firmware() {
  : "${PROFILE_ID:?PROFILE_ID is required}"
  : "${FILE_DATE:?FILE_DATE is required}"

  group_start "Artifacts: Collect Firmware"

  local firmware_dir
  firmware_dir="$(resolve_firmware_dir)"

  # 1. 進入 bin 目錄準備提取 IPK
  cd "${OPENWRT_ROOT}/bin"
  mkdir -p "collected_packages"
  
  # 2. 搜尋並複製所有編譯出來的 .ipk (包括 K3 Screen)
  # 這樣會保留驅動包和界面包
  find packages/ targets/ -name "*.ipk" -exec cp {} "collected_packages/" \;

  # 3. 回到固件目錄，但不要刪除 packages 目錄 (或者改為移動到我們剛建的文件夾)
  cd "$firmware_dir"
  # rm -rf packages  <-- 註釋掉或刪除這一行，防止它刪除包

  local artifact_name="openwrt-${PROFILE_ID}-${FILE_DATE}"

  # 4. 重新定義環境變量，讓 YAML 上傳整個 collected_packages 目錄
  append_env "FIRMWARE_DIR" "${OPENWRT_ROOT}/bin/collected_packages"
  append_env "ARTIFACT_NAME" "${artifact_name}-packages"

  log_info "IPK Collection dir: ${OPENWRT_ROOT}/bin/collected_packages"
  log_info "Artifact name: ${artifact_name}-packages"

  group_end
}


case "${1:-}" in
  collect-firmware)
    collect_firmware
    ;;
  *)
    log_error "Unknown command: ${1:-}"
    exit 1
    ;;
esac
