.SUFFIXES: .4gl .42m 

.4gl.42m:
	fglcomp -M -W all -r $<

all: fglmakedepend.42m

demo: fglmakedepend.42m demo.42m
	./fglmakedepend demo.42m

clean_prog:
	rm -f fglmakedepend.42m

clean: clean_prog
	rm -f *.42?
