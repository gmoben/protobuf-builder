#!/bin/bash
#
# Sets up the pre-commit hook for compiling the protobuf definitions

echo """#!/bin/bash
make compile && git add compiled
exit $?
""" > .git/hooks/pre-commit

chmod 755 .git/hooks/pre-commit

echo "Successfully installed hook to .git/hooks/pre-commit"
echo "Protobuf definitions will now auto-compile and be added before every commit."
