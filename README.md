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

tarantool> cdt.parser.parse('2015-02-19T01:00:00+03:00')
---
- sp: 1424296800
  op: 180
  np: 0
...

tarantool> cdt.parser.parse('2015-02-19T01:00:00.12347474+03:00')
---
- sp: 1424296800
  op: 180
  np: 123474740
...

tarantool> cdt.parser.parse('2015-02-19T01:00:00.12347474Z')
---
- sp: 1424307600
  op: 0
  np: 123474740
...

tarantool> cdt.parser.parse('2015-02-19T01:00:00.12347474+0300')
---
- sp: 1424296800
  op: 180
  np: 123474740
...

tarantool> cdt.parser.parse('2015-02-19T010000.12347474+0300')
---
- sp: 1424296800
  op: 180
  np: 123474740
...

tarantool> cdt.parser.parse('20150219T010000.12347474+0300')
---
- sp: 1424296800
  op: 180
  np: 123474740
...

```

