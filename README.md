[![Build LuaRocks module on Linux](https://github.com/tsafin/c-dt-ffi/actions/workflows/luarocks-build-linux.yml/badge.svg)](https://github.com/tsafin/c-dt-ffi/actions/workflows/luarocks-build-linux.yml) [![Build LuaRocks module on MacOSX](https://github.com/tsafin/c-dt-ffi/actions/workflows/luarocks-build-macos.yml/badge.svg)](https://github.com/tsafin/c-dt-ffi/actions/workflows/luarocks-build-macos.yml)

# LuaJIT module for datetime parsing and manipulations

## Prerequisites

LuaJIT 2.0+ or Tarantool 1.10+.

## SYNOPSIS

```
tarantoolctl rocks make

...
tarantool> cdt = require 'c-dt-ffi'
---
...

tarantool> dt1 = cdt{ year = 2020, month = 10, day = 10 }
---
...

tarantool> dt = cdt('2020-10-10')
---
...

tarantool> dt == dt1
---
- true
...

tarantool> dt = cdt('2020-10-10T12:00')
---
...

tarantool> dt1 = cdt{ year = 2020, month = 10, day = 10, hour = 12, minute = 0 }
---
...

tarantool> dt == dt1
---
- true
...

```

