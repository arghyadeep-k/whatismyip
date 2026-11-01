# whatismyip

A small CLI tool to print your public (and optionally local) IP address(es).
Works on Linux, macOS, and Windows (PowerShell or cmd.exe).

## Usage

```
whatismyip [OPTION]

  (no option)   Show public IPv4 address
  -6            Show public IPv6 address
  -l, --local   Show local IPv4 address(es)
  -a, --all     Show public and local IPv4 addresses
  -h, --help    Show this help
```

On Windows, the same options work whether you invoke `whatismyip` from
PowerShell or from `cmd.exe`, e.g. `whatismyip -a`.

## Requirements

### Linux / macOS

- `bash`
- `curl`
- `iproute2` (Linux, for the `-l`/`--local` option) — not needed on macOS,
  which uses the built-in `ifconfig` instead.

### Windows

- PowerShell 5.1+ (built into Windows) or PowerShell 7+
- No extra dependencies — network requests use `Invoke-RestMethod` and local
  addresses are read via .NET, so `whatismyip.cmd` works from a plain
  `cmd.exe` prompt too.

## Installation

### Linux / macOS

#### Using make

```sh
sudo make install
```

This installs to `/usr/local/bin/whatismyip`. Override the location with `PREFIX`:

```sh
sudo make install PREFIX=/usr
```

#### Using the install script

```sh
sudo ./install.sh
```

#### Installing via apt (Debian/Ubuntu)

```sh
curl -fsSL https://arghyadeep-k.github.io/whatismyip/KEY.gpg \
  | sudo tee /usr/share/keyrings/whatismyip.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/whatismyip.gpg] https://arghyadeep-k.github.io/whatismyip stable main" \
  | sudo tee /etc/apt/sources.list.d/whatismyip.list
sudo apt update && sudo apt install whatismyip
```

#### Publishing a new release (maintainers)

One-time setup: generate a dedicated signing key, add the armored private key
(`gpg --armor --export-secret-keys <id>`) as the `GPG_PRIVATE_KEY` repo secret
(and `GPG_PASSPHRASE` if it has one), then enable GitHub Pages from the
`gh-pages` branch.

Per release: `git tag v1.0.1 && git push origin v1.0.1`. The tag (minus the
leading `v`) becomes the package version. The `Publish package repos` workflow
runs the tests, builds the .deb and .rpm, signs the apt and dnf repo metadata,
and pushes both to `gh-pages`.

#### Building and installing a .deb package (Debian/Ubuntu)

##### Standard method (requires debhelper)

```sh
sudo apt-get install -y devscripts debhelper
debuild -us -uc -b
sudo apt install ../whatismyip_1.0.0-1_all.deb
```

##### Quick method (no debhelper required)

```sh
./build-deb.sh
sudo apt install ./whatismyip_1.0.0_all.deb
```

Either method installs `whatismyip` to `/usr/bin/whatismyip`.

#### Installing via dnf (Fedora/RHEL)

```sh
sudo tee /etc/yum.repos.d/whatismyip.repo <<'EOF'
[whatismyip]
name=whatismyip
baseurl=https://arghyadeep-k.github.io/whatismyip/rpm
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://arghyadeep-k.github.io/whatismyip/KEY.asc
EOF
sudo dnf install whatismyip
```

#### Installing via dnf (Fedora, from COPR)

Once the `whatismyip` COPR repo is published (see [Publishing to COPR](#publishing-to-copr) below):

```sh
sudo dnf copr enable arghyadeep-k/whatismyip
sudo dnf install whatismyip
```

#### Building and installing a .rpm package locally (Fedora/RHEL)

```sh
sudo dnf install -y rpm-build rpmdevtools
./build-rpm.sh
sudo dnf install ./whatismyip-1.0.0-1*.rpm
```

This installs `whatismyip` to `/usr/bin/whatismyip`.

#### Publishing to COPR

`whatismyip.spec` builds from the GitHub tag tarball
(`archive/refs/tags/v<version>`), so the tag must exist first. `v1.0.0` is
already pushed; for a new version, bump the default `Version:` in
`whatismyip.spec`, then tag and push (this is the same tag that publishes the
apt/dnf repos). A separate GitHub release is not required. Then:

1. Sign in to [copr.fedorainfracloud.org](https://copr.fedorainfracloud.org) with your Fedora account.
2. Create a new project, e.g. `whatismyip`.
3. Add a new package with source type **SCM**, pointing at this repo and `whatismyip.spec`.
4. Trigger a build. Once it succeeds, anyone can install with the `dnf copr enable`/`dnf install` commands above.

#### Manual

```sh
sudo install -m 0755 bin/whatismyip /usr/local/bin/whatismyip
```

### Windows

The Windows implementation lives in `bin/whatismyip.ps1` (PowerShell) with a
`bin/whatismyip.cmd` wrapper so it also runs from `cmd.exe`.

#### Manual (copy to a folder on PATH)

```powershell
$dest = "$env:LOCALAPPDATA\whatismyip"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Copy-Item bin\whatismyip.ps1, bin\whatismyip.cmd -Destination $dest

# Add $dest to your user PATH (one-time):
[Environment]::SetEnvironmentVariable(
    'Path',
    "$([Environment]::GetEnvironmentVariable('Path', 'User'));$dest",
    'User'
)
```

Open a new terminal and run `whatismyip` (works in both PowerShell and
`cmd.exe`).

#### Running directly without installing

```powershell
.\bin\whatismyip.ps1 -a
```

```cmd
bin\whatismyip.cmd -a
```

> If PowerShell blocks the script with an execution-policy error, either run
> it via `whatismyip.cmd` (which bypasses the policy for this invocation
> only) or use `powershell -ExecutionPolicy Bypass -File bin\whatismyip.ps1`.

## Uninstall

```sh
sudo make uninstall
```

Uninstalling the .deb:

```sh
sudo apt remove whatismyip
```

Uninstalling the .rpm:

```sh
sudo dnf remove whatismyip
```

On Windows, delete the folder you copied `whatismyip.ps1`/`whatismyip.cmd`
into and remove it from PATH.

## Running tests

### Linux / macOS (bats)

```sh
sudo apt-get install -y bats   # or: brew install bats-core
make test
```

### Windows (Pester)

```powershell
Install-Module -Name Pester -Force -Scope CurrentUser
Invoke-Pester -Path test/whatismyip.Tests.ps1
```

Or, with PowerShell 7 (`pwsh`) on any OS: `make test-pwsh`.
