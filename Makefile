all: make

make:
	luarocks make --local
	luarocks pack --local c-dt-ffi

check:
	luacheck --codes .
