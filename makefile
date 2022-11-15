.PHONY: all scripts
.ONESHELL:
all: scripts src
scripts:
	cd scripts
	make uninstall install
	cd ..
src:
	cd src
	make uninstall install
	cd ..
test:
	cd tests
	bash dotests.sh
	cd ..
