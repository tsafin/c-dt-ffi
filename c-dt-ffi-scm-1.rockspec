package = 'c-dt-ffi'

version = 'scm-1'

source  = {
    url    = 'git://github.com/tsafin/c-dt-ffi.git';
}

description = {
    summary  = "LuaJIT utility code for datetime operations";
    detailed = [[
    This is LuaJIT ffi wrapper over chansen/c-dt C implementation.
    The fastest known ISO 8601 parsing code ever.
    ]];
    homepage = 'https://github.com/tsafin/c-dt-ffi.git';
    maintainer = "Timur Safin <tsafin@tarantool.org>";
    license  = 'BSD2';
}

dependencies = {
  'lua >= 5.1',
}

build = {
    type = 'builtin';
    modules = {
        ['c-dt-ffi'] = 'c-dt-ffi/init.lua',
    }
}
