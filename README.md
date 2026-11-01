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

### Installing via apt (Debian/Ubuntu)

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

Per release: `git tag v1.0.1 && git push origin v1.0.1`. The
`Publish package repos` workflow builds the .deb and .rpm, signs the apt and
dnf repo metadata, and pushes both to `gh-pages`.

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

### Installing via dnf (Fedora/RHEL)

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

### Installing via dnf (Fedora, from COPR)

Once the `whatismyip` COPR repo is published (see [Publishing to COPR](#publishing-to-copr) below):

```sh
sudo dnf copr enable arghyadeep-k/whatismyip
sudo dnf install whatismyip
```

### Building and installing a .rpm package locally (Fedora/RHEL)

```sh
sudo dnf install -y rpm-build rpmdevtools
./build-rpm.sh
sudo dnf install ./whatismyip-1.0.0-1*.rpm
```

This installs `whatismyip` to `/usr/bin/whatismyip`.

### Publishing to COPR

`whatismyip.spec` builds from a GitHub release tarball, so a tagged release is required first:

```sh
git tag v1.0.0
git push origin v1.0.0
```

Then create a [GitHub release](https://github.com/arghyadeep-k/whatismyip/releases) for that tag (so the `archive/refs/tags/v1.0.0` tarball URL in the spec resolves), and:

1. Sign in to [copr.fedorainfracloud.org](https://copr.fedorainfracloud.org) with your Fedora account.
2. Create a new project, e.g. `whatismyip`.
3. Add a new package with source type **SCM**, pointing at this repo and `whatismyip.spec`.
4. Trigger a build. Once it succeeds, anyone can install with the `dnf copr enable`/`dnf install` commands above.

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

Uninstalling the .rpm:

```sh
sudo dnf remove whatismyip
```

## Running tests

```sh
sudo apt-get install -y bats
make test
```
