C_FILES := $(wildcard matlab_c/*.c)
OBJ_FILES := $(addprefix obj/,$(notdir $(C_FILES:.c=.out)))

all: lib include

lib: $(OBJ_FILES)
	mkdir -p lib
	ar rvsc lib/qp_kalman_lib.a $^

include:
	mkdir -p include
	cp matlab_c/qp_vars.h include/
	cp matlab_c/kalman_4d.h include/
	cp definitions.h include/

obj/%.out: matlab_c/%.c
	mkdir -p obj
	gcc -c -o $@ $<

clean:
	rm -rf lib
	rm -rf obj
	rm -rf include
