![Build module](https://github.com/tsafin/c-dt-ffi/workflows/Build%20LuaRocks%20module%20for%20Tarantool/badge.svg)

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

