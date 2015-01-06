

main:

test: createtests
	./runtests

createtests:
	./create_tests

.PHONY: clean

distclean:
	rm -f testlist.m
	cd ./data/reference/ && $(MAKE) distclean
	cd ./data/converted/ && $(MAKE) distclean
