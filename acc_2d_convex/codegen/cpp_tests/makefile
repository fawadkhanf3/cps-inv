C_FILES := $(wildcard ../matlab_c/*.c)
OBJ_FILES := $(addprefix obj/,$(notdir $(C_FILES:.c=.out)))

lib: cpp_wrapper.out $(OBJ_FILES)
	ar rvs cpp_wrapper.a $^

cpp_wrapper.out: $(OBJ_FILES)
	g++ -I/usr/local/include -c -o cpp_wrapper.out cpp_wrapper.cpp

obj/%.out: ../matlab_c/%.c
	mkdir -p obj
	gcc -c -o $@ $<

clean:
	rm -rf obj
	rm *.out

test1: cpp_wrapper.out lib
	g++ -o test1.out test1.cpp cpp_wrapper.a

test2: cpp_wrapper.out lib
	g++ -o test2.out test2.cpp cpp_wrapper.a
