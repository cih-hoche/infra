#!/usr/bin/env bash
#
# build.sh — construit l'ISO d'installation CIH
#
# Part du profil officiel "releng" d'archiso (l'ISO Arch standard), puis
# ajoute la surcouche CIH (iso/airootfs + iso/profiledef.cih.sh).
#
# Usage (sur une machine Arch, avec archiso installé) :
#     sudo ./build.sh [dossier_de_sortie]      # défaut : iso/out
#
# Variables : CIH_WORK_DIR (défaut iso/work, ~ quelques Go, supprimé à la fin)

set -euo pipefail

HERE="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
OUT_DIR="$(readlink -m "${1:-$HERE/out}")"
WORK_DIR="$(readlink -m "${CIH_WORK_DIR:-$HERE/work}")"
RELENG=/usr/share/archiso/configs/releng
PROFILE="$WORK_DIR/profile"

die() { echo "[FAIL] $*" >&2; exit 1; }

[[ $EUID -eq 0 ]]              || die "À lancer en root : sudo $0"
command -v mkarchiso > /dev/null || die "archiso absent : sudo pacman -S archiso"
[[ -d "$RELENG" ]]             || die "Profil releng introuvable : $RELENG"
[[ "$WORK_DIR" != "/" && "$WORK_DIR" != "$HERE" ]] || die "CIH_WORK_DIR invalide : $WORK_DIR"

# Dossier de travail propre (mkarchiso reprend sinon un ancien build)
rm -rf -- "$WORK_DIR"
mkdir -p "$PROFILE" "$OUT_DIR"
trap 'rm -rf -- "$WORK_DIR"' EXIT

echo "==> Profil releng + surcouche CIH"
cp -a "$RELENG/." "$PROFILE/"
cp -a "$HERE/airootfs/." "$PROFILE/airootfs/"
cat "$HERE/profiledef.cih.sh" >> "$PROFILE/profiledef.sh"

echo "==> mkarchiso"
mkarchiso -v -w "$WORK_DIR/build" -o "$OUT_DIR" "$PROFILE"

# Rend l'ISO à l'utilisateur qui a lancé sudo
if [[ -n "${SUDO_UID:-}" ]]; then
    chown "$SUDO_UID:$SUDO_GID" "$OUT_DIR"/*.iso
fi

echo "==> ISO prête :"
ls -lh "$OUT_DIR"/*.iso
