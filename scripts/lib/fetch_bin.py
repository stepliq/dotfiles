#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import shutil
import stat
import tarfile
import tempfile
import urllib.request
import zipfile
from pathlib import Path

from common import dest_bin, die, log, warn

ARCHIVE_SUFFIXES = (
    (".tar.gz", "asset.tar.gz"),
    (".tgz", "asset.tar.gz"),
    (".tar.xz", "asset.tar.xz"),
    (".tar.bz2", "asset.tar.bz2"),
    (".zip", "asset.zip"),
)


def download(url: str, path: Path) -> None:
    log(f"downloading {url}")
    with urllib.request.urlopen(url) as resp, path.open("wb") as out:
        shutil.copyfileobj(resp, out)


def archive_name_for(url: str) -> str | None:
    lower = url.lower().split("?", 1)[0]
    for suffix, name in ARCHIVE_SUFFIXES:
        if lower.endswith(suffix):
            return name
    return None


def extract(archive: Path, dest: Path) -> None:
    name = archive.name.lower()
    if name.endswith((".tar.gz", ".tgz", ".tar.xz", ".tar.bz2")):
        if name.endswith(".tar.xz"):
            mode = "r:xz"
        elif name.endswith(".tar.bz2"):
            mode = "r:bz2"
        else:
            mode = "r:gz"
        with tarfile.open(archive, mode) as tf:
            kwargs = {"filter": "data"} if hasattr(tarfile, "data_filter") else {}
            tf.extractall(dest, **kwargs)
        return
    if name.endswith(".zip"):
        with zipfile.ZipFile(archive) as zf:
            zf.extractall(dest)
        return
    die(f"unsupported archive: {archive.name}")


def find_binary(root: Path, bin_name: str) -> Path | None:
    matches = [p for p in root.rglob(bin_name) if p.is_file()]
    return matches[0] if matches else None


def install_binary(src: Path, dest: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dest)
    dest.chmod(dest.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)


def install_from_url(url: str, bin_name: str, dest_dir: Path | None = None) -> Path:
    dest_dir = dest_dir or dest_bin()
    dest = dest_dir / bin_name
    asset_name = archive_name_for(url)

    with tempfile.TemporaryDirectory(prefix="dotfiles-fetch-") as tmp:
        tmp_path = Path(tmp)
        if asset_name is None:
            raw = tmp_path / bin_name
            download(url, raw)
            install_binary(raw, dest)
            log(f"installed {dest}")
            return dest

        archive = tmp_path / asset_name
        download(url, archive)
        extract(archive, tmp_path)
        found = find_binary(tmp_path, bin_name)
        if found is None:
            die(f"could not find {bin_name} in archive")
        install_binary(found, dest)
        log(f"installed {dest}")
        return dest


def main() -> None:
    parser = argparse.ArgumentParser(description="Download and install a binary")
    parser.add_argument("url")
    parser.add_argument("bin_name")
    parser.add_argument("dest", nargs="?", default=str(dest_bin()))
    args = parser.parse_args()
    os.environ.setdefault("DOTFILES_SCRIPT", args.bin_name)
    try:
        install_from_url(args.url, args.bin_name, Path(args.dest))
    except SystemExit:
        raise
    except Exception as exc:  # noqa: BLE001
        warn(str(exc))
        raise SystemExit(1) from exc


if __name__ == "__main__":
    main()
