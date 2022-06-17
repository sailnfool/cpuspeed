SHELL=/bin/bash
.PHONY: atkin
.ONESHELL:
INSTALL = atkin

EXECDIR := $(HOME)/bin

atkin: atkin.c
	gcc  atkin.c -lm -o atkin
install: $(INSTALL)
	mkdir -p $(EXECDIR)
	install -g $(USER) -o $(USER) -c $? $(EXECDIR)
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

smalltest: atkin
	echo "2^32-1" | bc
	./atkin $(echo "2^32-1" | bc)
bigfailtest: atkin
	echo "2^64-1" | bc
	./atkin $(echo "2^64-1" | bc)
killtest: atkin multitester.atkin.sh tester.atkin.sh
	./multitester.atkin.sh
