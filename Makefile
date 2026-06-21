PREFIX ?= /usr/local

.PHONY: install uninstall

install:
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 0755 bin/whatismyip $(DESTDIR)$(PREFIX)/bin/whatismyip

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/whatismyip
