#!/bin/bash

# Exit the script if the given command fails.
function check {
  "$@"
  status=$?
  if [ $status -ne 0 ]; then
    echo "ERROR: Encountered error (${status}) while running the following:" >&2
    echo "           $@"  >&2
    echo "       (at line ${BASH_LINENO[0]} of file $0.)"  >&2
    echo "       Aborting." >&2
    exit $status
  fi
}

echo "gofmt"
check diff -u <(echo -n) <(gofmt -d $(find . -type f -name '*.go' -not -path "./vendor/*"))
for pkg in $(go list ./... | grep -v '/vendor/' ); do
    echo "testing $pkg"
    echo "go vet $pkg"
    check go vet "$pkg"
    echo "go test -v $pkg"
    check go test -v -timeout 180s "$pkg"
    echo "go test -v -race $pkg"
    GOMAXPROCS=4 check go test -v -timeout 180s -race "$pkg"
done
