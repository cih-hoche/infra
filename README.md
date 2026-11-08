# infra
Un repo qui documente et contient des fichiers helper pour l'infra du CIH

## Installation des PCs (Arch Linux)

Tout est dans [`installation_arch/`](installation_arch/) :

| Chemin | Contenu |
|---|---|
| [`iso/INSTALLATION.md`](installation_arch/iso/INSTALLATION.md) | **Installer un PC** avec l'ISO CIH (pas à pas) |
| [`iso/README.md`](installation_arch/iso/README.md) | **Construire l'ISO CIH** (archiso) et la modifier |
| [`iso/`](installation_arch/iso/) | Profil de l'ISO : `build.sh`, config archinstall pré-remplie, lancement auto du post-install |
| [`scripts/arch-install-post-install`](installation_arch/scripts/arch-install-post-install) | Post-installation : comptes, yay, Timeshift + grub-btrfs, Plymouth, paquets, zsh, Wake-on-LAN, snapshots |
| [`packages.txt`](installation_arch/packages.txt) | Logiciels installés par le post-install (par catégorie) |
| [`dotfiles/`](installation_arch/dotfiles/) | `.zshrc` / `.zprofile` déployés pour tous les comptes |
| `guide_installation.odt` | Guide d'installation manuel (sans l'ISO CIH) + dépannage |

Démarrage rapide :

```bash
# Construire l'ISO (machine Arch, archiso installé)
cd installation_arch/iso && sudo ./build.sh

# Sur le PC à installer, booté sur l'ISO :
cih-install
```

Le post-install se lance tout seul au premier login du compte `admin`.
Modifier `packages.txt`, `dotfiles/` ou le script ne demande pas de reconstruire l'ISO :
la dernière version du dépôt (`main`) est utilisée au premier boot.
