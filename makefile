.PHONY: all scripts
.ONESHELL:
all: scripts
scripts:
	cd scripts
	make uninstall install
	cd ..
	cd func
	make uninstall install
	cd ..
test:
	cd tests
	bash dotests.sh
	cd ..
install:
	cd scripts
	make uninstall install clean
	cd ..
sinstall:
	cd scripts
	make suninstall sinstall clean
	cd ..
suninstall:
	cd scripts
	make suninstall clean
