local ffi = require('ffi')
local cdt = ffi.load(package.searchpath('c-dt', package.cpath), true)

ffi.cdef [[

    // dt_config.h
    enum {
    /* Chronological Julian Date, January 1, 4713 BC, Monday
    #define DT_EPOCH_OFFSET 1721425
    */

    /* Network Time Protocol (NTP), January 1, 1900, Monday
    #define DT_EPOCH_OFFSET -693596
    */

    /* Unix, January 1, 1970, Thursday
    #define DT_EPOCH_OFFSET -719163
    */

    /* Rata Die, January 1, 0001, Monday (as Day 1) */
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

    // datetime with timezone
    struct t_datetime_tz {
        int secs;
        int nsec;
        int offset;
    };

    struct t_datetime_duration {
        int secs;
        int nsec;
    };

]]

local SECS_PER_DAY = 86400
local NANOS_PER_SEC = 1000000000

local datetime_t = ffi.typeof('struct t_datetime_tz')
local duration_t = ffi.typeof('struct t_datetime_duration')

local function duration_new()
    local delta = ffi.new(duration_t)
    return delta
end

local function adjusted_secs(dt)
    return dt.secs - dt.offset * 60
end

local function datetime_sub(lhs, rhs)
    local s1 = adjusted_secs(lhs)
    local s2 = adjusted_secs(rhs)
    local d = duration_new()
    d.secs = s2 - s1
    d.nsec = rhs.nsec - lhs.nsec
    if d.nsec < 0 then
        d.secs = d.secs - 1
        d.nsec = d.nsec + NANOS_PER_SEC
    end
    return d
end

local function datetime_add(lhs, rhs)
    local s1 = adjusted_secs(lhs)
    local s2 = adjusted_secs(rhs)
    local d = duration_new()
    d.secs = s2 + s1
    d.nsec = rhs.nsec - lhs.nsec
    if d.nsec >= NANOS_PER_SEC then
        d.secs = d.secs + 1
        d.nsec = d.nsec - NANOS_PER_SEC
    end
    return d
end

local function datetime_eq(lhs, rhs)
    if rhs == nil then
        return false
    end
    -- FIXME - timezone?
    return (lhs.secs == rhs.secs) and (lhs.nsec == rhs.nsec)
end


local function datetime_lt(lhs, rhs)
    if rhs == nil then
        return false
    end

    -- FIXME - timezone?
    return (lhs.secs < rhs.secs) or
           (lhs.secs == rhs.secs and lhs.nsec < rhs.nsec)
end

local function datetime_le(lhs, rhs)
    if rhs == nil then
        return false
    end

    -- FIXME - timezone?
    return (lhs.secs <= rhs.secs) or
           (lhs.secs == rhs.secs and lhs.nsec <= rhs.nsec)
end

local function datetime_tostring(self)
    return string.format('DateTime:{secs: %d. nsec: %d, offset:%d}',
                         self.secs, self.nsec, self.offset)
end

local function datetime_serialize(self)
    -- Allow YAML, MsgPack and JSON to dump objects with sockets
    return { secs = self.secs, nsec = self.nsec, tz = self.offset }
end

local function duration_tostring(self)
    return string.format('Duration:{secs: %d. nsec: %d}', self.secs, self.nsec)
end

local function duration_serialize(self)
    -- Allow YAML and JSON to dump objects with sockets
    return { secs = self.secs, nsec = self.nsec }
end

local datetime_mt = {
    -- __tostring = datetime_tostring,
    __serialize = datetime_serialize,
    __eq = datetime_eq,
    __lt = datetime_lt,
    __le = datetime_le,
    __sub = datetime_sub,
    __add = datetime_add,
}

local duration_mt = {
    -- __tostring = duration_tostring,
    __serialize = duration_serialize,
    __eq = datetime_eq,
    __lt = datetime_lt,
    __le = datetime_le,
}

local function datetime_new(o)
    local dt = ffi.new(datetime_t)
    if o then
        dt.secs = o.secs or 0
        dt.nsec = o.nsec or 0
        dt.offset = o.offset or 0
    end
    return dt
end

local function mk_timestamp(dt, sp, fp, offset)
    -- print(debug.traceback())
    local dtVal = dt ~= nil and (cdt.dt_rdn(dt[0]) - 719163) * SECS_PER_DAY or 0
    local spVal = sp ~= nil and sp[0] or 0
    local fpVal = fp ~= nil and fp[0] or 0
    local ofsVal = offset ~= nil and offset[0] or 0
    return datetime_new {
        secs = dtVal + spVal - ofsVal * 60,
        nsec = fpVal,
        offset = ofsVal,
    }
end

-- simple parse functions:
-- parse_date/parse_time/parse_zone

--[[
    Basic      Extended
    20121224   2012-12-24   Calendar date   (ISO 8601)
    2012359    2012-359     Ordinal date    (ISO 8601)
    2012W521   2012-W52-1   Week date       (ISO 8601)
    2012Q485   2012-Q4-85   Quarter date
]]

local function parse_date(str)
    local dt = ffi.new('dt_t[1]')
    local rc = cdt.dt_parse_iso_date(str, #str, dt)
    assert(rc > 0)
    return mk_timestamp(dt)
end

--[[
    Basic               Extended
    T12                 N/A
    T1230               T12:30
    T123045             T12:30:45
    T123045.123456789   T12:30:45.123456789
    T123045,123456789   T12:30:45,123456789

    The time designator [T] may be omitted.
]]
local function parse_time(str)
    local sp = ffi.new('int[1]')
    local fp = ffi.new('int[1]')
    local rc = cdt.dt_parse_iso_time(str, #str, sp, fp)
    assert(rc > 0)
    return mk_timestamp(nil, sp, fp)
end

--[[
    Basic    Extended
    Z        N/A
    ±hh      N/A
    ±hhmm    ±hh:mm
]]
local function parse_zone(str)
    local offset = ffi.new('int[1]')
    local rc = cdt.dt_parse_iso_zone(str, #str, offset)
    assert(rc > 0)
    return mk_timestamp(nil, nil, nil, offset)
end


--[[
    aggregated parse functions
    assumes to deal with date T time time_zone
    at once

    date [T] time [ ] time_zone
]]
local function parse_str(str)
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

local parser = {
    parse = parse_str,
    parse_date = parse_date,
    parse_time = parse_time,
    parse_zone = parse_zone,
}

local function datetime_fmt()
end

local format = {
    fmt = datetime_fmt
}

ffi.metatype(duration_t, duration_mt)
ffi.metatype(datetime_t, datetime_mt)

return setmetatable({
        datetime = datetime_new,
        delta = duration_new,
        parser = parser,
        format = format,
    }, {
        __call = function(self, ...) return parse_str(...) end
    }
)
-- vim: ts=4 sts=4 sw=4 et
