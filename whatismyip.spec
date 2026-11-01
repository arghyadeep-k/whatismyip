Name:           whatismyip
Version:        %{?pkg_version}%{!?pkg_version:1.0.0}
Release:        1%{?dist}
Summary:        Print your public and local IP address(es)

License:        MIT
URL:            https://github.com/arghyadeep-k/whatismyip
Source0:        https://github.com/arghyadeep-k/whatismyip/archive/refs/tags/v%{version}/whatismyip-%{version}.tar.gz

BuildArch:      noarch

Requires:       bash
Requires:       curl
Requires:       iproute

%description
whatismyip is a small CLI tool that prints your public IPv4/IPv6
address (via ifconfig.me, icanhazip.com, or ipinfo.io) and/or your
local IPv4 address(es) via the system's iproute2 tools.

%prep
%autosetup -n %{name}-%{version}

%build
# nothing to build for a single shell script

%install
make install DESTDIR=%{buildroot} PREFIX=%{_prefix}

%files
%license LICENSE
%doc README.md
%{_bindir}/whatismyip

%changelog
* Sun Jun 21 2026 Arghya <contact@arghyadeep.in> - 1.0.0-1
- Initial RPM packaging release.
