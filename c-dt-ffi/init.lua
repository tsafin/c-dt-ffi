local ffi = require('ffi')
local cdt = ffi.load(package.searchpath('c-dt', package.cpath), true)

ffi.cdef [[

    // dt_config.h
    enum {
        DT_EPOCH_OFFSET = 0
    };


    typedef int dt_t;
    
    // dt_core.h
    typedef enum {
        DT_MON       = 1,
        DT_MONDAY    = 1,
        DT_TUE       = 2,
        DT_TUESDAY   = 2,
        DT_WED       = 3,
        DT_WEDNESDAY = 3,
        DT_THU       = 4,
        DT_THURSDAY  = 4,
        DT_FRI       = 5,
        DT_FRIDAY    = 5,
        DT_SAT       = 6,
        DT_SATURDAY  = 6,
        DT_SUN       = 7,
        DT_SUNDAY    = 7,
    } dt_dow_t;

    dt_t     dt_from_rdn     (int n);
    dt_t     dt_from_yd      (int y, int d);
    dt_t     dt_from_ymd     (int y, int m, int d);
    dt_t     dt_from_yqd     (int y, int q, int d);
    dt_t     dt_from_ywd     (int y, int w, int d);

    void     dt_to_yd        (dt_t dt, int *y, int *d);
    void     dt_to_ymd       (dt_t dt, int *y, int *m, int *d);
    void     dt_to_yqd       (dt_t dt, int *y, int *q, int *d);
    void     dt_to_ywd       (dt_t dt, int *y, int *w, int *d);

    int      dt_rdn          (dt_t dt);
    dt_dow_t dt_dow          (dt_t dt);

    // dt_parse_iso.h
    size_t dt_parse_iso_date          (const char *str, size_t len, dt_t *dt);

    size_t dt_parse_iso_time          (const char *str, size_t len, int *sod, int *nsec);
    size_t dt_parse_iso_time_basic    (const char *str, size_t len, int *sod, int *nsec);
    size_t dt_parse_iso_time_extended (const char *str, size_t len, int *sod, int *nsec);

    size_t dt_parse_iso_zone          (const char *str, size_t len, int *offset);
    size_t dt_parse_iso_zone_basic    (const char *str, size_t len, int *offset);
    size_t dt_parse_iso_zone_extended (const char *str, size_t len, int *offset);
    size_t dt_parse_iso_zone_lenient  (const char *str, size_t len, int *offset);

]]

local function mk_timestamp(dt, sp, fp, offset)
    local spVal = sp ~= nil and sp[0] or 0
    local fpVal = fp ~= nil and fp[0] or 0
    local ofsVal = offset ~= nil and offset[0] or 0
    return {
        sp = (cdt.dt_rdn(dt[0]) - 719163) * 86400 + spVal - ofsVal * 60,
        np = fpVal,
        op = ofsVal,
    }
end

local parser = {
    parse_date = function(str)
        local dt = ffi.new('dt_t[1]')
        local rc = cdt.dt_parse_iso_date(str, #str, dt)
        assert(rc > 0)
        return rc > 0 and dt[0] or nil
    end,

    parse_time = function(str)
        local sp = ffi.new('int[1]')
        local fp = ffi.new('int[1]')
        local rc = cdt.dt_parse_iso_time(str, #str, sp, fp)
        assert(rc > 0)
        return rc > 0 and {sp[0], fp[0]} or nil
    end,

    parse_zone = function(str)
        local offset = ffi.new('int[1]')
        local rc = cdt.dt_parse_iso_zone(str, #str, offset)
        assert(rc > 0)
        return rc > 0 and offset[0] or nil
    end,

    parse = function(str)
        local dt = ffi.new('dt_t[1]')
        local len = #str
        local n = cdt.dt_parse_iso_date(str, len, dt)
        if n == 0 or len == n then
            return mk_timestamp(dt)
        end

        str = str:sub(tonumber(n) + 1)

        local ch = str:sub(1,1)
        if ch ~= 't' and ch ~= 'T' and ch ~= ' ' then
            return mk_timestamp(dt)
        end

        str = str:sub(2)
        len = #str

        local sp = ffi.new('int[1]')
        local fp = ffi.new('int[1]')
        local n = cdt.dt_parse_iso_time(str, len, sp, fp)
        if n == 0 then
            return mk_timestamp(dt)
        end
        if len == n then
            return mk_timestamp(dt, sp, fp)
        end

        str = str:sub(tonumber(n) + 1)

        if str:sub(1,1) == ' ' then
            str = str:sub(2)
        end

        len = #str

        local offset = ffi.new('int[1]')
        n = cdt.dt_parse_iso_zone(str, len, offset)
        if n == 0 then
            return mk_timestamp(dt, sp, fp)
        end
        return mk_timestamp(dt, sp, fp, offset)
    end
}

return {
    parser = parser,
    format = {},
    date = {},
    time = {},
    delta = {},
}
-- vim: ts=4 sts=4 sw=4 et
