ifndef DESTDIR
DESTDIR := /
endif
MAN_DIR := $(DESTDIR)usr/share/man/man1
BIN_DIR := $(DESTDIR)usr/bin

build:
	crystal build inject.cr
	gzip --keep inject.1
install: build
	cp inject $(BIN_DIR)
	cp inject.1.gz $(MAN_DIR)
uninstall:
	[ -f $(BIN_DIR)/inject ] && rm $(BIN_DIR)/inject
	[ -f $(MAN_DIR)/inject.1.gz ] && rm $(MAN_DIR)/inject.1.gz
clean:
	[ -f inject ] && rm inject
	[ -f inject.1.gz ] && rm -f inject.1.gz
