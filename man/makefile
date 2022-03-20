SHELL=/bin/bash

MANDIR := $(HOME)/man

.PHONY: uninstall all
all: $(INSTALL)
install: $(INSTALL)
	@for localman in man?; do \
		@mkdir -p $(MANDIR)/$$localman; \
		for lman in $$localman/*; do \
			install -g $(USER) -o $(USER) -C $$lman $$localman ; \
			done ; \
		done
uninstall: 
	@for execfile in $(INSTALL); do \
		echo "rm -f $(MANDIR)/$$execfile" ; \
		rm -f $(MANDIR)/$$execfile; \
	done
$(MANDIR):
	mkdir -p $(MANDIR)
