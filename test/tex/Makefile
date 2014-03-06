# ./Makefile

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###

ECHOCMD:=/bin/echo -e
PDFLATEX:=lualatex --shell-escape

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###

TARGET:=acid

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# 

default: main

#main:
main:
	@$(PDFLATEX) $(TARGET)

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

distclean: clean
	@rm -f ../data/*
	@rm -f $(TARGET).tex
