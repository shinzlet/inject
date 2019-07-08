build:
	crystal build inject.cr
	gzip inject.1

install:
	crystal build inject.cr
	cp inject /usr/bin/inject
	gzip inject.1
	cp inject.1.gz /usr/share/man/man1/
uninstall:
	rm /usr/bin/inject
	rm /usr/share/man/man1/inject.1.gz
