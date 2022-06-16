.PHONY: all scripts
.ONESHELL:
all: func scripts src
func:
	cd func
	make uninstall install
	cd ..
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
