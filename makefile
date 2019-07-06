build:
	crystal build inject.cr

install:
	crystal build inject.cr
	cp inject /usr/bin/inject
