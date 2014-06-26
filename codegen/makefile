C_FILES := $(wildcard lib/*.c)
OBJ_FILES := $(addprefix obj/,$(notdir $(C_FILES:.c=.out)))

lib: umcont.out $(OBJ_FILES)
	ar rvs umcont.a $^

umcont.out: $(OBJ_FILES)
	g++ -c -o umcont.out umcont.cpp

obj/%.out: lib/%.c
	gcc -c -o $@ $<

clean:
	rm obj/*.out

test1: lib
	g++ -o test1.out test1.cpp umcont.a

test2: lib
	g++ -o test2.out test2.cpp umcont.a
