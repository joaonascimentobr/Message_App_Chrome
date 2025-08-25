#!/usr/bin/env bash
set -euo pipefail

# setup-udev.sh
# Instala regras udev para dispositivos Android no HOST (não no container).
# - Copia um arquivo 51-android.rules do projeto (se existir) OU cria um padrão com vendors comuns.
# - Garante grupo plugdev, recarrega udev, e testa adb.
#
# Uso:
#   ./scripts/setup-udev.sh [CAMINHO_REGRAS]
#
# Onde CAMINHO_REGRAS (opcional) é um arquivo como infra/51-android.rules no seu repo.
# Se omitido, o script cria um arquivo padrão com vendors populares.

RULES_SRC="${1:-}"
RULES_DST="/etc/udev/rules.d/51-android.rules"

require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo ">> Este script precisa de sudo/ROOT. Reexecutando com sudo..."
    exec sudo -E "$0" "$@"
  fi
}

ensure_deps() {
  # adb é útil para testar; se não existir, tenta instalar (Ubuntu/Debian).
  if ! command -v adb >/dev/null 2>&1; then
    echo ">> 'adb' não encontrado. Instalando android-tools-adb..."
    apt-get update -y
    apt-get install -y --no-install-recommends android-tools-adb
  fi
}

make_default_rules() {
  cat <<'EOF'
# Google (Pixel / Nexus)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="plugdev"

# Samsung
SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="plugdev"

# Xiaomi / Redmi / Poco
SUBSYSTEM=="usb", ATTR{idVendor}=="2717", MODE="0666", GROUP="plugdev"

# OnePlus
SUBSYSTEM=="usb", ATTR{idVendor}=="2a70", MODE="0666", GROUP="plugdev"

# Motorola
SUBSYSTEM=="usb", ATTR{idVendor}=="22b8", MODE="0666", GROUP="plugdev"

# Huawei / Honor
SUBSYSTEM=="usb", ATTR{idVendor}=="12d1", MODE="0666", GROUP="plugdev"

# Sony
SUBSYSTEM=="usb", ATTR{idVendor}=="0fce", MODE="0666", GROUP="plugdev"

# LG
SUBSYSTEM=="usb", ATTR{idVendor}=="1004", MODE="0666", GROUP="plugdev"

# HTC
SUBSYSTEM=="usb", ATTR{idVendor}=="0bb4", MODE="0666", GROUP="plugdev"

# ZTE
SUBSYSTEM=="usb", ATTR{idVendor}=="19d2", MODE="0666", GROUP="plugdev"

# Oppo / Realme
SUBSYSTEM=="usb", ATTR{idVendor}=="22d9", MODE="0666", GROUP="plugdev"
EOF
}

install_rules() {
  echo ">> Instalando regras em ${RULES_DST} ..."
  if [[ -n "${RULES_SRC}" ]]; then
    if [[ ! -f "${RULES_SRC}" ]]; then
      echo "!! Arquivo informado não existe: ${RULES_SRC}"
      exit 1
    fi
    cp -f "${RULES_SRC}" "${RULES_DST}"
  else
    # Gera regras padrão
    make_default_rules > "${RULES_DST}"
  fi

  chmod a+r "${RULES_DST}"
}

reload_udev() {
  echo ">> Recarregando udev..."
  udevadm control --reload-rules
  udevadm trigger
}

ensure_plugdev() {
  # Garante que o grupo plugdev existe
  if ! getent group plugdev >/dev/null; then
    echo ">> Criando grupo plugdev..."
    groupadd plugdev
  fi

  # Adiciona usuário atual ao plugdev (se possível detectar)
  # Nota: quando rodando com sudo, $SUDO_USER é o usuário que chamou o sudo.
  local TARGET_USER="${SUDO_USER:-$USER}"
  if [[ -n "${TARGET_USER}" ]]; then
    echo ">> Adicionando ${TARGET_USER} ao grupo plugdev (se ainda não estiver)..."
    usermod -aG plugdev "${TARGET_USER}" || true
    echo ">> Para aplicar grupo imediatamente: execute 'newgrp plugdev' como ${TARGET_USER} ou faça logout/login."
  fi
}

hint_detect_vendor() {
  echo ">> Dica: para descobrir seu Vendor ID, conecte o celular e rode: lsusb"
  echo ">> Saída típica: 'ID 18d1:4ee7' => Vendor ID = 18d1 (adicione/ajuste na regra se necessário)."
}

test_adb() {
  echo ">> Testando ADB (conecte e autorize o dispositivo no aparelho, se necessário)..."
  # Tenta reiniciar o servidor adb para pegar novas permissões
  adb kill-server >/dev/null 2>&1 || true
  adb start-server
  sleep 1
  adb devices
  echo ">> Se aparecer 'unauthorized', aceite o pop-up de depuração no celular e rode 'adb devices' novamente."
}

main() {
  require_root "$@"
  ensure_deps
  install_rules
  reload_udev
  ensure_plugdev
  hint_detect_vendor
  test_adb
  echo ">> Pronto! Regras udev aplicadas em ${RULES_DST}."
}

main "$@"
