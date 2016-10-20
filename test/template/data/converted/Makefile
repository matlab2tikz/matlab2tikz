# ./Makefile

ECHOCMD:=/bin/echo -e
LATEX:=pdflatex --shell-escape -interaction=batchmode

TEST_SRCS:=$(wildcard test*-converted.tex)
TEST_PDFS:=$(TEST_SRCS:.tex=.pdf)

default: $(TEST_PDFS)

%.pdf: %.tex
	@$(LATEX) $<

.PHONY: clean

clean:
	rm -f test*-converted.aux \
		test*-converted.log \
		test*-converted.pdf

distclean: clean
	rm -f test*-converted.tex \
		test*-converted*.png
