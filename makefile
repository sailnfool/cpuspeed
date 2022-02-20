.PHONY: all scripts
.ONESHELL:
all: install
scripts:
	cd scripts
	make uninstall install 
	cd ..
func:
	cd func
	make uninstall install
	cd ..
install:
	cd scripts
	make uninstall install clean
	cd func
	makd uninstall install
	cd ..
sinstall:
	cd scripts
	make suninstall sinstall clean
	cd ..
suninstall:
	cd scripts
	make suninstall clean
