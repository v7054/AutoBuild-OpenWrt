#!/usr/bin/env bash

ARCH="${1:-arm64}"
SC_URL='https://raw.githubusercontent.com/juewuy/ShellCrash/master'
PRESET_DIR='files/usr/share/ShellCrash'
MIHOMO_REPO='MetaCubeX/mihomo'
DAT_REPO='MetaCubeX/meta-rules-dat'
MIHOMO_TAG="$(curl -s "https://api.github.com/repos/${MIHOMO_REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')"
MIHOMO_FILE="mihomo-linux-${ARCH}-${MIHOMO_TAG}.gz"
MIHOMO_URL="https://github.com/${MIHOMO_REPO}/releases/download/${MIHOMO_TAG}/${MIHOMO_FILE}"
DAT_URL="https://github.com/${DAT_REPO}/releases/latest/download"

mkdir -p "${PRESET_DIR}"
curl -fsSL "${SC_URL}/bin/ShellCrash.tar.gz" | tar -zxf - -C "${PRESET_DIR}"

curl -fsSL "${MIHOMO_URL}" | gzip -dc > "${PRESET_DIR}/CrashCore"
chmod +x "${PRESET_DIR}/CrashCore"
tar -zcf "${PRESET_DIR}/CrashCore.tar.gz" -C "${PRESET_DIR}" CrashCore
rm -f "${PRESET_DIR}/CrashCore"

curl -fsSLo "${PRESET_DIR}/GeoIP.dat" "${DAT_URL}/geoip.dat"
curl -fsSLo "${PRESET_DIR}/GeoSite.dat" "${DAT_URL}/geosite.dat"
curl -fsSLo "${PRESET_DIR}/Country.mmdb" "${DAT_URL}/country.mmdb"

mkdir -p "${PRESET_DIR}"/{configs,yamls,jsons,tools,task,ruleset}
touch "${PRESET_DIR}/configs/ShellCrash.cfg"

cat << 'EOF' > "${PRESET_DIR}/configs/command.env"
TMPDIR='/tmp/ShellCrash'
BINDIR='/usr/share/ShellCrash'
COMMAND="$TMPDIR/CrashCore -d $BINDIR -f $TMPDIR/config.yaml"
EOF

find "${PRESET_DIR}" -maxdepth 1 -name '*.sh' -exec sed -i 's|^#!/bin/.*|#!/bin/bash|' {} +
find "${PRESET_DIR}" -type f -name '*.sh' -exec chmod 755 {} +

mkdir -p files/etc/init.d
cp -f "${PRESET_DIR}/shellcrash.procd" files/etc/init.d/shellcrash
chmod 755 files/etc/init.d/shellcrash

mkdir -p files/etc/profile.d
cat << 'EOF' > files/etc/profile.d/shellcrash.sh
export CRASHDIR='/usr/share/ShellCrash'
alias crash='/usr/share/ShellCrash/menu.sh'
EOF

pushd "${PRESET_DIR}" > /dev/null
for FILE in task*; do
  [ -f "${FILE}" ] && mv -f "${FILE}" task
done
for FILE in *.yaml; do
  [ -f "${FILE}" ] && mv -f "${FILE}" yamls
done
for FILE in *.list; do
  [ -f "${FILE}" ] && mv -f "${FILE}" configs
done
popd > /dev/null

printf '[ \e[32mSUCCESS\e[0m ] %s\n' "[${0##*/}] done"
exit 0