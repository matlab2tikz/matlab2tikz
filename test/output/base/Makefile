# ./Makefile

ECHOCMD:=/bin/echo -e
LATEX:=pdflatex --shell-escape
TARGET:=acid

main:
	cd data/reference/ && $(MAKE)
	cd data/converted/ && $(MAKE)
	@$(LATEX) $(TARGET)

.PHONY: clean

clean:
	@rm -f $(TARGET).aux \
	$(TARGET).log \
	$(TARGET).nav \
	$(TARGET).out \
	$(TARGET).snm \
	$(TARGET).toc \
	$(TARGET).vrb \
	$(TARGET).pdf \
	$(TARGET).dvi \
	$(TARGET).ps \
	missfont.log
	@rm -f *~
	cd data/reference/ && $(MAKE) clean
	cd data/converted/ && $(MAKE) clean

distclean: clean
	@rm -f $(TARGET).tex
	cd data/reference/ && $(MAKE) distclean
	cd data/converted/ && $(MAKE) distclean
