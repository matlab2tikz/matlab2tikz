# ./Makefile

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###

ECHOCMD:=/bin/echo -e
PDFLATEX:=lualatex

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###

TARGET:=acid

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# 

default: main

#main:
main: eps2pdf
	@$(PDFLATEX) $(TARGET)

.PHONY: clean

# make sure the EPS files got converted to PDFs
eps2pdf:
	@echo -e -n "Building PDF files..."
	@find ../data/ -name "*.eps" -exec epstopdf {} \;
	@echo -e " done.\n\n"
	
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

distclean: clean
	@rm -f ../data/*
	@rm -f $(TARGET).tex
