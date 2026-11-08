#!/usr/bin/env bash
#
# firstboot-setup.sh — exécuté par archinstall (custom_commands) DANS le chroot
# du système installé, juste avant la fin de l'installation.
#
# - clone le dépôt infra dans /opt/cih-infra (le script de post-install le
#   mettra à jour au premier lancement)
# - installe /usr/local/bin/cih-firstboot
# - ajoute un démarrage automatique dans la session Plasma du compte admin :
#   au premier login, une console s'ouvre et lance arch-install-post-install
#
# Ne doit JAMAIS échouer : une erreur ici ferait planter archinstall à la toute
# fin. Tout ce qui rate est rattrapé par cih-firstboot au premier boot.

set +e

REPO_URL="https://github.com/cih-hoche/infra.git"
INFRA_DIR="/opt/cih-infra"
ADMIN="admin"

# 1. Dépôt infra (optionnel : cih-firstboot sait le récupérer sinon)
if [[ ! -d "$INFRA_DIR/.git" ]]; then
    git clone --quiet --branch main "$REPO_URL" "$INFRA_DIR" \
        || echo "[cih] clone de $REPO_URL impossible — sera fait au premier boot"
fi

# 2. Lanceur du post-install
cat > /usr/local/bin/cih-firstboot << 'EOF'
#!/usr/bin/env bash
# cih-firstboot — lance le post-install CIH (installé par l'ISO CIH).
# Ouvert automatiquement au premier login du compte admin ; relançable à la main.
SCRIPT="/opt/cih-infra/installation_arch/scripts/arch-install-post-install"
SCRIPT_URL="https://raw.githubusercontent.com/cih-hoche/infra/refs/heads/main/installation_arch/scripts/arch-install-post-install"
AUTOSTART="$HOME/.config/autostart/cih-firstboot.desktop"

echo "=============== Post-installation CIH ==============="
until ping -c1 -W3 github.com > /dev/null 2>&1; do
    echo "Pas d'accès à Internet. Connecter le PC (applet réseau KDE),"
    read -rp "puis appuyer sur Entrée (Ctrl+C pour annuler)… "
done

# Dépôt pas encore cloné (clone raté pendant l'installation) : script seul
if [[ ! -x "$SCRIPT" ]]; then
    SCRIPT="$(mktemp)"
    curl -fsSL "$SCRIPT_URL" -o "$SCRIPT" && chmod +x "$SCRIPT"
fi

if "$SCRIPT"; then
    rm -f "$AUTOSTART"
    echo "Post-installation terminée. Redémarrer le PC."
else
    echo "Le post-install s'est arrêté en erreur. Relancer avec : cih-firstboot"
fi
read -rp "Entrée pour fermer… "
EOF
chmod 755 /usr/local/bin/cih-firstboot

# 3. Démarrage automatique au premier login du compte admin
if id "$ADMIN" > /dev/null 2>&1; then
    home="$(getent passwd "$ADMIN" | cut -d: -f6)"
    group="$(id -gn "$ADMIN")"
    install -d -o "$ADMIN" -g "$group" "$home/.config" "$home/.config/autostart"
    cat > "$home/.config/autostart/cih-firstboot.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=Post-installation CIH
Exec=konsole -e /usr/local/bin/cih-firstboot
X-KDE-autostart-phase=2
EOF
    chown "$ADMIN:$group" "$home/.config/autostart/cih-firstboot.desktop"
    echo "[cih] post-install programmé au premier login de $ADMIN"
else
    echo "[cih] compte '$ADMIN' absent — lancer cih-firstboot à la main au premier boot"
fi

exit 0
