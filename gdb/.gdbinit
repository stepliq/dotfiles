python
import os
path = os.path.expanduser(os.path.join(os.environ.get("XDG_DATA_HOME", os.path.expanduser("~/.local/share")), "gdb-dashboard", ".gdbinit"))
if os.path.isfile(path):
    gdb.execute(f"source {path}")
else:
    print(f"gdb-dashboard missing at {path}; run ./install or scripts/install-gdb-dashboard.sh")
end

set history save
set verbose off
set print pretty on
set print array off
set print array-indexes on
set python print-stack full
