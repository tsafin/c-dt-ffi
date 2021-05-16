all: make

make: c-dt.so

c-dt.so: c-dt-ffi-scm-1.rockspec c-dt-ffi/init.lua
	luarocks make --local
	luarocks pack --local c-dt-ffi

check: c-dt-ffi/init.lua spec/cdt_spec.lua
	luacheck --codes .

test: make
	busted --lua=tarantool
