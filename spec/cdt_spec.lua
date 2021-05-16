local date = require('c-dt-ffi')

describe("Testing the 'c-dt-ffi' module", function()
    it("Tests for parser", function()
        assert(date("Jul 27 2006 03:56:28 +2:00") ==
              date {year=2006, month=7, day=27, hour=1, minute=56, second=28})
        assert(date("Jul 27 2006 -75 ") ==
              date {year=2006, month=7, day=27, hour=1, minute=15})
        assert(date("Jul 27 2006 -115") ==
              date {year=2006, month=7, day=27, hour=1, minute=15})
        assert(date("Jul 27 2006 +10 ") ==
              date {year=2006, month=7, day=26, hour=14})
        assert(date("Jul 27 2006 +2  ") ==
              date {year=2006, month=7, day=26, hour=22})
    end)
end)
