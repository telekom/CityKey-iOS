#!/bin/sh
# Cheack for forbidden Commands

#separate forbidden Commands 
KEYWORDS="(fopen|chmod|chown|stat|mktemp|printf|strcat|strcpy|strncat|strncpy|vsprintf|gets)"
git ls-tree --full-tree -r --name-only HEAD | grep "\.*" | xargs egrep -s --with-filename --line-number --only-matching "$KEYWORDS[(].*[)].*$" | perl -p -e "s/($KEYWORDS)/ warning: Are you sure you want to use \$1?\nTo remove this warning, append a comment at the end of this line \$1/" > "${DERIVED_FILE_DIR}/output.txt"

