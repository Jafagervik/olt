# Aliases
alias b := build
alias rf := run-file
alias c := clean
alias af := allf
alias ad := alld
alias d := debug


# Recipes
alld fname: debug
    ./bin/olt {{fname}} 

allf fname: build
    ./bin/olt {{fname}} 

build:
    odin build src/ -out:bin/olt -o:speed -build-mode:exe

debug:
    odin build src/ -out:bin/olt -debug -vet -vet-tabs -disallow-do -warnings-as-errors -strict-style -build-mode:exe

run-file fname:
    ./bin/olt {{fname}}

clean:
    rm -rf ./bin/*

test:
    odin test src/ && rm src.bin
