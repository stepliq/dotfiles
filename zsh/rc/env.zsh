export EDITOR=subl
export PGDATABASE=postgres

export PI_BG_FEATURES=process,delegate,attested,attribution

_ssh_rtdir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
for _ssh_sock in "$_ssh_rtdir/ssh-agent.socket" "$_ssh_rtdir/openssh_agent"; do
  if [[ -S $_ssh_sock ]]; then
    export SSH_AUTH_SOCK=$_ssh_sock
    break
  fi
done
unset _ssh_sock _ssh_rtdir
