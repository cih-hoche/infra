# ~/.zshrc

# ── Historique ───────────────────────────────────────────────
HISTFILE=~/.histfile
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY EXTENDED_HISTORY

# ── Navigation ───────────────────────────────────────────────
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS
setopt INTERACTIVE_COMMENTS

# ── Complétion ───────────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# ── Touches ──────────────────────────────────────────────────
bindkey -e                      # emacs keys; use bindkey -v for vi

# Put the terminal in "application keypad" mode while the line editor is
# active, so terminfo key capabilities actually match what we receive.
autoload -Uz add-zle-hook-widget
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  _zle_app_mode_on()  { echoti smkx }
  _zle_app_mode_off() { echoti rmkx }
  add-zle-hook-widget line-init _zle_app_mode_on
  add-zle-hook-widget line-finish _zle_app_mode_off
fi

# bind a widget to several escape sequences at once, ignoring empty ones
_bk() { local w=$1; shift; local k; for k in "$@"; do [[ -n $k ]] && bindkey -- "$k" "$w"; done }

# history search on Up/Down (both normal and application cursor mode)
_bk history-beginning-search-backward '^[[A' '^[OA' "${terminfo[kcuu1]}"
_bk history-beginning-search-forward  '^[[B' '^[OB' "${terminfo[kcud1]}"

# Home / End
_bk beginning-of-line '^[[H' '^[OH' '^[[1~' '^[[7~' "${terminfo[khome]}"
_bk end-of-line       '^[[F' '^[OF' '^[[4~' '^[[8~' "${terminfo[kend]}"

# Delete / Insert
_bk delete-char    '^[[3~' "${terminfo[kdch1]}"
_bk overwrite-mode '^[[2~' "${terminfo[kich1]}"

# Page Up / Page Down
_bk history-beginning-search-backward '^[[5~' "${terminfo[kpp]}"
_bk history-beginning-search-forward  '^[[6~' "${terminfo[knp]}"

# word-wise movement: Ctrl+Left/Right and Alt+Left/Right
_bk backward-word '^[[1;5D' '^[[1;3D' '^[[5D' '^[^[[D' '^[b' "${terminfo[kLFT5]}"
_bk forward-word  '^[[1;5C' '^[[1;3C' '^[[5C' '^[^[[C' '^[f' "${terminfo[kRIT5]}"

# buffer ends: Ctrl+Home / Ctrl+End
_bk beginning-of-buffer-or-history '^[[1;5H' '^[[5H'
_bk end-of-buffer-or-history       '^[[1;5F' '^[[5F'

# word-wise deletion
_bk backward-kill-word '^W' '^[^?' '^[^H' '^H'   # Ctrl+W, Alt+Backspace, Ctrl+Backspace
_bk kill-word          '^[[3;5~' '^[[3;3~' '^[d' # Ctrl+Delete, Alt+Delete

# Shift+Tab walks the completion menu backwards
_bk reverse-menu-complete '^[[Z' "${terminfo[kcbt]}"

unfunction _bk

# ── Prompt ───────────────────────────────────────────────────
PS1='%F{green}%n%f@%F{blue}%m%f %F{cyan}%~%f %(?.%F{green}.%F{red})❯%f '

# ── Alias ────────────────────────────────────────────────────
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vim='nvim'

# ── Fichiers perso (non déployés par le script) ──────────────
[[ -f ~/.aliases ]]     && source ~/.aliases
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ── Plugins : toujours en dernier ────────────────────────────
# zsh-syntax-highlighting doit être sourcé APRÈS tous les widgets et bindkey.
for _plugin in \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
do
  [[ -r $_plugin ]] && source $_plugin
done
unset _plugin

# ── Accueil ──────────────────────────────────────────────────
# Run fastfetch, sadly gf died with huge data loss ;-;
(( $+commands[fastfetch] )) && fastfetch --logo small
