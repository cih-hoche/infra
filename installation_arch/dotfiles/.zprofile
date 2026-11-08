# ~/.zprofile — lu par les shells de connexion (et la session Plasma via SDDM)

# ~/.local/bin (pipx, etc.), ajouté une seule fois
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$PATH:$HOME/.local/bin" ;;
esac
