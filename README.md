# My dotfiles

Bootstrap via [Dotbot](https://github.com/anishathalye/dotbot):

```bash
git clone --recurse-submodules https://github.com/dura0ok/dotfiles ~/.dotfiles
cd ~/.dotfiles
./install
```

Флаги:

- `./install --skip-apps` — пакеты + симлинки, без тяжёлых установщиков (Ghostty, Sublime, VS Code, Docker, nvm, Go, …)
- `./install --links-only` — только симлинки (`dotbot --only link`)

