SHELL=/bin/bash
.PHONY: atkin
.ONESHELL:
.sh:
	@rm -f $@
	cp $< $@

PREFIX=$(HOME)
LPREFIX=$(HOME)/.local
INSTALL = atkin  
LINSTALL = func.kbytes func.nice2num func.errecho func.regex

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
func.kbytes: $(HOME)/github/func/func.kbytes.sh
func.nice2num: $(HOME)/github/func/func.nice2num.sh
func.errecho: $(HOME)/github/func/func.insufficient.sh
func.regex: $(HOME)/github/func/func.regex.sh
tester.atkin.sh: func.kbytes func.nice2num func.errecho func.regex

smalltest: atkin
	echo "2^32-1" | bc
	./atkin $(echo "2^32-1" | bc)
bigfailtest: atkin
	echo "2^64-1" | bc
	./atkin $(echo "2^64-1" | bc)
killtest: atkin multitester.atkin.sh tester.atkin.sh
	./multitester.atkin.sh
