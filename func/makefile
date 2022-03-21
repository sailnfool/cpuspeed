.PHONY: all scripts
.ONESHELL:
all: install
scripts:
	cd scripts
	make uninstall install
	cd ..
test:
	cd tests
	bash dotests.sh
	cd ..
install:
	cd scripts
	make uninstall linstall clean
	cd ..
uninstall:
	cd scripts
	make uninstall
	cd ..
