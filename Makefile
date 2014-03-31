# This makefile creates a release tarball.

MATLAB2TIKZ_DIR=.
VERSION=0.4.7

default: release

release:
	# The license is automatically added by
	# MathWorks after the upload.
	@zip -r matlab2tikz_${VERSION}.zip \
     ${MATLAB2TIKZ_DIR}/AUTHORS \
     ${MATLAB2TIKZ_DIR}/ChangeLog \
     ${MATLAB2TIKZ_DIR}/README.md \
     ${MATLAB2TIKZ_DIR}/THANKS \
     ${MATLAB2TIKZ_DIR}/version-${VERSION} \
     ${MATLAB2TIKZ_DIR}/tools/ \
     ${MATLAB2TIKZ_DIR}/src/

clean:
	rm -f matlab2tikz_${VERSION}.zip
