# ISO d'installation CIH — construction

ISO Arch Linux live (profil officiel `releng` d'archiso) + une surcouche CIH :

- clavier `fr` et police `ter-132b` dès le démarrage de la session live ;
- commande `cih-install` : lance `archinstall` **pré-rempli** avec la config du guide ;
- au premier login du compte `admin` sur le PC installé, une console s'ouvre et lance
  [`arch-install-post-install`](../scripts/arch-install-post-install) (comptes, yay,
  Timeshift + grub-btrfs, Plymouth, paquets de [`packages.txt`](../packages.txt),
  zsh + dotfiles, Wake-on-LAN, snapshots…).

L'ISO ne contient pas les paquets du post-install : ils sont téléchargés au premier boot,
depuis la version du dépôt sur GitHub (`main`). Modifier `packages.txt`, les dotfiles ou le
script ne demande donc **pas** de reconstruire l'ISO.

Installer un PC avec l'ISO : voir [INSTALLATION.md](INSTALLATION.md).

## Contenu

| Fichier | Rôle |
|---|---|
| `build.sh` | Copie `releng`, applique la surcouche, lance `mkarchiso` |
| `profiledef.cih.sh` | Ajouté à la fin du `profiledef.sh` de releng (nom, label, permissions) |
| `airootfs/etc/vconsole.conf` | Clavier `fr` + police de la session live |
| `airootfs/etc/motd` | Message d'accueil de la session live |
| `airootfs/usr/local/bin/cih-install` | Installeur : vérifie le réseau, lance `archinstall --config` |
| `airootfs/root/cih/user_configuration.json` | Réponses pré-remplies d'archinstall (format archinstall 4.x) |
| `airootfs/root/cih/firstboot-setup.sh` | Exécuté par archinstall dans le chroot (`custom_commands`) : clone le dépôt dans `/opt/cih-infra`, installe `cih-firstboot` et l'autostart du compte `admin` |

Config pré-remplie (= tableau du guide) :

| Paramètre | Valeur |
|---|---|
| Clavier / locale | `fr` / `fr_FR.UTF-8` |
| Bootloader | GRUB |
| Noyau | `linux-lts` |
| Profil | Desktop → KDE Plasma, SDDM, pilotes graphiques open-source |
| Audio | pipewire |
| Réseau | NetworkManager |
| Paquets en plus | `git base-devel neovim konsole` |
| Fuseau | `Europe/Paris`, NTP |
| Swap | zram |

Laissés au menu (propres à chaque PC) : disque/partitionnement, hostname, mots de passe et comptes.

## Construire l'ISO

Sur une machine **Arch Linux** (x86_64), ~5 Go libres, connexion Internet :

```bash
sudo pacman -S --needed archiso
cd installation_arch/iso
sudo ./build.sh            # ISO dans installation_arch/iso/out/
# ou : sudo ./build.sh /chemin/de/sortie
```

Résultat : `out/cih-archlinux-AAAA.MM.JJ-x86_64.iso` (~1,2 Go). `work/` est supprimé à la fin.
`out/` et `work/` sont ignorés par git : ne pas commiter l'ISO.

### Via GitHub Actions (sans machine Arch)

Workflow [`build-iso.yml`](../../.github/workflows/build-iso.yml). Il se lance :

- à la main : onglet **Actions** → **Build ISO** → **Run workflow** ;
- à chaque push sur `main` qui modifie `installation_arch/iso/` (et sur les PR) ;
- le 1er de chaque mois (ISO à jour).

Dernière ISO construite depuis `main` (lien fixe, remplacée à chaque build) :
<https://github.com/cih-hoche/infra/releases/tag/iso-latest>

Chaque run garde aussi l'ISO et son `SHA256SUMS` en bas de sa page (**Artifacts**,
14 jours, zip à extraire). Pour une version figée, créer une release :

```bash
git tag iso-2026.11 && git push origin iso-2026.11
```

L'ISO est alors attachée à la release GitHub du tag.

### Depuis une autre distribution (Docker)

```bash
cd installation_arch/iso
docker run --rm --privileged -v "$PWD":/iso -w /iso archlinux:latest \
    bash -c 'pacman -Syu --noconfirm archiso && ./build.sh'
```

### Tester dans une VM avant de graver

```bash
sudo pacman -S --needed qemu-desktop edk2-ovmf
run_archiso -u -i out/cih-archlinux-*.iso      # -u = démarrage UEFI
```

Pour tester l'installation complète, créer un disque virtuel et démarrer avec QEMU/virt-manager
(UEFI, ≥ 40 Go de disque, ≥ 4 Go de RAM).

## Modifier l'ISO

- **Réponses d'archinstall** : éditer `user_configuration.json`. Pour récupérer le format exact
  d'une option, faire une installation à la main dans une VM, puis copier les clés voulues de
  `/var/log/archinstall/user_configuration.json` (session live, après install).
- **Paquets de la session live** : la liste vient de releng
  (`/usr/share/archiso/configs/releng/packages.x86_64`). Pour en ajouter, faire ajouter les
  lignes par `build.sh` dans `"$PROFILE/packages.x86_64"`.
- **Nouveau fichier exécutable dans `airootfs/`** : déclarer ses permissions dans
  `profiledef.cih.sh` (`file_permissions`), sinon il sera installé sans le bit `x`.
- **Logiciels / config des PCs** : rien à changer ici, modifier `packages.txt`, `dotfiles/` ou
  le script de post-install.

Reconstruire l'ISO de temps en temps (mise à jour du noyau live et d'archinstall).
Si une nouvelle version d'archinstall ne lit plus une clé de la config, l'option apparaît
simplement vide dans le menu : la renseigner à la main, puis corriger le JSON.
