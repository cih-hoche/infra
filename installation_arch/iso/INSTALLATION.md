# Installer un PC du CIH avec l'ISO CIH

Durée : ~20 min d'installation + ~30–60 min de post-install (téléchargements).
Il faut : la clé USB avec l'ISO CIH, une connexion Internet (Ethernet de préférence),
l'étiquette du PC (pour le hostname) et les mots de passe des comptes.

> **Attention : l'installation efface le disque choisi.** Sauvegarder ce qui doit l'être avant.

## 1. Préparer la clé USB

ISO : `cih-archlinux-*.iso` (construite avec [README.md](README.md)).

- **Ventoy** (recommandé) : copier l'ISO sur la clé Ventoy.
- **Ou** graver directement (efface la clé, vérifier `/dev/sdX` avec `lsblk`) :
  ```bash
  sudo dd if=cih-archlinux-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
  ```

## 2. Démarrer sur la clé

1. Dans le BIOS/UEFI : désactiver **Secure Boot** et **Fast Boot**, activer le
   **Wake on LAN** au passage (souvent « Power On by PCI-E »).
2. Booter sur la clé (menu de boot : F12, F8, Échap… selon le PC), choisir l'entrée Arch Linux.
3. La session live s'ouvre en root, clavier déjà en `fr`.

## 3. Réseau

- **Ethernet** : rien à faire.
- **Wi-Fi** :
  ```bash
  iwctl
  station wlan0 scan
  station wlan0 get-networks
  station wlan0 connect "<SSID>"
  exit
  ```
  Si l'interface n'apparaît pas : `ip link`, puis `rfkill list` (débloquer avec `rfkill unblock all`).

## 4. Lancer l'installeur

```bash
cih-install
```

Le menu d'archinstall s'ouvre, déjà rempli (fr, GRUB, linux-lts, KDE Plasma + SDDM, pipewire,
NetworkManager, Europe/Paris). **Vérifier**, puis renseigner :

| Menu | Quoi mettre |
|---|---|
| Mirrors | France + Worldwide (optionnel, sinon miroirs classés automatiquement) |
| Disk configuration | Disque du PC. Filesystem **btrfs**, **sans chiffrement**. Partition `/home` séparée si voulue. Garder les sous-volumes par défaut (`@`, `@home`…) : Timeshift en a besoin. Pas de snapshots archinstall (Timeshift est configuré par le post-install) |
| Hostname | L'étiquette du PC, ex : `archlinux-cih-001` |
| Authentication | Mot de passe **root** + un utilisateur **`admin`** avec les droits **sudo** (« superuser ») |

Les autres comptes (`membre`, `asso`, `guest`) sont créés par le post-install : ne pas les créer ici.

Puis **Install**, confirmer. À la fin : choisir **Reboot** et retirer la clé USB pendant le redémarrage.

## 5. Premier démarrage : post-installation automatique

1. À l'écran SDDM, se connecter avec **`admin`**.
2. Une console « Post-installation CIH » s'ouvre toute seule et lance
   `arch-install-post-install` (si pas de réseau, elle attend : se connecter via l'applet réseau KDE).
3. Répondre aux questions au début : mot de passe sudo de `admin`, puis mot de passe de chaque
   compte créé (`membre`, `asso`, `guest`). Ensuite tout tourne sans intervention.
4. À la fin, lire le **récapitulatif** (OK / WARN / FAIL), **noter l'adresse MAC** affichée
   (inventaire WoL), puis **redémarrer**.

Une fois réussi, la console ne se rouvre plus. En cas d'échec ou d'interruption, relancer à la main :

```bash
cih-firstboot
# ou directement :
/opt/cih-infra/installation_arch/scripts/arch-install-post-install
```

Le script est relançable sans risque (il saute ce qui est déjà fait) ; le relancer plus tard
applique aussi les nouveautés du dépôt (paquets, dotfiles).

## 6. Après

- Thème Plymouth (optionnel) : `sudo plymouth-set-default-theme -l`, puis `sudo plymouth-set-default-theme -R <thème>`
- Vérifier les snapshots : `sudo timeshift --list` (un snapshot « Baseline post-install » doit exister)

En cas de problème (le PC ne démarre plus, etc.) : demander sur le Discord de l'association.
