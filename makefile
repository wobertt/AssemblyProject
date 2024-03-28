MARS = java -jar /Users/robertchung/.vscode/extensions/triciopo.vscode-mips-0.3.1/mars.jar

%: %.asm
	$(MARS) ./$<