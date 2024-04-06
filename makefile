MARS = java -jar Mars_Updated.jar
FLAGS = nc

%: %.asm
	$(MARS) $(FLAGS) $<