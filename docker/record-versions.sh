#!/usr/bin/env bash
# Records the tool versions present in the image to $FHIR_HOME/VERSIONS.txt,
# surfaced at runtime by `fhir-tools versions`.
set -euo pipefail

FHIR_HOME="${FHIR_HOME:-/opt/fhir}"

# Neither publisher.jar nor validator_cli.jar sets Implementation-Version, but both
# name their own core artefact in the manifest Class-Path — read it from there.
jar_version() {
  python3 - "$1" "$2" <<'PY'
import re, sys, zipfile
manifest = zipfile.ZipFile(sys.argv[1]).read("META-INF/MANIFEST.MF").decode("utf-8", "replace")
manifest = manifest.replace("\r\n", "\n").replace("\n ", "")   # unfold 72-char wrapping
hit = re.search(sys.argv[2], manifest)
print(hit.group(1) if hit else "unknown")
PY
}

{
  echo "HL7 FHIR publishing toolchain"
  echo "ig-publisher : $(jar_version "${FHIR_HOME}/publisher.jar" 'publisher\.core-([0-9][^/ ]*?)\.jar')"
  echo "validator    : $(jar_version "${FHIR_HOME}/validator_cli.jar" 'fhir\.validation-([0-9][^/ ]*?)\.jar')"
  echo "sushi        : $(sushi --version 2>/dev/null | tail -n1)"
  echo "gofsh        : $(gofsh --version 2>/dev/null | tail -n1)"
  echo "java         : $(java -version 2>&1 | head -n1)"
  echo "node         : $(node --version)"
  echo "npm          : $(npm --version)"
  echo "ruby         : $(ruby --version)"
  echo "jekyll       : $(jekyll --version)"
  echo "graphviz     : $(dot -V 2>&1)"
  echo "git          : $(git --version)"
} > "${FHIR_HOME}/VERSIONS.txt"

cat "${FHIR_HOME}/VERSIONS.txt"
