.PHONY: all scripts
.ONESHELL:
all: scripts
scripts:
	cd func
	make uninstall install
	cd ..
	cd scripts
	make uninstall install
	cd ..
test:
	cd tests
	bash dotests.sh
	cd ..
