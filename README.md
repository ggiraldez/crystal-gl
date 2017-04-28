# OpenGL bindings for Crystal

**This is a work in progress!**

These are bindings for OpenGL and some other related libraries (GLFW, SOIL, GLM, etc.). Currently only tested on Mac OS X, but probably should work on Linux with minor modifications.

Vestigial SDL support. It doesn't work ;)

## Running

You need Crystal 0.22 or later. You also need to have GLFW 3, GLEW (`brew install glfw3 glew` should do it), and [libSOIL](https://github.com/ggiraldez/libSOIL) which is being used to load textures.

With all dependencies installed, run:

```sh
$ crystal test_glfw.cr
```
