SHELL=/bin/bash
.PHONY: atkin
.ONESHELL:
.sh:
	@rm -f $@
	cp $< $@

########################################################################
# this brings in the local function that are normally in:
# https://github.com/sailnfool/func.git
# by default I clone these repositories into ~/github/....git
# This copies the local shell functions into the src directory and
# then installs copies in ~/.local/bin which is always in my search
# path.  I did not want to clutter ~/bin with all of these functions
# that are very useful to have documented and laying around.
########################################################################
PREFIX=$(HOME)
LPREFIX=$(HOME)/.local
INSTALL = atkin
LINSTALL = func.errecho func.regex

EXECDIR := $(PREFIX)/bin
LEXECDIR := $(LPREFIX)/bin

atkin: atkin.c
	gcc  atkin.c -lm -o atkin
install: $(INSTALL)
	mkdir -p $(EXECDIR)
	install -g $(USER) -o $(USER) -c $? $(EXECDIR)
	rm -f $?
linstall: $(LINSTALL)
	mkdir -p $(LEXECDIR)
	install -o $(USER) -C $? $(LEXECDIR)
	rm -f $?

clean:
	@for execfile in $(INSTALL); do \
		echo rm -f $$execvile; \
		rm -f $$execfile; \
		done
uninstall:
	@for execfile in $(INSTALL); do \
		echo "rm -f $(EXECDIR)/$$execfile" ; \
		rm -f $(EXECDIR)/$$execfile; \
		done
$(EXECDIR):
	mkdir -p $(EXECDIR)
func.errecho: $(HOME)/github/func/scripts/func.insufficient.sh
func.regex: $(HOME)/github/func/scripts/func.regex.sh
tester.atkin.sh: func.errecho func.regex

smalltest: atkin
	echo "2^32-1" | bc
	./atkin $(echo "2^32-1" | bc)
bigfailtest: atkin
	echo "2^64-1" | bc
	./atkin $(echo "2^64-1" | bc)
killtest: atkin multitester.atkin.sh tester.atkin.sh
	./multitester.atkin.sh
