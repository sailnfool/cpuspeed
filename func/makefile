.PHONY: all scripts
.ONESHELL:
all: linstall
scripts:
	cd scripts
	make uninstall linstall
	cd ..
test:
	cd tests
	bash dotests.sh
	cd ..
linstall:
	cd scripts
	make uninstall linstall clean
	cd ..
uninstall:
	cd scripts
	make uninstall
	cd ..
