all: keywallet.stl

bin/extopenscad: stack.yaml stack.yaml.lock
	mkdir -p bin
	stack install --local-bin-path bin implicit

%.stl: %.escad bin/extopenscad
	./bin/extopenscad --output $@ --format stl $<

%.um2.gcode: %.stl
	CuraEngine slice -v -j /usr/share/cura/resources/definitions/ultimaker2_plus.def.json -s layer_height=0.15 -o $@ -l $<
