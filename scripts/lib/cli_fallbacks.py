#!/usr/bin/env python3
from __future__ import annotations

import os
import platform
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path

from common import dest_bin, have_cmd, log, skip_apps, warn
from fetch_bin import install_from_url


def host() -> tuple[str, str]:
    system = platform.system()
    machine = platform.machine()
    return system, machine


def cargo_install(crate: str) -> bool:
    cargo = shutil.which("cargo")
    if not cargo:
        return False
    env = os.environ.copy()
    env["PATH"] = f"{Path.home() / '.cargo' / 'bin'}:{env.get('PATH', '')}"
    return subprocess.call([cargo, "install", "--locked", crate], env=env) == 0


@dataclass(frozen=True)
class Tool:
    cmd: str
    version_env: str
    default_version: str
    urls: dict[tuple[str, str], str]
    bin_name: str | None = None
    cargo: str | None = None
    darwin_hint: str | None = None

    def binary(self) -> str:
        return self.bin_name or self.cmd


TOOLS = [
    Tool(
        cmd="just",
        version_env="JUST_VERSION",
        default_version="1.59.0",
        urls={
            ("Linux", "x86_64"): "https://github.com/casey/just/releases/download/{ver}/just-{ver}-x86_64-unknown-linux-musl.tar.gz",
            ("Linux", "aarch64"): "https://github.com/casey/just/releases/download/{ver}/just-{ver}-aarch64-unknown-linux-musl.tar.gz",
            ("Darwin", "x86_64"): "https://github.com/casey/just/releases/download/{ver}/just-{ver}-x86_64-apple-darwin.tar.gz",
            ("Darwin", "arm64"): "https://github.com/casey/just/releases/download/{ver}/just-{ver}-aarch64-apple-darwin.tar.gz",
        },
    ),
    Tool(
        cmd="eza",
        version_env="EZA_VERSION",
        default_version="0.23.5",
        urls={
            ("Linux", "x86_64"): "https://github.com/eza-community/eza/releases/download/v{ver}/eza_x86_64-unknown-linux-musl.tar.gz",
            ("Linux", "aarch64"): "https://github.com/eza-community/eza/releases/download/v{ver}/eza_aarch64-unknown-linux-gnu.tar.gz",
        },
        cargo="eza",
    ),
    Tool(
        cmd="lazygit",
        version_env="LAZYGIT_VERSION",
        default_version="0.66.2",
        urls={
            ("Linux", "x86_64"): "https://github.com/jesseduffield/lazygit/releases/download/v{ver}/lazygit_{ver}_linux_x86_64.tar.gz",
            ("Linux", "aarch64"): "https://github.com/jesseduffield/lazygit/releases/download/v{ver}/lazygit_{ver}_linux_arm64.tar.gz",
            ("Darwin", "x86_64"): "https://github.com/jesseduffield/lazygit/releases/download/v{ver}/lazygit_{ver}_darwin_x86_64.tar.gz",
            ("Darwin", "arm64"): "https://github.com/jesseduffield/lazygit/releases/download/v{ver}/lazygit_{ver}_darwin_arm64.tar.gz",
        },
    ),
    Tool(
        cmd="procs",
        version_env="PROCS_VERSION",
        default_version="0.14.12",
        urls={
            ("Linux", "x86_64"): "https://github.com/dalance/procs/releases/download/v{ver}/procs-v{ver}-x86_64-linux.zip",
            ("Linux", "aarch64"): "https://github.com/dalance/procs/releases/download/v{ver}/procs-v{ver}-aarch64-linux.zip",
            ("Darwin", "x86_64"): "https://github.com/dalance/procs/releases/download/v{ver}/procs-v{ver}-x86_64-mac.zip",
            ("Darwin", "arm64"): "https://github.com/dalance/procs/releases/download/v{ver}/procs-v{ver}-aarch64-mac.zip",
        },
    ),
    Tool(
        cmd="fq",
        version_env="FQ_VERSION",
        default_version="0.18.0",
        urls={
            ("Linux", "x86_64"): "https://github.com/wader/fq/releases/download/v{ver}/fq_{ver}_linux_amd64.tar.gz",
            ("Linux", "aarch64"): "https://github.com/wader/fq/releases/download/v{ver}/fq_{ver}_linux_arm64.tar.gz",
            ("Darwin", "x86_64"): "https://github.com/wader/fq/releases/download/v{ver}/fq_{ver}_macos_amd64.zip",
            ("Darwin", "arm64"): "https://github.com/wader/fq/releases/download/v{ver}/fq_{ver}_macos_arm64.zip",
        },
    ),
    Tool(
        cmd="fclones",
        version_env="FCLONES_VERSION",
        default_version="0.35.0",
        urls={
            ("Linux", "x86_64"): "https://github.com/pkolaczk/fclones/releases/download/v{ver}/fclones-{ver}-linux-musl-x86_64.tar.gz",
        },
        cargo="fclones",
    ),
    Tool(
        cmd="erd",
        version_env="ERDTREE_VERSION",
        default_version="3.1.2",
        urls={
            ("Linux", "x86_64"): "https://github.com/solidiquis/erdtree/releases/download/v{ver}/erd-v{ver}-x86_64-unknown-linux-musl.tar.gz",
            ("Linux", "aarch64"): "https://github.com/solidiquis/erdtree/releases/download/v{ver}/erd-v{ver}-aarch64-unknown-linux-musl.tar.gz",
            ("Darwin", "x86_64"): "https://github.com/solidiquis/erdtree/releases/download/v{ver}/erd-v{ver}-x86_64-apple-darwin.tar.gz",
            ("Darwin", "arm64"): "https://github.com/solidiquis/erdtree/releases/download/v{ver}/erd-v{ver}-aarch64-apple-darwin.tar.gz",
        },
    ),
    Tool(
        cmd="fastfetch",
        version_env="FASTFETCH_VERSION",
        default_version="2.70.0",
        urls={
            ("Linux", "x86_64"): "https://github.com/fastfetch-cli/fastfetch/releases/download/{ver}/fastfetch-linux-amd64.tar.gz",
            ("Linux", "aarch64"): "https://github.com/fastfetch-cli/fastfetch/releases/download/{ver}/fastfetch-linux-aarch64.tar.gz",
        },
        darwin_hint="use brew on macOS if missing",
    ),
]


def install_tool(tool: Tool, system: str, machine: str, dest: Path) -> bool:
    os.environ["DOTFILES_SCRIPT"] = tool.cmd
    ver = os.environ.get(tool.version_env, tool.default_version)
    url = tool.urls.get((system, machine))
    if url is None:
        if system == "Darwin" and tool.darwin_hint:
            warn(tool.darwin_hint)
            return False
        if tool.cargo:
            log(f"no release archive for {system}/{machine}; trying cargo")
            return cargo_install(tool.cargo)
        return False
    try:
        install_from_url(url.format(ver=ver), tool.binary(), dest)
        return True
    except SystemExit:
        return False


def main() -> None:
    skip_apps()
    system, machine = host()
    dest = dest_bin()

    for tool in TOOLS:
        os.environ["DOTFILES_SCRIPT"] = tool.cmd
        if have_cmd(tool.cmd):
            log(f"already installed ({shutil.which(tool.cmd)})")
            continue
        log("missing — installing fallback")
        if not install_tool(tool, system, machine, dest):
            warn("fallback install failed (continuing)")


if __name__ == "__main__":
    try:
        main()
    except SystemExit as exc:
        raise SystemExit(exc.code or 0) from exc
