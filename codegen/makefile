C_FILES := $(wildcard lib/*.c)
OBJ_FILES := $(addprefix obj/,$(notdir $(C_FILES:.c=.out)))

main: lib
	g++ main.cpp umcont.a

lib: umcont.out $(OBJ_FILES)
	ar rvs umcont.a $^

umcont.out: $(OBJ_FILES)
	g++ -c -o umcont.out umcont.cpp

obj/%.out: lib/%.c
	gcc -c -o $@ $<

clean:
	rm obj/*.out