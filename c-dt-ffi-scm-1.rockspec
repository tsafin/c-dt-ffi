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
        ['c-dt'] = {
            sources = {
                'c-dt/dt_accessor.c',
                'c-dt/dt_arithmetic.c',
                'c-dt/dt_char.c',
                'c-dt/dt_core.c',
                'c-dt/dt_dow.c',
                'c-dt/dt_easter.c',
                'c-dt/dt_length.c',
                'c-dt/dt_navigate.c',
                'c-dt/dt_parse_iso.c',
                'c-dt/dt_search.c',
                'c-dt/dt_tm.c',
                'c-dt/dt_util.c',
                'c-dt/dt_valid.c',
                'c-dt/dt_weekday.c',
                'c-dt/dt_workday.c',
                'c-dt/dt_zone.c',
            }
        },
        ['c-dt-ffi'] = 'c-dt-ffi/init.lua',
    }
}
