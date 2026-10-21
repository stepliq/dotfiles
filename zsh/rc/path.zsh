export PATH=$HOME/.local/bin:$PATH

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"

export ANDROID_SDK_ROOT=$HOME/Android
export PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH
export PATH="$HOME/.elan/bin:$PATH"

export PATH=$HOME/.platformio/penv/bin:$PATH

[[ -f "$HOME/.xmake/profile" ]] && source "$HOME/.xmake/profile"

zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

export PATH=$HOME/.cargo/bin:$PATH
# alias cursor="$HOME/.cursor/cursor.AppImage --no-sandbox"

export GOROOT=$HOME/.go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

[[ -d $HOME/.local/lib/kache/shims ]] && export PATH=$HOME/.local/lib/kache/shims:$PATH
