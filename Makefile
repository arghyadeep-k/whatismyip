PREFIX ?= /usr/local

.PHONY: install uninstall test

install:
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 0755 bin/whatismyip $(DESTDIR)$(PREFIX)/bin/whatismyip

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/whatismyip

test-pwsh:
	pwsh -NoProfile -File test/Run-Tests.ps1

test:
	bats test/
