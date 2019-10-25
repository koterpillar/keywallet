all: keywallet.stl

bin/extopenscad: stack.yaml stack.yaml.lock
	mkdir -p bin
	stack install --local-bin-path bin implicit

%.stl: %.escad bin/extopenscad
	./bin/extopenscad --output $@ --format stl $<
