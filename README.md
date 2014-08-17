= OpenGL bindings for Crystal =

**This is a work in progress**

These are bindings for OpenGL and some other related libraries (GLFW, SOIL, GLM, SDL, etc.). Currently only tested on Mac OS X, but probably should work on Linux with minor modifications.

The SDL version is broken since SDL 1.2 only creates OpenGL 2 contexts and there's no way to request a 3.0 context. Migrating to SDL2 is planned for the future.

== Running ==

You need Crystal 0.4 or later. You also need to have GLFW 3, GLEW (`brew install glfw3 glew` should do it), and [libSOIL](https://github.com/ggiraldez/libSOIL) which is being used to load textures. This might be eventually deprecated by SDL2_image when we make bindings for SDL2.

With all dependencies installed, run:

`crystal --run test_glfw.cr`

