# whatismyip

A small CLI tool to print your public (and optionally local) IP address(es).

## Usage

```
whatismyip [OPTION]

  (no option)   Show public IPv4 address
  -6            Show public IPv6 address
  -l, --local   Show local IPv4 address(es)
  -a, --all     Show public and local IPv4 addresses
  -h, --help    Show this help
```

## Requirements

- `bash`
- `curl`
- `iproute2` (for the `-l`/`--local` option)

## Installation

### Using make

```sh
sudo make install
```

This installs to `/usr/local/bin/whatismyip`. Override the location with `PREFIX`:

```sh
sudo make install PREFIX=/usr
```

### Using the install script

```sh
sudo ./install.sh
```

### Building and installing a .deb package (Debian/Ubuntu)

#### Standard method (requires debhelper)

```sh
sudo apt-get install -y devscripts debhelper
debuild -us -uc -b
sudo apt install ../whatismyip_1.0.0-1_all.deb
```

#### Quick method (no debhelper required)

```sh
./build-deb.sh
sudo apt install ./whatismyip_1.0.0_all.deb
```

Either method installs `whatismyip` to `/usr/bin/whatismyip`.

### Manual

```sh
sudo install -m 0755 bin/whatismyip /usr/local/bin/whatismyip
```

## Uninstall

```sh
sudo make uninstall
```

Uninstalling the .deb:

```sh
sudo apt remove whatismyip
```

## Running tests

```sh
sudo apt-get install -y bats
make test
```
