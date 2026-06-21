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

### Manual

```sh
sudo install -m 0755 bin/whatismyip /usr/local/bin/whatismyip
```

## Uninstall

```sh
sudo make uninstall
```
