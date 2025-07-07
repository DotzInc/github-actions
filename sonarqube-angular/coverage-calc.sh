#!/usr/bin/env bash

COVERAGE=$(python -c "import xml.etree.ElementTree as ET; \
print(float(ET.parse('coverage.xml').getroot().attrib['line-rate']) * 100)")

echo "coverage=$COVERAGE" >> $GITHUB_OUTPUT
echo "legacy_coverage=$COVERAGE" >> $GITHUB_OUTPUT
