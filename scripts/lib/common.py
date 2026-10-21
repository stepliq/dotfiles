#!/usr/bin/env python3
from __future__ import annotations

import os
import shutil
import sys
from pathlib import Path


def script_name() -> str:
    name = os.environ.get("DOTFILES_SCRIPT") or Path(sys.argv[0]).name
    return name.removesuffix(".sh").removesuffix(".py")


def log(msg: str) -> None:
    print(f"{script_name()}: {msg}")


def warn(msg: str) -> None:
    print(f"{script_name()}: {msg}", file=sys.stderr)


def die(msg: str, code: int = 1) -> None:
    warn(msg)
    raise SystemExit(code)


def skip_apps() -> None:
    if os.environ.get("DOTFILES_SKIP_APPS"):
        raise SystemExit(0)


def have_cmd(name: str) -> bool:
    return shutil.which(name) is not None


def dest_bin() -> Path:
    dest = Path.home() / ".local" / "bin"
    dest.mkdir(parents=True, exist_ok=True)
    return dest
