# This makefile creates a release tarball.

MATLAB2TIKZ_DIR=.
VERSION=0.2.3

PACKAGE_DIR=matlab2tikz-${VERSION}

default: release

release:
	# The license is automatically added by
	# Mathworks after the upload.
	@zip -r matlab2tikz_${VERSION}.zip \
     ${MATLAB2TIKZ_DIR}/AUTHORS \
     ${MATLAB2TIKZ_DIR}/ChangeLog \
     ${MATLAB2TIKZ_DIR}/README.md \
     ${MATLAB2TIKZ_DIR}/THANKS \
     ${MATLAB2TIKZ_DIR}/src/

clean:
	rm -f matlab2tikz_${VERSION}.zip
