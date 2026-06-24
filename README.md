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
