#!/bin/sh
# Map the "shiny" account to the arbitrary UID assigned by OpenShift
[ -w /etc/passwd ] || exit 0
tempfile=$(mktemp)
grep -v "^shiny:" /etc/passwd > "$tempfile"
echo "shiny:x:$(id -u):$(id -g)::/tmp:/bin/sh" >> "$tempfile"
cat "$tempfile" > /etc/passwd
rm -f "$tempfile"