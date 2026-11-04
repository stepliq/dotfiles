fpath=(/usr/local/share/zsh/site-functions /usr/share/zsh/site-functions $fpath)

if [[ ! -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
  mkdir -p ~/.local/share/zinit && \
    git clone https://github.com/zdharma-continuum/zinit ~/.local/share/zinit/zinit.git
fi

source ~/.local/share/zinit/zinit.git/zinit.zsh

eval "$(direnv hook zsh)"

zinit ice blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-history-substring-search
zinit light tom-auger/cmdtime
zinit light MichaelAquilina/zsh-you-should-use
zinit load agkozak/zsh-z

# OMZ libs for muse (prompt); OMZP::git/tmux after compinit (compdef)
zinit snippet OMZL::spectrum.zsh
zinit snippet OMZL::git.zsh
zinit snippet OMZL::async_prompt.zsh
zinit snippet OMZL::prompt_info_functions.zsh
zinit snippet OMZL::theme-and-appearance.zsh

autoload -Uz compinit && compinit -C

zmodload -i zsh/complist 2>/dev/null
zstyle ':completion:*' menu select=2
[[ -n ${LS_COLORS} ]] && zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

zinit cdreplay -q

zinit snippet OMZP::git

export ZSH_TMUX_FIXTERM=false
zinit snippet OMZP::tmux
zinit cdreplay -q
zinit snippet OMZ::themes/muse.zsh-theme

zinit light zsh-users/zsh-autosuggestions
