if (( ! ${+commands[bat]} )) && (( ${+commands[batcat]} )); then
  alias bat=batcat
fi
if (( ! ${+commands[fd]} )) && (( ${+commands[fdfind]} )); then
  alias fd=fdfind
fi
