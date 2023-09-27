SHELL := /usr/bin/env -S bash -o pipefail

EMACS ?= emacs

####################################################################################################

ifeq ($(shell hash poetry > /dev/null 2>&1 && echo INSTALLED || echo MISSING),MISSING)

$(error Command 'poetry' not installed or in path)

endif

####################################################################################################

.PHONY : help

help :
	@printf "\
Main targets\n\
compile    -- compile .el files\n\
elpa 	   -- create a package with the elpa format \n\
package    -- create a tar.gz file with the .el files \n\
test       -- run tests in batch mode\n\
clean      -- delete generated files\n\
lint       -- run package-lint in batch mode\n\
help       -- print this message\n"


####################################################################################################

.PHONY : package

package : *.el
	@ver=`grep -o "Version: .*" rail.el | cut -c 10-`; \
	tar czvf rail-$$ver.tar.gz --mode 644 $$(find . -name \*.el)

####################################################################################################

.PHONY : elpa

elpa : *.el
	@version=`grep -o "Version: .*" rail.el | cut -c 10-`; \
	dir=rail-$$version; \
	mkdir -p "$$dir"; \
	cp $$(find . -name \*.el) rail-$$version; \
	echo "(define-package \"rail\" \"$$version\" \
	\"Modular in-buffer completion framework\")" \
	> "$$dir"/rail-pkg.el; \
	tar cvf rail-$$version.tar --mode 644 "$$dir"

####################################################################################################

.PHONY : clean
clean :
	-@rm -rf *.elc ert.el .elpa/ $$(find . -print | grep -i ".elc")

####################################################################################################

.PHONY : make-test

make-test:
	${EMACS}  --batch -l test/make-install.el -l test/make-test.el

####################################################################################################

.PHONY : test

test : make-test clean

####################################################################################################

.PHONY : compile

compile :
	${EMACS} --batch -l test/make-install.el -L . -f batch-byte-compile rail.el $$(find . -print | grep -i "rail-")

####################################################################################################

.PHONY : compile-test

compile-test : compile clean

####################################################################################################

.PHONY : lint

lint :
	${EMACS} --batch -l test/make-install.el -f package-lint-batch-and-exit $$(find . -print | grep -i "rail-")
