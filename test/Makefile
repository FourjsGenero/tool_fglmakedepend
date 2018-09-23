%.42m: %.4gl 
	fglcomp -M --resolve-calls $* && ../fglmakedepend $@

MODULES=$(patsubst %.4gl,%.42m,$(wildcard *.4gl))

all: $(MODULES)

-include $(MODULES:.42m=.d)

echo:
	echo "MODULES:$(MODULES)"
	echo "depends:$(MODULES:.42m=.d)"

clean:
	rm -f *.42* *.d
