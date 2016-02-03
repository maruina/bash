#!/bin/bash

main () {
    echo "Total number of arguments: $#"
    echo "First argument: $1"
    echo "From second on: ${@:2}"
    echo ""
}

main "one"
main "one" "two" "three"
main "one two three"
main one two three
