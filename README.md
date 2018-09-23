# fglmakedepend Makefile dependency generator for Genero projects

## Description

This tool uses Genero .42m modules to generate Makefile dependency rules from it and created .d files.
The dependency rules are included in the target Makefile (with a '-' sign, so they do not have to exist upon first invocation of Make)

typical usage is after the fglcomp step of a 4gl file


```
%.42m: %.4gl 
	fglcomp -M --resolve-calls $* && fglmakedepend $@
```

Email comments/suggestions/wishes to : l s a t 4 j s d o t c o m
