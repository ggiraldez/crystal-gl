CRYSTAL = crystal
LIBSOIL = soil

all: test_glfw

$(LIBSOIL)/libSOIL.so:
	make -C $(LIBSOIL)

libsoil: $(LIBSOIL)/libSOIL.so

test_glfw: libsoil
	env LD_LIBRARY_PATH="$(PWD)/$(LIBSOIL)" LIBRARY_PATH="$(PWD)/$(LIBSOIL)" $(CRYSTAL) build test_glfw.cr

run_test_glfw: test_glfw
	env LD_LIBRARY_PATH="$(PWD)/$(LIBSOIL)" LIBRARY_PATH="$(PWD)/$(LIBSOIL)" ./test_glfw

clean:
	rm test_glfw
	make -C $(LIBSOIL) clean
