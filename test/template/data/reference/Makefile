# ./Makefile

EPSTOPDF:=epstopdf

REFERENCE_EPSS:=$(wildcard test*-reference.eps)
REFERENCE_PDFS:=$(REFERENCE_EPSS:.eps=.pdf)

default: $(REFERENCE_PDFS)

%.pdf: %.eps
	$(EPSTOPDF) $<

.PHONY: clean

clean:
	rm -f test*-reference.pdf

distclean: clean
	rm -f test*-reference.eps
