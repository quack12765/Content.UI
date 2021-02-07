------------
-- Donxon Global Properties.
--
-- Properties that are accessible at a global level.
--
-- @global Properties

--- Empty function.
--
local g_emptyFunc = function()end

--- @section end


------------
-- Donxon Global Functions.
--
-- Functions that are accessible at a global level.
--
-- @global Functions


--- Checks whether `Game` module is loaded.
--
-- @treturn bool Returns true if Game module is loaded.
function IsGameModule ()
    return Game ~= nil and type(Game) == "table";
end


--- Checks whether `UI` module is loaded.
--
-- @treturn bool Returns true if UI module is loaded.
function IsUIModule ()
    return UI ~= nil and type(UI) == "table";
end


--- Asserts based on value's data type.
--
-- @tparam string name The value's variable name.
-- @tparam string datatype The expected data type.
-- @tparam anything value The value to checks.
-- @tparam[opt] string level The value's level (property, class, function, etc).
-- @tparam[opt] bool condition The condition to be satisfied.
-- @tparam[opt] number hop Uses `error` instead and this is error level hopping number.
function AssertType ( name, datatype, value, level, condition, hop )
    if level == nil then level = '';
    else level = (level .. ' '); end
    if condition == nil then condition = (type( value ) == datatype); end
    if hop == nil then hop = 0; end

    local msg = level.. "`" ..name.. "` expected " ..datatype.. ", got " .. type( value ) .. " instead.";
    if hop > 0 then
        if not condition then
            error( msg, hop );
        end
    else
        assert( condition, msg );
    end
end


--- Math Library
--
-- @section math

--- Clamps a number between a minimum and maximum value.
--
-- @tparam number min The minimum value, this function will never return a number less than this.
-- @tparam number max The maximum value, this function will never return a number greater than this.
-- @tparam number value The number to clamp.
-- @treturn number The clamped value.
function math.clamp (min, max, value)
    return math.min( max, math.max( min , value ) );
end


--- Rounds the number.
--
-- @tparam number num The value to round.
-- @tparam[opt=0] number numDecimalPlaces The number of decimal place(s).
-- @treturn number The rounded number.
function math.round (num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num));
end


--- String Library
--
-- @section string

--- Splits a string into a `table`.
--
-- @string source The string to explode.
-- @string delimiter The string delimiter.
-- @treturn table The result.
function string.explode (source , delimiter)
    local t, l, ll
    t={}
    ll=0
    if(#source == 1) then
        return {source}
    end
    while true do
        l = string.find(source, delimiter, ll, true) -- find the next d in the string
        if l ~= nil then -- if "not not" found then..
            table.insert(t, string.sub(source,ll,l-1)) -- Save it in our array.
            ll = l + 1 -- save just after where we found it for searching next time.
        else
            table.insert(t, string.sub(source,ll)) -- Save what's left in our array.
            break -- Break at end, as it should be, according to the lua manual.
        end
    end
    return t
end


--- Table Library
--
-- @section table


--- The extended table.
--
-- @struct .extendedTable
-- @tfield table _base The base table.
-- @tfield table _parent The parent table inheret from. It could be same as `_base`.
-- @field ... The derived table's members.


--- The extended table's metatable.
--
-- @struct .extendedMetatable
-- @tfield[opt=false] bool __hasWriteOnlyMember This table has write-only member(s).
-- @tfield[opt=false] bool __functionSelfOverride Sets derived table as `self` when accessing base's functions.
-- @tfield ?table|function|nil __index_old The original __index.
-- @tfield function __index The extended __index.
-- @tfield ?table|function|nil __newindex_old The original __newindex.
-- @tfield function __newindex The extended __newindex.


--- Sets the `table` access to read-only using `metatable`.
--
-- @tparam table table The table to set.
-- @string[opt] msg The error message when invokes table editing.
-- @treturn table The result.
function table.readonly (table, msg)
    msg = msg or "read-only table.";
    return setmetatable({}, {
        __index = table,
        __newindex = function()
            error(msg, 2);
        end,
        __metatable = false
    });
end


--- Extends a `table` using `metatable`.
--
-- @tparam table base The base index table.
-- @tparam table derived The derived table.
-- @bool[opt] hasWriteOnlyMember Base table has write-only members.
-- @bool[opt] functionSelfOverride Sets derived table as `self` when accessing base or parent's functions.
-- @treturn .extendedTable The extended derived table.
function table.extend (base, derived, hasWriteOnlyMember, functionSelfOverride)
    assert( base ~= derived , "Can't extend with same table address." );
    if hasWriteOnlyMember == nil then hasWriteOnlyMember = false; end
    if functionSelfOverride == nil then functionSelfOverride = false; end
    AssertType( "hasWriteOnlyMember", "boolean", hasWriteOnlyMember, nil, nil, 2 );
    AssertType( "functionSelfOverride", "boolean", functionSelfOverride, nil, nil, 2 );

    derived._base = derived._base or base._base or base;
    derived._parent = derived._parent or derived._base;
    local mt = getmetatable( derived );
    mt = (type(mt) == "table") and mt or {};
    mt.__hasWriteOnlyMember = hasWriteOnlyMember;
    mt.__functionSelfOverride = functionSelfOverride;
    mt.__index_old = mt.__index;
    mt.__index = function (self, key)
        local result = nil;
        -- Use derived metamethod.
        if mt.__index_old then
            if type(mt.__index_old) == "function" then
                result = mt.__index_old(self, key);
            else
                result = mt.__index_old[key];
            end
        end

        -- Use parent/base table.
        if result == nil then
            local parent = rawget(self, "_parent"); -- Use parent table.
            if parent == nil then parent = rawget(self, "_base"); end -- Use base table.
            if parent then
                result = parent[key];

                if type( result ) == "function" then
                    result = function (this, ...)
                        if not mt.__functionSelfOverride and this == self then this = parent; end
                        return parent[key](this, ...);
                    end;
                end
            end
        end

        return result;
    end;
    mt.__newindex_old = mt.__newindex;
    mt.__newindex = function (self, key, value)
        -- Use derived metamethod.
        if mt.__newindex_old then
            if type(mt.__newindex_old) == "function" then
                mt.__newindex_old(self, key, value);
            else
                mt.__newindex_old[key] = value;
            end
            return;
        end

        -- Use parent/base table.
        local tipe = type(value);
        local parent = self._parent; -- Use parent table.
        if parent == nil then parent = self._base; end -- Use base table.
        if parent then
            if mt.__hasWriteOnlyMember and tipe ~= "number" and tipe ~= "string"
            then
                parent[key] = value;
                return;

            else
                if parent[key] ~= nil
                then
                    parent[key] = value;
                    return;
                end
            end
        end

        -- Otherwise, usual value assignment.
        rawset( self, key, value );
    end;

    return setmetatable(derived, mt);
end


--- Merges two tables.
--
-- @tparam table target The target table to merge with.
-- @tparam table source The source table.
-- @tparam[opt=false] bool deep Do recursive merge.
-- @treturn table The merget target table.
function table.merge (target, source, deep)
    if deep == nil then deep = false; end
    AssertType( "target", "table", target, nil, nil, 2 );
    AssertType( "source", "table", source, nil, nil, 2 );

    for k,v in pairs( source ) do
        if deep and type(v) == 'table' and type( target[k] or false ) == 'table' then
            table.merge( target[k], v );
        else
            target[k] = v;
        end
    end

    return target;
end


--- Clones a table.
--
-- @tparam table source The source table to clone.
-- @tparam[opt=true] bool deep Do recursive copy.
-- @tparam[opt=nil] table seen Last seen sub-table.
-- @treturn table The cloned table.
function table.clone ( source, deep, seen )
    seen = seen or {};
    if source == nil then return nil; end
    if seen[ source ] then return seen[ source ]; end

    local result;
    if type( source ) == 'table' then
        result = {};

        if deep then
            seen[ source ] = result;
            for k, v in next, source, nil do
                result[ table.clone(k, seen) ] = table.clone( v, seen );
            end
            setmetatable( result, table.clone( getmetatable( source ), seen ) );

        else
            for k, v in pairs( source ) do
                result[ k ] = v;
            end
        end
    else -- number, string, boolean, etc.
        result = source;
    end

    return result;
end

--- @section end


------------
-- Donxon Global Classes.
--
-- Classes that are accessible at a global level.
--
-- @global Classes


--- Debug class.
--
-- Built-in debugging tools.
--
-- @tfield Debug Debug


--- String Buffer class.
--
-- Fast string buffer with "Tower of Hanoi" strategy algorithm.
--
-- @tfield StringBuffer StringBuffer


--- Hook Management class.
--
-- Creating multiple hooks become more easier.
--
-- @tfield Hook Hook

--- @section end


------------
-- Debug class.
--
-- Built-in debugging tools.
--
-- @classmod Debug
Debug = {};

--- Debug mode.
--
-- @tfield bool enable Set to `true` to enable debug mode.
Debug.enable = true;


--- Methods
-- @section method

--- Prints a debug message into console.
--
-- **Note:** Is active when debug mode (`enable`) is enabled.
--
-- @param ... Receives any number of arguments and prints their values.
function Debug.print (...)
    if not Debug.enable then return; end
    print( "[D]" , (IsGameModule() and "[G]" or "[U]"), ... );
end


--- Metamethods
-- @section metamethod


--- Event Callbacks
-- @section callback

--- @section end


------------
-- String Buffer class.
--
-- Fast string buffer with "Tower of Hanoi" strategy algorithm.
--
-- @classmod StringBuffer
local StringBuffer = {};


--- Methods
-- @section method

--- Checks whether the table is compatible with string buffer class.
--
-- @local
-- @tparam table v The table to check.
-- @bool[opt=true] checkMembers Asserts members data type.
-- @treturn bool Return true if table is compatible.
function StringBuffer:AssertTable ( v , checkMembers )
    AssertType( "v", "table", v, nil, nil, 3 );
    checkMembers = (checkMembers == nil) and true or checkMembers;
    if checkMembers then
        AssertType( "content", "table", v.content, "property", nil, 3 );
    end

    return true;
end


--- Constructs a string buffer.
--
-- @tparam[opt=""] string init The init string.
-- @treturn StringBuffer A new string buffer.
function StringBuffer:Create ( init )
    -- Class properties.
    local o =
    {
        content = { init or "" }
    };

    setmetatable( o, StringBuffer );

    -- Checks again.
    self:AssertTable( o );

    return o;
end


--- Returns the buffered string.
--
-- @treturn string The buffered string.
function StringBuffer:ToString ()
    return table.concat( self.content );
end


--- Metamethods
-- @section metamethod

--- Base class.
-- @tfield StringBuffer __index
StringBuffer.__index = StringBuffer;


--- Returns the buffered string.
-- @tfield StringBuffer.ToString __tostring
StringBuffer.__tostring = StringBuffer.ToString;


--- Returns a concatenated form of this string buffer.
--
-- @tparam string val The string to concat.
function StringBuffer:__concat ( val )
    local stack = self.content;
    table.insert( stack, val );   -- push 's' into the the stack
    for i = #stack - 1, 1, -1 do
        if string.len( stack[i] ) > string.len( stack[i+1] ) then
            break;
        end
        stack[i] = stack[i] .. table.remove( stack );
    end
    return self;
end


--- Returns the length of this string buffer.
--
-- @treturn number The length of this string buffer.
function StringBuffer:__len ()
    return string.len( self:ToString() );
end


--- Event Callbacks
-- @section callback

--- @section end


------------
-- Hook Management class.
--
-- Creating multiple hooks become more easier.
--
-- @classmod Hook
Hook = {};

--- Hook function return codes.
--
Hook.RETURN = {
    CONTINUE = function()end,  -- Returned when a hook function has not handled the call.
    HANDLED  = function()end,  -- Returned when a hook function has handled the call.
}; Hook.RETURN = table.readonly( Hook.RETURN );


--- The hook doubly-linked list.
--
-- @struct .hookLink
-- @tfield .hookLink _previous The previous link.
-- @tfield function _current The hook function.
-- @tfield .hookLink _next The next link.


--- The hook index page table.
--
-- @struct .hookIndexPage
-- @tfield table _container The hook container parent table.
-- @tfield table _base The base hook class.
-- @tfield string _name The hook name.
-- @tfield .hookLink _first The first hook.
-- @tfield .hookLink _last The last hook.


--- The hook container table.
--
-- @struct .hookContainer
-- @tfield table _base The base hook class.
-- @tfield {[string]=.hookIndexPage,...} _hooks The hook index pages.


--- The hook container's metatable.
--
-- @struct .hookContainerMetatable
-- @tfield[opt] string|string[]|function __hookNameComparator The comparator of hook method name (Lua Regex | Hook name list | Comparator function). (_default_ "[Oo]n%u.*")
-- @tfield[opt=false] bool __functionSelfOverride Sets hook table as `self` when accessing base's functions.


--- Methods
-- @section method

--- Creates a hook container.
--
-- @tparam table base The base hook class.
-- @tparam[opt] ?string|string[]|function hookNameComparator The comparator of hook method name (Lua Regex | Hook name list | Comparator function). (_default_ "[Oo]n%u.*")
-- @tparam[opt=false] bool functionSelfOverride Sets hook table as `self` when accessing base's functions.
-- @treturn .hookContainer A hook container.
function Hook:Create ( base, hookNameComparator, functionSelfOverride )
    if hookNameComparator == nil then hookNameComparator = "[Oo]n%u.*"; end
    if functionSelfOverride == nil then functionSelfOverride = false; end
    AssertType( "hookNameComparator", "string|table|function", hookNameComparator, nil, type(hookNameComparator) == "string" or type(hookNameComparator) == "table" or type(hookNameComparator) == "function", 2 );
    AssertType( "functionSelfOverride", "boolean", functionSelfOverride, nil, nil, 2 );

    local mt = {};
    mt.__hookNameComparator = hookNameComparator;
    mt.__functionSelfOverride = functionSelfOverride;
    mt.__index = function (self, key)
        local result = rawget( self, "_hooks" )[key];
        if not result then
            local base = rawget( self, "_base" );

            if base then
                result = base[key];
                if type( result ) == "function" then
                    return function (this, ...)
                        if not mt.__functionSelfOverride and this == self then this = base; end
                        return base[key](this, ...);
                    end;
                end
            end
        end
        return result;
    end;
    mt.__newindex = function (self, key, value)
        local isHook = (type(value) == "function");

        -- Checks with hook name comparator.
        local comparator = mt.__hookNameComparator;
        if isHook and comparator then
            if type(comparator) == "string" then
                isHook = key:find( comparator );

            elseif type(comparator) == "table" then
                isHook = false;
                for _,v in pairs( comparator ) do
                    if v == key then
                        isHook = true;
                        break;
                    end
                end

            elseif type(comparator) == "function" then
                isHook = comparator( key );
            end
        end

        -- Is a hook method.
        if isHook then
            local hooks = self._hooks;
            if type(hooks[key]) ~= "table" then
                hooks[key] = setmetatable( { _container = self, _base = self._base, _name = key }, {
                    __call = function (...)
                        local varags = {...};
                        if varags[1] == hooks[key] then table.remove( varags, 1 ); end
                        return self._base[key]( table.unpack(varags) );
                    end });
                local func = Hook:Link( value );
                hooks[key]._first = func;
                hooks[key]._last = func;
                self._base[key] = func;
                Debug.print( "[H]", "(C)", key);
            else
                local temp = Hook:Link( value, hooks[key]._last );
                hooks[key]._last._next = temp;
                rawset( hooks[key], "_last", temp );
            end
            Debug.print( "[H]", "(L)", key);

        -- A regular value assigning.
        else
            self._base[key] = value;
        end
    end;

    return setmetatable({
        _base = base,
        _hooks = {},
    }, mt );
end


--- Creates a doubly linked list of a hook.
--
-- @local
-- @func func The hook function to link.
-- @tparam[opt] table prev The previous link.
-- @tparam[opt] table nxt The next link.
-- @treturn .hookLink A linked hook.
function Hook:Link ( func, prev, nxt )
    AssertType( "func", "function", func, nil, nil, 2 );
    AssertType( "prev", "table", prev, nil, prev == nil or type(prev) == "table", 2 );
    AssertType( "nxt", "table", nxt, nil, nxt == nil or type(nxt) == "table", 2 );

    local o = {_previous = prev, _current = func, _next = nxt};
    return setmetatable(o, {
        __call = function ( ... )
            local varags = {...};
            if varags[1] == o then table.remove( varags, 1 ); end
            local nextCall = o._next or g_emptyFunc;
            if type(o._current) ~= "function" then
                Debug.print( "[H]", "(L)", "Dangling pointer.");
                if type(o._next) == "table" then
                    o._next._previous = o._previous;
                end
                if type(o._previous) == "table" then
                    o._previous._next = o._next;
                end
                return nextCall( table.unpack(varags) );
            end

            local callReturns = table.pack( o._current( table.unpack(varags) ) );
            local returnCode = callReturns[1];
            if returnCode == Hook.RETURN.CONTINUE then table.remove( callReturns, 1 ); end
            if callReturns.n == 0 then
                callReturns = table.pack( nextCall( table.unpack(varags) ) );
                returnCode = callReturns[1];
            end

            if callReturns.n > 0 then
                if returnCode == Hook.RETURN.HANDLED then return; end
                if #callReturns > 0 then return table.unpack( callReturns ); end
                return nil;
            end
        end
    });
end


--- Removes a hook.
--
-- @tparam table hooks The hook name.
-- @tparam ?function|table func The hook function reference to remove.
-- @treturn boolean Returns `true` if succeed. Otherwise, returns `false`.
function Hook:Remove ( hooks, func )
    AssertType( "hooks", "table", hooks, nil, nil, 2 );
    func = (type(func) == "table") and func._first._current or func;
    AssertType( "func", "function", func, nil, nil, 2 );

    local key = hooks._name;
    local first, last = hooks._first, hooks._last;
    local o = last;
    repeat
        if o._current == func then
            if o == last then
                rawset( hooks, "_last", o._previous );
            end
            if o == first then
                rawset( hooks, "_first", o._next );
                hooks._base[key] = o._next or g_emptyFunc;
            end
            if type(o._next) == "table" then
                o._next._previous = o._previous;
            end
            if type(o._previous) == "table" then
                o._previous._next = o._next;
            end
            o._current = nil;
            Debug.print( "[H]", "(R)", "{GOOD}", key );
            return true;
        end
        o = o._previous;
    until o == nil;

    Debug.print( "[H]", "(R)", "{BAD}", key );
    return false;
end


--- Removes all hooks.
--
-- @tparam table hooks The hook name.
-- @treturn boolean Returns `true` if succeed.
function Hook:RemoveAll ( hooks )
    AssertType( "hooks", "table", hooks, nil, nil, 2 );

    local key = hooks._name;
    hooks._base[key] = g_emptyFunc;
    rawset( hooks._container, "_hooks", {} );
    Debug.print( "[H]", "(RA)", key );
    return true;
end


--- Metamethods
-- @section metamethod


--- Event Callbacks
-- @section callback

--- @section end


------------
-- System module.
--
-- This module contains any stuffs related to external systems such as operating system, game fonts, etc.
--
-- @module System


--[[=========================================================
--  [SYSTEM] Pre-loading.
=========================================================--]]

--- System module.
--
-- @local
-- @tfield System System
System = {};


--- The system font.
--
-- @struct .systemFont
-- @tfield number defaultCharWidth The default character width.
-- @tfield table charWidth The list of character width.

--- System fonts.
--
-- @local
-- @table System.FONT
System.FONT = {};


--- YGO340 font.
--
-- Default font for CSO Korea, and CSNS (Nexon).
--
-- Including Basic Greek, Basic Latin, Bopomofo, CJK, Cyrillic, Hangul, Katakana, Hiragana.
--
-- @tfield .systemFont YGO340
System.FONT.YGO340 = {};
System.FONT.YGO340.defaultCharWidth = 920;
System.FONT.YGO340.charWidth = {[32]=350,[33]=308,[34]=319,[35]=530,[36]=545,[37]=812,[38]=696,[39]=205,[40]=333,[41]=333,[42]=528,[43]=656,[44]=299,[45]=635,[46]=299,[47]=446,[48]=562,[49]=562,[50]=562,[51]=562,[52]=562,[53]=562,[54]=562,[55]=562,[56]=562,[57]=562,[58]=460,[59]=460,[60]=452,[61]=635,[62]=457,[63]=598,[64]=863,[65]=686,[66]=630,[67]=678,[68]=663,[69]=593,[70]=569,[71]=706,[72]=672,[73]=229,[74]=464,[75]=651,[76]=544,[77]=790,[78]=679,[79]=707,[80]=606,[81]=707,[82]=625,[83]=598,[84]=586,[85]=650,[86]=684,[87]=837,[88]=619,[89]=622,[90]=571,[91]=332,[92]=1008,[93]=332,[94]=608,[95]=526,[96]=197,[97]=563,[98]=602,[99]=546,[100]=602,[101]=575,[102]=287,[103]=594,[104]=567,[105]=229,[106]=237,[107]=549,[108]=229,[109]=805,[110]=567,[111]=575,[112]=602,[113]=602,[114]=358,[115]=502,[116]=287,[117]=567,[118]=522,[119]=706,[120]=501,[121]=524,[122]=489,[123]=410,[124]=351,[125]=410,[126]=891,[167]=386,[176]=258,[178]=368,[179]=368,[184]=350,[185]=368,[720]=253,[731]=350,[945]=612,[946]=558,[947]=598,[948]=557,[949]=492,[950]=442,[951]=497,[952]=474,[953]=225,[954]=488,[955]=534,[956]=497,[957]=570,[958]=442,[959]=570,[960]=708,[961]=524,[963]=616,[964]=474,[965]=497,[966]=621,[967]=557,[968]=639,[969]=745,[8216]=240,[8217]=240,[8220]=410,[8221]=410,[8242]=258,[8243]=432,[8308]=368,[8319]=368,[8321]=368,[8322]=368,[8323]=368,[8324]=368,[8706]=423,[12289]=331,[12290]=258,[12296]=430,[12297]=430,[12298]=460,[12299]=460,[12300]=368,[12301]=368,[12302]=368,[12303]=368,[12304]=450,[12305]=450,[12308]=304,[12309]=304,[51120]=922,[65288]=390,[65289]=390,[65339]=390,[65341]=390,[65371]=450,[65373]=450,[65536]=1000,[65537]=0,[65538]=1000,};

--- DFYuanW9_GB font.
--
-- Default font for CSO China (Tiancity).
--
-- Including Basic Greek, Basic Latin, Bopomofo, CJK, Cyrillic, Hangul, Katakana, Hiragana, Yijing.
--
-- @tfield .systemFont DFYuanW9_GB
System.FONT.DFYuanW9_GB = {};
System.FONT.DFYuanW9_GB.defaultCharWidth = 1024;
System.FONT.DFYuanW9_GB.charWidth = {[1]=512,[2]=512,[3]=512,[4]=512,[5]=512,[6]=512,[7]=512,[8]=512,[9]=512,[10]=512,[11]=512,[12]=512,[13]=512,[14]=512,[15]=512,[16]=512,[17]=512,[18]=512,[19]=512,[20]=512,[21]=512,[22]=512,[23]=512,[24]=512,[25]=512,[26]=512,[27]=512,[28]=512,[29]=512,[30]=512,[31]=512,[32]=512,[33]=512,[34]=512,[35]=512,[36]=512,[37]=512,[38]=512,[39]=512,[40]=512,[41]=512,[42]=512,[43]=512,[44]=512,[45]=512,[46]=512,[47]=512,[48]=512,[49]=512,[50]=512,[51]=512,[52]=512,[53]=512,[54]=512,[55]=512,[56]=512,[57]=512,[58]=512,[59]=512,[60]=512,[61]=512,[62]=512,[63]=512,[64]=512,[65]=512,[66]=512,[67]=512,[68]=512,[69]=512,[70]=512,[71]=512,[72]=512,[73]=512,[74]=512,[75]=512,[76]=512,[77]=512,[78]=512,[79]=512,[80]=512,[81]=512,[82]=512,[83]=512,[84]=512,[85]=512,[86]=512,[87]=512,[88]=512,[89]=512,[90]=512,[91]=512,[92]=512,[93]=512,[94]=512,[95]=512,[96]=512,[97]=512,[98]=512,[99]=512,[100]=512,[101]=512,[102]=512,[103]=512,[104]=512,[105]=512,[106]=512,[107]=512,[108]=512,[109]=512,[110]=512,[111]=512,[112]=512,[113]=512,[114]=512,[115]=512,[116]=512,[117]=512,[118]=512,[119]=512,[120]=512,[121]=512,[122]=512,[123]=512,[124]=512,[125]=512,[126]=512,[65537]=512,[65538]=512,[65539]=512,[65540]=512,[65541]=512,[65542]=512,[65543]=512,[65544]=512,[65545]=512,[65546]=512,[65547]=512,[65548]=512,[65549]=512,[65550]=512,[65551]=512,[65552]=512,[65553]=512,[65554]=512,[65555]=512,[65556]=512,[65557]=512,[65558]=512,[65559]=512,[65560]=512,[65561]=512,[65562]=512,[65563]=512,[65564]=512,[65565]=512,[65566]=512,[65567]=512,[65568]=512,[65569]=512,[65570]=512,[65571]=512,[65572]=512,[65573]=512,[65574]=512,[65575]=512,[65576]=512,[65577]=512,[65578]=512,[65579]=512,[65580]=512,[65581]=512,[65582]=512,[65583]=512,[65584]=512,[65585]=512,[65586]=512,[65587]=512,[65588]=512,[65589]=512,[65590]=512,[65591]=512,[65592]=512,[65593]=512,[65594]=512,[65595]=512,[65596]=512,[65597]=512,[65598]=512,[65599]=512,[65600]=512,[65601]=512,[65602]=512,[65603]=512,[65604]=512,[65605]=512,[65606]=512,[65607]=512,[65608]=512,[65609]=512,[65610]=512,[65611]=512,[65612]=512,[65613]=512,[65614]=512,[65615]=512,[65616]=512,[65617]=512,[65618]=512,[65619]=512,[65620]=512,[65621]=512,[65622]=512,[65623]=512,[65624]=512,[65625]=512,[65626]=512,[65627]=512,[65628]=512,[65629]=512,[65630]=512,[65631]=512,[65632]=512,[65633]=512,[65634]=512,[65635]=512,[65636]=512,[65637]=512,[65638]=512,[65639]=512,[65640]=512,[65641]=512,[65642]=512,[65643]=512,[65644]=512,[65645]=512,[65646]=512,[65647]=512,[65648]=512,[65649]=512,[65650]=512,[65651]=512,[65652]=512,[65653]=512,[65654]=512,[65655]=512,[65656]=512,[65657]=512,[65658]=512,[65659]=512,[65660]=512,[65661]=512,[65662]=512,[65663]=512,[65664]=512,[65665]=512,[65666]=512,[65699]=341,[65700]=341,[65701]=370,[65702]=736,[65703]=736,[65704]=962,[65705]=820,[65706]=241,[65707]=341,[65708]=341,[65709]=423,[65710]=514,[65711]=315,[65712]=341,[65713]=315,[65714]=285,[65715]=736,[65716]=736,[65717]=736,[65718]=736,[65719]=736,[65720]=736,[65721]=736,[65722]=736,[65723]=736,[65724]=736,[65725]=315,[65726]=315,[65727]=514,[65728]=514,[65729]=514,[65730]=613,[65731]=820,[65732]=771,[65733]=715,[65734]=716,[65735]=723,[65736]=711,[65737]=699,[65738]=713,[65739]=733,[65740]=355,[65741]=656,[65742]=675,[65743]=673,[65744]=815,[65745]=712,[65746]=728,[65747]=706,[65748]=735,[65749]=719,[65750]=709,[65751]=677,[65752]=702,[65753]=692,[65754]=812,[65755]=683,[65756]=712,[65757]=702,[65758]=341,[65759]=285,[65760]=341,[65761]=453,[65762]=512,[65763]=341,[65764]=615,[65765]=585,[65766]=565,[65767]=585,[65768]=584,[65769]=471,[65770]=611,[65771]=584,[65772]=355,[65773]=447,[65774]=584,[65775]=355,[65776]=755,[65777]=577,[65778]=590,[65779]=587,[65780]=587,[65781]=455,[65782]=564,[65783]=513,[65784]=571,[65785]=577,[65786]=654,[65787]=551,[65788]=549,[65789]=558,[65790]=341,[65791]=238,[65792]=341,[65793]=341,[65920]=810,[65921]=914,};

--- DFLiYuan_XB font.
--
-- Default font for CSO Taiwan/Hong Kong (Beanfun).
--
-- Including Basic Greek, Basic Latin, Bopomofo, CJK, Cyrillic, Hangul, Katakana, Hiragana, Yijing.
--
-- @tfield .systemFont DFLiYuan_XB
System.FONT.DFLiYuan_XB = {};
System.FONT.DFLiYuan_XB.defaultCharWidth = 1024;
System.FONT.DFLiYuan_XB.charWidth = {[1]=512,[2]=512,[3]=512,[4]=512,[5]=512,[6]=512,[7]=512,[8]=512,[9]=512,[10]=512,[11]=512,[12]=512,[13]=512,[14]=512,[15]=512,[16]=512,[17]=512,[18]=512,[19]=512,[20]=512,[21]=512,[22]=512,[23]=512,[24]=512,[25]=512,[26]=512,[27]=512,[28]=512,[29]=512,[30]=512,[31]=512,[32]=512,[33]=512,[34]=512,[35]=512,[36]=512,[37]=512,[38]=512,[39]=512,[40]=512,[41]=512,[42]=512,[43]=512,[44]=512,[45]=512,[46]=512,[47]=512,[48]=512,[49]=512,[50]=512,[51]=512,[52]=512,[53]=512,[54]=512,[55]=512,[56]=512,[57]=512,[58]=512,[59]=512,[60]=512,[61]=512,[62]=512,[63]=512,[64]=512,[65]=512,[66]=512,[67]=512,[68]=512,[69]=512,[70]=512,[71]=512,[72]=512,[73]=512,[74]=512,[75]=512,[76]=512,[77]=512,[78]=512,[79]=512,[80]=512,[81]=512,[82]=512,[83]=512,[84]=512,[85]=512,[86]=512,[87]=512,[88]=512,[89]=512,[90]=512,[91]=512,[92]=512,[93]=512,[94]=512,[95]=512,[96]=512,[97]=512,[98]=512,[99]=512,[100]=512,[101]=512,[102]=512,[103]=512,[104]=512,[105]=512,[106]=512,[107]=512,[108]=512,[109]=512,[110]=512,[111]=512,[112]=512,[113]=512,[114]=512,[115]=512,[116]=512,[117]=512,[118]=512,[119]=512,[120]=512,[121]=512,[122]=512,[123]=512,[124]=512,[125]=512,[126]=512,[65537]=512,[65538]=512,[65539]=512,[65540]=512,[65541]=512,[65542]=512,[65543]=512,[65544]=512,[65545]=512,[65546]=512,[65547]=512,[65548]=512,[65549]=512,[65550]=512,[65551]=512,[65552]=512,[65553]=512,[65554]=512,[65555]=512,[65556]=512,[65557]=512,[65558]=512,[65559]=512,[65560]=512,[65561]=512,[65562]=512,[65563]=512,[65564]=512,[65565]=512,[65566]=512,[65567]=512,[65568]=512,[65569]=512,[65570]=512,[65571]=512,[65572]=512,[65573]=512,[65574]=512,[65575]=512,[65576]=512,[65577]=512,[65578]=512,[65579]=512,[65580]=512,[65581]=512,[65582]=512,[65583]=512,[65584]=512,[65585]=512,[65586]=512,[65587]=512,[65588]=512,[65589]=512,[65590]=512,[65591]=512,[65592]=512,[65593]=512,[65594]=512,[65595]=512,[65596]=512,[65597]=512,[65598]=512,[65599]=512,[65600]=512,[65601]=512,[65602]=512,[65603]=512,[65604]=512,[65605]=512,[65606]=512,[65607]=512,[65608]=512,[65609]=512,[65610]=512,[65611]=512,[65612]=512,[65613]=512,[65614]=512,[65615]=512,[65616]=512,[65617]=512,[65618]=512,[65619]=512,[65620]=512,[65621]=512,[65622]=512,[65623]=512,[65624]=512,[65625]=512,[65626]=512,[65627]=512,[65628]=512,[65629]=512,[65630]=512,[65631]=512,[65632]=512,[65633]=512,[65634]=512,[65635]=512,[65636]=512,[65637]=512,[65638]=512,[65639]=512,[65640]=512,[65641]=512,[65642]=512,[65643]=512,[65644]=512,[65645]=512,[65646]=512,[65647]=512,[65648]=512,[65649]=512,[65650]=512,[65651]=512,[65652]=512,[65653]=512,[65654]=512,[65655]=512,[65656]=512,[65657]=512,[65658]=512,[65659]=512,[65660]=512,[65661]=512,[65662]=512,[65663]=512,[65664]=512,[65665]=512,[65666]=512,[65699]=341,[65700]=341,[65701]=370,[65702]=736,[65703]=736,[65704]=962,[65705]=820,[65706]=241,[65707]=341,[65708]=341,[65709]=423,[65710]=514,[65711]=315,[65712]=341,[65713]=315,[65714]=285,[65715]=736,[65716]=736,[65717]=736,[65718]=736,[65719]=736,[65720]=736,[65721]=736,[65722]=736,[65723]=736,[65724]=736,[65725]=315,[65726]=315,[65727]=514,[65728]=514,[65729]=514,[65730]=613,[65731]=820,[65732]=771,[65733]=715,[65734]=716,[65735]=723,[65736]=711,[65737]=699,[65738]=713,[65739]=733,[65740]=355,[65741]=656,[65742]=675,[65743]=673,[65744]=815,[65745]=712,[65746]=728,[65747]=706,[65748]=735,[65749]=719,[65750]=709,[65751]=677,[65752]=702,[65753]=692,[65754]=812,[65755]=683,[65756]=712,[65757]=702,[65758]=341,[65759]=285,[65760]=341,[65761]=453,[65762]=512,[65763]=341,[65764]=615,[65765]=585,[65766]=565,[65767]=585,[65768]=584,[65769]=471,[65770]=611,[65771]=584,[65772]=355,[65773]=447,[65774]=584,[65775]=355,[65776]=755,[65777]=577,[65778]=590,[65779]=587,[65780]=587,[65781]=455,[65782]=564,[65783]=513,[65784]=571,[65785]=577,[65786]=654,[65787]=551,[65788]=549,[65789]=558,[65790]=341,[65791]=238,[65792]=341,[65793]=341,[65920]=810,[65921]=914,};

--- Default system font being used in-game.
--
-- @tfield .systemFont default (default `System.FONT.YGO340`).
System.defaultFont = System.FONT.YGO340;


--- Get a char's width size.
--
-- @tparam string char An UTF-8 character.
-- @tparam number height Height size.
-- @treturn number Width.
function System:GetCharWidth( char, height )
    AssertType( "char", "string", char, nil, nil, 3 );
	AssertType( "height", "number", height, nil, nil, 3 );

	local default = self.defaultFont;
	local glyphWidth = default.charWidth[ self.UTF8.byte(char) ];
	if not glyphWidth then glyphWidth = default.defaultCharWidth; end

    return glyphWidth / 1000 * height;
end


--- Classes
-- @section classes

--- UTF-8 library class.
--
-- Provides UTF-8 aware string functions implemented in pure lua.
--
-- All functions behave as their non UTF-8 aware counterparts with the exception
-- that UTF-8 characters are used instead of bytes for all units.
--
-- @tfield System.UTF8 UTF8

--- @section end


------------
-- UTF-8 library class.
--
-- Provides UTF-8 aware string functions implemented in pure lua.
--
-- All functions behave as their non UTF-8 aware counterparts with the exception
-- that UTF-8 characters are used instead of bytes for all units.
--
-- @classmod System.UTF8
System.UTF8 = {};


--- Methods
-- @section method

do
local byte    = string.byte
local char    = string.char
local dump    = string.dump
local find    = string.find
local format  = string.format
local len     = string.len
local lower   = string.lower
local rep     = string.rep
local sub     = string.sub
local upper   = string.upper

-- returns the number of bytes used by the UTF-8 character at byte i in s
-- also doubles as a UTF-8 character validator
local function utf8charbytes (s, i)
	-- argument defaults
	i = i or 1

	-- argument checking
	if type(s) ~= "string" then
		error("bad argument #1 to 'utf8charbytes' (string expected, got ".. type(s).. ")")
	end
	if type(i) ~= "number" then
		error("bad argument #2 to 'utf8charbytes' (number expected, got ".. type(i).. ")")
	end

	local c = byte(s, i)

	-- determine bytes needed for character, based on RFC 3629
	-- validate byte 1
	if c > 0 and c <= 127 then
		-- UTF8-1
		return 1

	elseif c >= 194 and c <= 223 then
		-- UTF8-2
		local c2 = byte(s, i + 1)

		if not c2 then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if c2 < 128 or c2 > 191 then
			error("Invalid UTF-8 character")
		end

		return 2

	elseif c >= 224 and c <= 239 then
		-- UTF8-3
		local c2 = byte(s, i + 1)
		local c3 = byte(s, i + 2)

		if not c2 or not c3 then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if c == 224 and (c2 < 160 or c2 > 191) then
			error("Invalid UTF-8 character")
		elseif c == 237 and (c2 < 128 or c2 > 159) then
			error("Invalid UTF-8 character")
		elseif c2 < 128 or c2 > 191 then
			error("Invalid UTF-8 character")
		end

		-- validate byte 3
		if c3 < 128 or c3 > 191 then
			error("Invalid UTF-8 character")
		end

		return 3

	elseif c >= 240 and c <= 244 then
		-- UTF8-4
		local c2 = byte(s, i + 1)
		local c3 = byte(s, i + 2)
		local c4 = byte(s, i + 3)

		if not c2 or not c3 or not c4 then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if c == 240 and (c2 < 144 or c2 > 191) then
			error("Invalid UTF-8 character")
		elseif c == 244 and (c2 < 128 or c2 > 143) then
			error("Invalid UTF-8 character")
		elseif c2 < 128 or c2 > 191 then
			error("Invalid UTF-8 character")
		end

		-- validate byte 3
		if c3 < 128 or c3 > 191 then
			error("Invalid UTF-8 character")
		end

		-- validate byte 4
		if c4 < 128 or c4 > 191 then
			error("Invalid UTF-8 character")
		end

		return 4

	else
		error("Invalid UTF-8 character")
	end
end

-- returns the number of characters in a UTF-8 string
local function utf8len (s)
	-- argument checking
	if type(s) ~= "string" then
		for k,v in pairs(s) do print('"',tostring(k),'"',tostring(v),'"') end
		error("bad argument #1 to 'utf8len' (string expected, got ".. type(s).. ")")
	end

	local pos = 1
	local bytes = len(s)
	local ln = 0

	while pos <= bytes do
		ln = ln + 1
		pos = pos + utf8charbytes(s, pos)
	end

	return ln
end

-- functions identically to string.sub except that i and j are UTF-8 characters
-- instead of bytes
local function utf8sub (s, i, j)
	-- argument defaults
	j = j or -1

	local pos = 1
	local bytes = len(s)
	local ln = 0

	-- only set l if i or j is negative
	local l = (i >= 0 and j >= 0) or utf8len(s)
	local startChar = (i >= 0) and i or l + i + 1
	local endChar   = (j >= 0) and j or l + j + 1

	-- can't have start before end!
	if startChar > endChar then
		return ""
	end

	-- byte offsets to pass to string.sub
	local startByte,endByte = 1,bytes

	while pos <= bytes do
		ln = ln + 1

		if ln == startChar then
			startByte = pos
		end

		pos = pos + utf8charbytes(s, pos)

		if ln == endChar then
			endByte = pos - 1
			break
		end
	end

	if startChar > ln  then startByte = bytes+1   end
	if endChar   < 1   then endByte   = 0         end

	return sub(s, startByte, endByte)
end

-- identical to string.reverse except that it supports UTF-8
local function utf8reverse (s)
	-- argument checking
	if type(s) ~= "string" then
		error("bad argument #1 to 'utf8reverse' (string expected, got ".. type(s).. ")")
	end

	local bytes = len(s)
	local pos = bytes
	local charbytes
	local newstr = ""

	while pos > 0 do
		local c = byte(s, pos)
		while c >= 128 and c <= 191 do
			pos = pos - 1
			c = byte(s, pos)
		end

		charbytes = utf8charbytes(s, pos)

		newstr = newstr .. sub(s, pos, pos + charbytes - 1)

		pos = pos - 1
	end

	return newstr
end

-- http://en.wikipedia.org/wiki/Utf8
-- http://developer.coronalabs.com/code/utf-8-conversion-utility
local function utf8char(unicode)
	if unicode <= 0x7F then return char(unicode) end

	if (unicode <= 0x7FF) then
		local Byte0 = 0xC0 + math.floor(unicode / 0x40);
		local Byte1 = 0x80 + (unicode % 0x40);
		return char(Byte0, Byte1);
	end;

	if (unicode <= 0xFFFF) then
		local Byte0 = 0xE0 +  math.floor(unicode / 0x1000);
		local Byte1 = 0x80 + (math.floor(unicode / 0x40) % 0x40);
		local Byte2 = 0x80 + (unicode % 0x40);
		return char(Byte0, Byte1, Byte2);
	end;

	if (unicode <= 0x10FFFF) then
		local code = unicode
		local Byte3= 0x80 + (code % 0x40);
		code       = math.floor(code / 0x40)
		local Byte2= 0x80 + (code % 0x40);
		code       = math.floor(code / 0x40)
		local Byte1= 0x80 + (code % 0x40);
		code       = math.floor(code / 0x40)
		local Byte0= 0xF0 + code;

		return char(Byte0, Byte1, Byte2, Byte3);
	end;

	error 'Unicode cannot be greater than U+10FFFF!'
end

local shift_6  = 2^6
local shift_12 = 2^12
local shift_18 = 2^18

local utf8unicode
utf8unicode = function(str, i, j, byte_pos)
	i = i or 1
	j = j or i

	if i > j then return end

	local chr,bytes

	if byte_pos then
		bytes = utf8charbytes(str,byte_pos)
		chr  = sub(str,byte_pos,byte_pos-1+bytes)
	else
		chr,byte_pos = utf8sub(str,i,i), 0
		bytes         = #chr
	end

	local unicode

	if bytes == 1 then unicode = byte(chr) end
	if bytes == 2 then
		local byte0,byte1 = byte(chr,1,2)
		local code0,code1 = byte0-0xC0,byte1-0x80
		unicode = code0*shift_6 + code1
	end
	if bytes == 3 then
		local byte0,byte1,byte2 = byte(chr,1,3)
		local code0,code1,code2 = byte0-0xE0,byte1-0x80,byte2-0x80
		unicode = code0*shift_12 + code1*shift_6 + code2
	end
	if bytes == 4 then
		local byte0,byte1,byte2,byte3 = byte(chr,1,4)
		local code0,code1,code2,code3 = byte0-0xF0,byte1-0x80,byte2-0x80,byte3-0x80
		unicode = code0*shift_18 + code1*shift_12 + code2*shift_6 + code3
	end

	return unicode,utf8unicode(str, i+1, j)
end

-- Returns an iterator which returns the next substring and its byte interval
local function utf8gensub(str, sub_len)
	sub_len        = sub_len or 1
	local byte_pos = 1
	local ln      = #str
	return function(skip)
		if skip then byte_pos = byte_pos + skip end
		local char_count = 0
		local start      = byte_pos
		repeat
			if byte_pos > ln then return end
			char_count  = char_count + 1
			local bytes = utf8charbytes(str,byte_pos)
			byte_pos    = byte_pos+bytes

		until char_count == sub_len

		local last  = byte_pos-1
		local sb   = sub(str,start,last)
		return sb, start, last
	end
end

local function binsearch(sortedTable, item, comp)
	local head, tail = 1, #sortedTable
	local mid = math.floor((head + tail)/2)
	if not comp then
		while (tail - head) > 1 do
			if sortedTable[tonumber(mid)] > item then
				tail = mid
			else
				head = mid
			end
			mid = math.floor((head + tail)/2)
		end
	else
	end
	if sortedTable[tonumber(head)] == item then
		return true, tonumber(head)
	elseif sortedTable[tonumber(tail)] == item then
		return true, tonumber(tail)
	else
		return false
	end
end
local function classMatchGenerator(class, plain)
	local codes = {}
	local ranges = {}
	local ignore = false
	local range = false
	local firstletter = true
	local unmatch = false

	local it = utf8gensub(class)

	local skip
	for c,be in it do
		skip = be
		if not ignore and not plain then
			if c == "%" then
				ignore = true
			elseif c == "-" then
				table.insert(codes, utf8unicode(c))
				range = true
			elseif c == "^" then
				if not firstletter then
					error('!!!')
				else
					unmatch = true
				end
			elseif c == ']' then
				break
			else
				if not range then
					table.insert(codes, utf8unicode(c))
				else
					table.remove(codes) -- removing '-'
					table.insert(ranges, {table.remove(codes), utf8unicode(c)})
					range = false
				end
			end
		elseif ignore and not plain then
			if c == 'a' then -- %a: represents all letters. (ONLY ASCII)
				table.insert(ranges, {65, 90}) -- A - Z
				table.insert(ranges, {97, 122}) -- a - z
			elseif c == 'c' then -- %c: represents all control characters.
				table.insert(ranges, {0, 31})
				table.insert(codes, 127)
			elseif c == 'd' then -- %d: represents all digits.
				table.insert(ranges, {48, 57}) -- 0 - 9
			elseif c == 'g' then -- %g: represents all printable characters except space.
				table.insert(ranges, {1, 8})
				table.insert(ranges, {14, 31})
				table.insert(ranges, {33, 132})
				table.insert(ranges, {134, 159})
				table.insert(ranges, {161, 5759})
				table.insert(ranges, {5761, 8191})
				table.insert(ranges, {8203, 8231})
				table.insert(ranges, {8234, 8238})
				table.insert(ranges, {8240, 8286})
				table.insert(ranges, {8288, 12287})
			elseif c == 'l' then -- %l: represents all lowercase letters. (ONLY ASCII)
				table.insert(ranges, {97, 122}) -- a - z
			elseif c == 'p' then -- %p: represents all punctuation characters. (ONLY ASCII)
				table.insert(ranges, {33, 47})
				table.insert(ranges, {58, 64})
				table.insert(ranges, {91, 96})
				table.insert(ranges, {123, 126})
			elseif c == 's' then -- %s: represents all space characters.
				table.insert(ranges, {9, 13})
				table.insert(codes, 32)
				table.insert(codes, 133)
				table.insert(codes, 160)
				table.insert(codes, 5760)
				table.insert(ranges, {8192, 8202})
				table.insert(codes, 8232)
				table.insert(codes, 8233)
				table.insert(codes, 8239)
				table.insert(codes, 8287)
				table.insert(codes, 12288)
			elseif c == 'u' then -- %u: represents all uppercase letters. (ONLY ASCII)
				table.insert(ranges, {65, 90}) -- A - Z
			elseif c == 'w' then -- %w: represents all alphanumeric characters. (ONLY ASCII)
				table.insert(ranges, {48, 57}) -- 0 - 9
				table.insert(ranges, {65, 90}) -- A - Z
				table.insert(ranges, {97, 122}) -- a - z
			elseif c == 'x' then -- %x: represents all hexadecimal digits.
				table.insert(ranges, {48, 57}) -- 0 - 9
				table.insert(ranges, {65, 70}) -- A - F
				table.insert(ranges, {97, 102}) -- a - f
			else
				if not range then
					table.insert(codes, utf8unicode(c))
				else
					table.remove(codes) -- removing '-'
					table.insert(ranges, {table.remove(codes), utf8unicode(c)})
					range = false
				end
			end
			ignore = false
		else
			if not range then
				table.insert(codes, utf8unicode(c))
			else
				table.remove(codes) -- removing '-'
				table.insert(ranges, {table.remove(codes), utf8unicode(c)})
				range = false
			end
			ignore = false
		end

		firstletter = false
	end

	table.sort(codes)

	local function inRanges(charCode)
		for _,r in ipairs(ranges) do
			if r[1] <= charCode and charCode <= r[2] then
				return true
			end
		end
		return false
	end
	if not unmatch then
		return function(charCode)
			return binsearch(codes, charCode) or inRanges(charCode)
		end, skip
	else
		return function(charCode)
			return charCode ~= -1 and not (binsearch(codes, charCode) or inRanges(charCode))
		end, skip
	end
end


local cache = setmetatable({},{
	__mode = 'kv'
})
local cachePlain = setmetatable({},{
	__mode = 'kv'
})
local function matcherGenerator(regex, plain)
	local matcher = {
		functions = {},
		captures = {}
	}
	if not plain then
		cache[regex] =  matcher
	else
		cachePlain[regex] = matcher
	end
	local function simple(func)
		return function(cC)
			if func(cC) then
				matcher:nextFunc()
				matcher:nextStr()
			else
				matcher:reset()
			end
		end
	end
	local function star(func)
		return function(cC)
			if func(cC) then
				matcher:fullResetOnNextFunc()
				matcher:nextStr()
			else
				matcher:nextFunc()
			end
		end
	end
	local function minus(func)
		return function(cC)
			if func(cC) then
				matcher:fullResetOnNextStr()
			end
			matcher:nextFunc()
		end
	end
	local function question(func)
		return function(cC)
			if func(cC) then
				matcher:fullResetOnNextFunc()
				matcher:nextStr()
			end
			matcher:nextFunc()
		end
	end

	local function capture(id)
		return function(cC)
			local l = matcher.captures[id][2] - matcher.captures[id][1]
			local captured = utf8sub(matcher.string, matcher.captures[id][1], matcher.captures[id][2])
			local check = utf8sub(matcher.string, matcher.str, matcher.str + l)
			if captured == check then
				for i = 0, l do
					matcher:nextStr()
				end
				matcher:nextFunc()
			else
				matcher:reset()
			end
		end
	end
	local function captureStart(id)
		return function(cC)
			matcher.captures[id][1] = matcher.str
			matcher:nextFunc()
		end
	end
	local function captureStop(id)
		return function(cC)
			matcher.captures[id][2] = matcher.str - 1
			matcher:nextFunc()
		end
	end

	local function balancer(str)
		local sum = 0
		local bc, ec = utf8sub(str, 1, 1), utf8sub(str, 2, 2)
		local skip = len(bc) + len(ec)
		bc, ec = utf8unicode(bc), utf8unicode(ec)
		return function(cC)
			if cC == ec and sum > 0 then
				sum = sum - 1
				if sum == 0 then
					matcher:nextFunc()
				end
				matcher:nextStr()
			elseif cC == bc then
				sum = sum + 1
				matcher:nextStr()
			else
				if sum == 0 or cC == -1 then
					sum = 0
					matcher:reset()
				else
					matcher:nextStr()
				end
			end
		end, skip
	end

	matcher.functions[1] = function(cC)
		matcher:fullResetOnNextStr()
		matcher.seqStart = matcher.str
		matcher:nextFunc()
		if (matcher.str > matcher.startStr and matcher.fromStart) or matcher.str >= matcher.stringLen then
			matcher.stop = true
			matcher.seqStart = nil
		end
	end

	local lastFunc
	local ignore = false
	local skip = nil
	local it = (function()
		local gen = utf8gensub(regex)
		return function()
			return gen(skip)
		end
	end)()
	local cs = {}
	for c, bs, be in it do
		skip = nil
		if plain then
			table.insert(matcher.functions, simple(classMatchGenerator(c, plain)))
		else
			if ignore then
				if find('123456789', c, 1, true) then
					if lastFunc then
						table.insert(matcher.functions, simple(lastFunc))
						lastFunc = nil
					end
					table.insert(matcher.functions, capture(tonumber(c)))
				elseif c == 'b' then
					if lastFunc then
						table.insert(matcher.functions, simple(lastFunc))
						lastFunc = nil
					end
					local b
					b, skip = balancer(sub(regex, be + 1, be + 9))
					table.insert(matcher.functions, b)
				else
					lastFunc = classMatchGenerator('%' .. c)
				end
				ignore = false
			else
				if c == '*' then
					if lastFunc then
						table.insert(matcher.functions, star(lastFunc))
						lastFunc = nil
					else
						error('invalid regex after ' .. sub(regex, 1, bs))
					end
				elseif c == '+' then
					if lastFunc then
						table.insert(matcher.functions, simple(lastFunc))
						table.insert(matcher.functions, star(lastFunc))
						lastFunc = nil
					else
						error('invalid regex after ' .. sub(regex, 1, bs))
					end
				elseif c == '-' then
					if lastFunc then
						table.insert(matcher.functions, minus(lastFunc))
						lastFunc = nil
					else
						error('invalid regex after ' .. sub(regex, 1, bs))
					end
				elseif c == '?' then
					if lastFunc then
						table.insert(matcher.functions, question(lastFunc))
						lastFunc = nil
					else
						error('invalid regex after ' .. sub(regex, 1, bs))
					end
				elseif c == '^' then
					if bs == 1 then
						matcher.fromStart = true
					else
						error('invalid regex after ' .. sub(regex, 1, bs))
					end
				elseif c == '$' then
					if be == len(regex) then
						matcher.toEnd = true
					else
						error('invalid regex after ' .. sub(regex, 1, bs))
					end
				elseif c == '[' then
					if lastFunc then
						table.insert(matcher.functions, simple(lastFunc))
					end
					lastFunc, skip = classMatchGenerator(sub(regex, be + 1))
				elseif c == '(' then
					if lastFunc then
						table.insert(matcher.functions, simple(lastFunc))
						lastFunc = nil
					end
					table.insert(matcher.captures, {})
					table.insert(cs, #matcher.captures)
					table.insert(matcher.functions, captureStart(cs[#cs]))
					if sub(regex, be + 1, be + 1) == ')' then matcher.captures[#matcher.captures].empty = true end
				elseif c == ')' then
					if lastFunc then
						table.insert(matcher.functions, simple(lastFunc))
						lastFunc = nil
					end
					local cap = table.remove(cs)
					if not cap then
						error('invalid capture: "(" missing')
					end
					table.insert(matcher.functions, captureStop(cap))
				elseif c == '.' then
					if lastFunc then
						table.insert(matcher.functions, simple(lastFunc))
					end
					lastFunc = function(cC) return cC ~= -1 end
				elseif c == '%' then
					ignore = true
				else
					if lastFunc then
						table.insert(matcher.functions, simple(lastFunc))
					end
					lastFunc = classMatchGenerator(c)
				end
			end
		end
	end
	if #cs > 0 then
		error('invalid capture: ")" missing')
	end
	if lastFunc then
		table.insert(matcher.functions, simple(lastFunc))
	end
	lastFunc = nil
	ignore = nil

	table.insert(matcher.functions, function()
		if matcher.toEnd and matcher.str ~= matcher.stringLen then
			matcher:reset()
		else
			matcher.stop = true
		end
	end)

	matcher.nextFunc = function(self)
		self.func = self.func + 1
	end
	matcher.nextStr = function(self)
		self.str = self.str + 1
	end
	matcher.strReset = function(self)
		local oldReset = self.reset
		local str = self.str
		self.reset = function(s)
			s.str = str
			s.reset = oldReset
		end
	end
	matcher.fullResetOnNextFunc = function(self)
		local oldReset = self.reset
		local func = self.func +1
		local str = self.str
		self.reset = function(s)
			s.func = func
			s.str = str
			s.reset = oldReset
		end
	end
	matcher.fullResetOnNextStr = function(self)
		local oldReset = self.reset
		local str = self.str + 1
		local func = self.func
		self.reset = function(s)
			s.func = func
			s.str = str
			s.reset = oldReset
		end
	end

	matcher.process = function(self, str, start)

		self.func = 1
		start = start or 1
		self.startStr = (start >= 0) and start or utf8len(str) + start + 1
		self.seqStart = self.startStr
		self.str = self.startStr
		self.stringLen = utf8len(str) + 1
		self.string = str
		self.stop = false

		self.reset = function(s)
			s.func = 1
		end

		local chr
		while not self.stop do
			if self.str < self.stringLen then
				chr = utf8sub(str, self.str,self.str)
				self.functions[self.func](utf8unicode(chr))
			else
				self.functions[self.func](-1)
			end
		end

		if self.seqStart then
			local captures = {}
			for _,pair in pairs(self.captures) do
				if pair.empty then
					table.insert(captures, pair[1])
				else
					table.insert(captures, utf8sub(str, pair[1], pair[2]))
				end
			end
			return self.seqStart, self.str - 1, unpack(captures)
		end
	end

	return matcher
end

-- string.find
local function utf8find(str, regex, init, plain)
	local matcher = cache[regex] or matcherGenerator(regex, plain)
	return matcher:process(str, init)
end

-- string.match
local function utf8match(str, regex, init)
	init = init or 1
	local found = {utf8find(str, regex, init)}
	if found[1] then
		if found[3] then
			return unpack(found, 3)
		end
		return utf8sub(str, found[1], found[2])
	end
end

-- string.gmatch
local function utf8gmatch(str, regex, all)
	regex = (utf8sub(regex,1,1) ~= '^') and regex or '%' .. regex
	local lastChar = 1
	return function()
		local found = {utf8find(str, regex, lastChar)}
		if found[1] then
			lastChar = found[2] + 1
			if found[all and 1 or 3] then
				return unpack(found, all and 1 or 3)
			end
			return utf8sub(str, found[1], found[2])
		end
	end
end

local function replace(repl, args)
	local ret = ''
	if type(repl) == 'string' then
		local ignore = false
		local num = 0
		for c in utf8gensub(repl) do
			if not ignore then
				if c == '%' then
					ignore = true
				else
					ret = ret .. c
				end
			else
				num = tonumber(c)
				if num then
					ret = ret .. args[num]
				else
					ret = ret .. c
				end
				ignore = false
			end
		end
	elseif type(repl) == 'table' then
		ret = repl[args[1] or args[0]] or ''
	elseif type(repl) == 'function' then
		if #args > 0 then
			ret = repl(unpack(args, 1)) or ''
		else
			ret = repl(args[0]) or ''
		end
	end
	return ret
end

-- string.gsub
local function utf8gsub(str, regex, repl, limit)
	limit = limit or -1
	local ret = ''
	local prevEnd = 1
	local it = utf8gmatch(str, regex, true)
	local found = {it()}
	local n = 0
	while #found > 0 and limit ~= n do
		local args = {[0] = utf8sub(str, found[1], found[2]), unpack(found, 3)}
		ret = ret .. utf8sub(str, prevEnd, found[1] - 1)
		.. replace(repl, args)
		prevEnd = found[2] + 1
		n = n + 1
		found = {it()}
	end
	return ret .. utf8sub(str, prevEnd), n
end

local function utf8codes (s)
	local byte_pos = 1
	local ln      = #s
	return function(skip)
		if skip then byte_pos = byte_pos + skip end
		local start      = byte_pos

		if byte_pos > ln then return end
		local bytes = utf8charbytes(s,byte_pos)
		byte_pos    = byte_pos+bytes

		local last  = byte_pos-1
		local sb   = sub(s,start,last)
		return start, utf8unicode(sb)
	end
end

local function utf8string( ... )
	local str = StringBuffer:Create();

	for k,v in ipairs({ ... })
	do
		local tp = type(v);
		if tp ~= "number" then
			error("bad argument #".. k .." to 'utf8string' (number expected, got ".. tp ..")")
		end

		str = str .. utf8char( v );
	end

	return str:ToString();
end


System.UTF8.byte    = utf8unicode
System.UTF8.char    = utf8string --utf8char
System.UTF8.dump    = dump
System.UTF8.find    = utf8find
System.UTF8.format  = format
System.UTF8.gmatch  = utf8gmatch
System.UTF8.gsub    = utf8gsub
System.UTF8.len     = utf8len
System.UTF8.lower   = lower
System.UTF8.match   = utf8match
System.UTF8.rep     = rep
System.UTF8.reverse = utf8reverse
System.UTF8.sub     = utf8sub
System.UTF8.upper   = upper
System.UTF8.codes	= utf8codes
System.UTF8.unicode = utf8unicode
System.UTF8.gensub  = utf8gensub
end

--- `string.byte` equivalent for UTF-8 strings.
--
-- @function byte
-- @tparam string s
-- @tparam[opt=1] number i
-- @tparam[opt=i] number j
-- @treturn ... Char codes in lua number.

--- `string.char` equivalent for UTF-8 strings.
--
-- @function char
-- @param ... UTF-8 code integers.
-- @treturn string

--- `string.find` equivalent for UTF-8 strings.
--
-- @function find
-- @tparam string s
-- @tparam string pattern
-- @tparam[opt] number init
-- @tparam[opt] boolean plain
-- @return find result.

--- `string.gmatch` equivalent for UTF-8 strings.
--
-- @function gmatch
-- @tparam string s
-- @tparam string pattern
-- @tparam[opt] boolean all
-- @treturn function

--- `string.gsub` equivalent for UTF-8 strings.
--
-- @function gsub
-- @tparam string s
-- @tparam string pattern
-- @tparam string|table|function repl
-- @tparam[opt] number n
-- @treturn string

--- `string.len` equivalent for UTF-8 strings.
--
-- @function len
-- @tparam string s
-- @treturn number

--- `string.match` equivalent for UTF-8 strings.
--
-- @function match
-- @tparam string s
-- @tparam string pattern
-- @tparam[opt] number init
-- @return match result.

--- `string.sub` equivalent for UTF-8 strings.
--
-- @function sub
-- @tparam string s
-- @tparam number i
-- @tparam[opt] number j
-- @treturn string

--- `string.reverse` equivalent for UTF-8 strings.
--
-- @function reverse
-- @tparam string s
-- @treturn string

--- Returns an iterator which iterate over all characters in string s,
-- with p being the position (in bytes) and c the code point of each character.
--
-- @function codes
-- @tparam string s
-- @treturn function Returns variable (p, c).

--- Returns an iterator which returns the next substring and its byte interval.
--
-- @function gensub
-- @tparam string s
-- @tparam[opt=1] number len The string length of each substrings.
-- @treturn function Returns variable (substring, startPos, endPos).

--- `string.explode` equivalent for UTF-8 strings.
--
-- @string source The string to explode.
-- @string delimiter The string delimiter.
-- @treturn table The result.
function System.UTF8.explode (source , delimiter)
    local t, l, ll
    t={}
    ll=0
    if(#source == 1) then
        return {source}
    end
    while true do
        l = System.UTF8.find(source, delimiter, ll, true) -- find the next d in the string
        if l ~= nil then -- if "not not" found then..
            table.insert(t, System.UTF8.sub(source,ll,l-1)) -- Save it in our array.
            ll = l + 1 -- save just after where we found it for searching next time.
        else
            table.insert(t, System.UTF8.sub(source,ll)) -- Save what's left in our array.
            break -- Break at end, as it should be, according to the lua manual.
        end
    end
    return t
end


--- Metamethods
-- @section metamethod


--- Event Callbacks
-- @section callback

--- @section end


------------
-- Donxon Common module.
--
-- This module contains the functionality for scripts running on both the client and server.
--
-- It can be used in script files registered in both "game" and "ui" array of `project.json`.
--
-- @module Common


--[[=========================================================
--  [COMMON] Pre-loading.
=========================================================--]]

--- Stores original `Common` table for later usages.
--
-- @local
-- @tfield Common baseCommon
local baseCommon = Common;

--- Common module.
--
-- @local
-- @tfield Common Common
local Common = {};

--- Maximum supported player slots.
--
-- @tfield[opt=24] number maxPlayer
Common.maxPlayer = 24;

--- Zero vector (0, 0, 0).
--
-- @tfield[opt="x = 0 y = 0 z = 0"] Common.Vector vecZero

--- Empty function.
--
-- An empty function used for internal stuffs.
--
-- @tfield function emptyFunc
Common.emptyFunc = g_emptyFunc;


Common.SIGNAL = {};


--- Available colors.
--
-- @table Common.COLOR
Common.COLOR = {
    YELLOWISH   = nil,
    REDISH      = nil,
    GREENISH    = nil,
};


--- Classes
-- @section classes


--- Color class.
--
-- Shared functions and properties for color manipulations.
--
-- @tfield Common.Color Color


--- 2D Vector class.
--
-- Used for many pathfinding and many other operations
-- that are treated as planar rather than 3d.
--
-- @tfield Common.Vector2D Vector2D


--- 3D Vector class.
--
-- @tfield Common.Vector Vector


--- Network Message Builder class.
--
-- Used to builds network messages
-- that will be sent from server
-- to client(s).
--
-- @tfield Common.NetMessage NetMessage


--- Common Text Menu class.
--
-- Shared functions and properties for text menu classes.
--
-- @tfield Common.TextMenu TextMenu


--- Common ScreenFade class.
--
-- Shared functions and properties for screen fade classes.
--
-- @tfield Common.ScreenFade ScreenFade

--- @section end


------------
-- Color class.
--
-- Shared functions and properties for color manipulations.
--
-- @classmod Common.Color
Common.Color = {};


--- The color table.
--
-- @struct .color
-- @tfield int r Red color composition (Range = 0~255).
-- @tfield int g Green color composition (Range = 0~255).
-- @tfield int b Blue color composition (Range = 0~255).
-- @tfield[opt=nil] int a Alpha/opaque/transparency (Range = 0~255).


--- Methods
-- @section method

--- Converts hexadecimal to color table.
--
-- @tparam ?number|string val The hexadecimal value.
-- @treturn .color The color table.
function Common.Color.FromHex( val )
    if type( val ) == "string" then
        -- Removes specific headers.
        -- val = string.gsub( val, "0x", "" );
        val = string.gsub( val, "#", "" );
    end

    val = tonumber( val );
    return {
        r = (val & 0xFF0000) >> 16,
        g = (val & 0xFF00) >> 8,
        b = val & 0xFF,
    };
end


--- Converts color to hexadecimal string.
--
-- @tparam ?int|.color r Red color composition. | A color-compatible table.
-- @tparam[opt] int g Green color composition (Ignored if `r` is table).
-- @tparam[opt] int b Blue color composition (Ignored if `r` is table).
-- @treturn string A hexadecimal string.
function Common.Color.ToHex( r, g, b )
    if type( r ) == "table" then
        r,g,b = r.r, r.b, r.g;
    end

    if math.type( r ) == nil then r = 0; end
    if math.type( g ) == nil then g = 0; end
    if math.type( b ) == nil then b = 0; end

    r = math.clamp( 0, 255, r );
    g = math.clamp( 0, 255, g );
    b = math.clamp( 0, 255, b );

    return string.format( "0x%02X%02X%02X%02X", r,g,b,0 );
end


--- Metamethods
-- @section metamethod


--- Event Callbacks
-- @section callback

--- @section end


------------
-- 2D Vector class.
--
-- Used for many pathfinding and many other operations
-- that are treated as planar rather than 3d.
--
-- @classmod Common.Vector2D
Common.Vector2D = {};
local baseVector2D = Common.Vector2D;

--- Vector x variable.
-- @tfield[opt=0] number x

--- Vector y variable.
-- @tfield[opt=0] number y


--- Methods
-- @section method

--- Checks whether the table is compatible with 2D vector class.
--
-- @local
-- @tparam table v The table to check.
-- @bool[opt=false] checkMembers Asserts members data type.
-- @bool[opt=true] setDefault Set invalid members with default value (Ignored if `checkMembers` is true).
-- @treturn bool Return true if table is compatible.
function Common.Vector2D:AssertTable ( v , checkMembers , setDefault )
    AssertType( "v", "table", v, nil, nil, 3 );
    setDefault = (setDefault == nil) and true or setDefault;
    if checkMembers then
        AssertType( "x", "number", v.x, "property", math.type( v.x ), 3 );
        AssertType( "y", "number", v.y, "property", math.type( v.y ), 3 );
    elseif setDefault then
        if not math.type( v.x ) then v.x = 0; end
        if not math.type( v.y ) then v.y = 0; end
    end

    return true;
end


--- Checks whether the value is number type.
--
-- @local
-- @number fl The value to check.
-- @treturn bool Return true if value is number type.
function Common.Vector2D:AssertNumber ( fl )
    AssertType( "fl", "number", fl, nil, math.type( fl ), 3 );

    return true;
end


--- Constructs a 2D vector.
--
-- @tparam ?number|table X The value of X. | The vector-compatible table.
-- @number[opt] Y The value of Y (Ignored if `X` is table).
-- @treturn Common.Vector2D The new vector.
-- @usage
-- -- You can do this.
-- vec = Common.Vector2D:Create( 1 , 2 )
-- -- or do this.
-- vec = Common.Vector2D:Create( { x = 1 , y = 2 } )
-- -- or do this.
-- vec = Common.Vector2D:Create( "1 2" )
function Common.Vector2D:Create ( X , Y )
    -- Class properties.
    local o =
    {
        x = 0
        , y = 0
    };

    if math.type( X )
    then
        AssertType( "Y", "number", Y, nil, math.type( Y ), 2 );

        o.x = X;
        o.y = Y;

    elseif type( X ) == "string"
    then
        return self:FromString ( X );

    else
        o = X or o;
        self:AssertTable( o );
    end

    setmetatable( o, baseVector2D );

    -- Checks again.
    self:AssertTable( o , true );

    return o;
end


--- Constructs a 2D vector from a string.
-- Format should be:  x y
--
-- @string stringVector The string vector.
-- @treturn Common.Vector2D The new vector.
function Common.Vector2D:FromString ( stringVector )
    local vec = string.explode( stringVector, ' ' );
    return self:Create( tonumber(vec[1]), tonumber(vec[2]) );
end


--- Returns a clone of this vector.
--
-- @treturn Common.Vector2D The new vector.
function Common.Vector2D:Clone ()
    return self:Create{ x = self.x , y = self.y };
end


--- Gets the length of this vector.
--
-- @treturn number The length.
function Common.Vector2D:Length ()
    local x, y = self.x, self.y;
    return math.sqrt(x*x + y*y);
end


--- Returns the normalized form of this vector.
--
-- @treturn Common.Vector2D The normalized vector.
function Common.Vector2D:Normalize ()
    local flLen = self:Length();

    if ( flLen == 0 )
    then
        return self:Create{ x = 0 , y = 0 };
    else
        flLen = 1 / flLen;
        return self:Create{ x = self.x * flLen , y = self.y * flLen };
    end
end


--- Returns the 3D form of this vector.
--
-- @treturn Common.Vector The new 3D vector.
function Common.Vector2D:Make3D ()
    return Common.Vector:Create( self:Clone() );
end


--- Returns a string representation of this vector.
--
-- @treturn string The string of integers.
function Common.Vector2D:ToString ()
    return string.format( "%.0f %.0f" , self.x , self.y );
end


--- Returns a dot product from 2 vectors.
--
-- @tparam Common.Vector2D v The other vector.
-- @treturn number The dot product.
function Common.Vector2D:DotProduct ( v )
    self:AssertTable( v , true );

    return self.x * v.x + self.y * v.y;
end


--- Metamethods
-- @section metamethod

--- Base class.
-- @tfield Common.Vector2D __index
Common.Vector2D.__index = Common.Vector2D;


--- Returns a string representation of this vector.
-- @tfield Common.Vector2D.ToString __tostring
Common.Vector2D.__tostring = Common.Vector2D.ToString;


--- Returns a negated form of this vector.
--
-- @treturn Common.Vector2D The new vector.
-- @usage
-- local vec = Common.Vector2D:Create( 1 , 2 );
-- vec = -vec;
-- print( vec:ToString() ); -- prints "-1 -2".
function Common.Vector2D:__unm ()
    return self:Create{ x = -self.x , y = -self.y };
end


--- Compares this vector.
--
-- @tparam Common.Vector2D v The other vector.
-- @treturn bool Returns true if equals.
-- @usage
-- local vec = Common.Vector2D:Create();
-- print( vec == Common.vecZero ); -- prints "true".
function Common.Vector2D:__eq ( v )
    self:AssertTable( v , true );

    return self.x == v.x and self.y == v.y;
end


--- Returns a vector from addition of 2 vectors.
--
-- @tparam Common.Vector2D v The other vector.
-- @treturn Common.Vector2D The new vector.
-- @usage
-- local vec = Common.Vector2D:Create( 2 , 3 );
-- vec = vec + {x = 2 , y = 1};
-- print( vec:ToString() ); -- prints "4 4".
function Common.Vector2D:__add ( v )
    self:AssertTable( v );

    local result = self:Clone();
    result.x = result.x + v.x;
    result.y = result.y + v.y;

    return result;
end


--- Returns a vector from subtraction of 2 vectors.
--
-- @tparam Common.Vector2D v The other vector.
-- @treturn Common.Vector2D The new vector.
-- @usage
-- local vec = Common.Vector2D:Create( 2 , 3 );
-- vec = vec - {x = 2 , y = 1};
-- print( vec:ToString() ); -- prints "0 2".
function Common.Vector2D:__sub ( v )
    self:AssertTable( v );

    local result = self:Clone();
    result.x = result.x - v.x;
    result.y = result.y - v.y;

    return result;
end


--- Multiplies this vector with a number value.
--
-- @number fl The modifier.
-- @treturn Common.Vector2D The new vector.
-- @usage
-- local vec = Common.Vector2D:Create( 2 , 3 );
-- vec = vec * 2;
-- print( vec:ToString() ); -- prints "4 6".
function Common.Vector2D:__mul ( fl )
    self:AssertNumber( fl );

    local result = self:Clone();
    result.x = result.x * fl;
    result.y = result.y * fl;

    return result;
end


--- Divides this vector with a number value.
--
-- @number fl The modifier.
-- @treturn Common.Vector2D The new vector.
-- @usage
-- local vec = Common.Vector2D:Create( 4 , 6 );
-- vec = vec / 2;
-- print( vec:ToString() ); -- prints "2 3".
function Common.Vector2D:__div ( fl )
    self:AssertNumber( fl );

    local result = self:Clone();
    result.x = result.x / fl;
    result.y = result.y / fl;

    return result;
end


--- Event Callbacks
-- @section callback

--- @section end


------------
-- 3D Vector class.
--
-- @classmod Common.Vector
Common.Vector = {};
local baseVector3D = Common.Vector;

--- Vector x variable.
-- @tfield[opt=0] number x

--- Vector y variable.
-- @tfield[opt=0] number y

--- Vector z variable.
-- @tfield[opt=0] number z


--- Methods
-- @section method

--- Checks whether the table is compatible with 3D vector class.
--
-- @local
-- @tparam table v The table to check.
-- @bool[opt=false] checkMembers Asserts members data type.
-- @bool[opt=true] setDefault Set invalid members with default value (Ignored if `checkMembers` is true).
-- @treturn bool Return true if table is compatible.
function Common.Vector:AssertTable ( v , checkMembers , setDefault )
    AssertType( "v", "table", v, nil, nil, 3 );
    setDefault = (setDefault == nil) and true or setDefault;
    if checkMembers then
        AssertType( "x", "number", v.x, "property", math.type( v.x ), 3 );
        AssertType( "y", "number", v.y, "property", math.type( v.y ), 3 );
        AssertType( "z", "number", v.z, "property", math.type( v.z ), 3 );
    elseif setDefault then
        if not math.type( v.x ) then v.x = 0; end
        if not math.type( v.y ) then v.y = 0; end
        if not math.type( v.z ) then v.z = 0; end
    end

    return true;
end


--- Checks whether the value is number type.
--
-- @local
-- @number fl The value to check.
-- @treturn bool Return true if value is number type.
function Common.Vector:AssertNumber ( fl )
    AssertType( "fl", "number", fl, nil, math.type( fl ), 3 );

    return true;
end


--- Constructs a 3D vector.
--
-- @tparam ?number|table X The value of X. | The vector-compatible table.
-- @number[opt] Y The value of Y (Ignored if `X` is table).
-- @number[opt] Z The value of Z (Ignored if `X` is table).
-- @treturn Common.Vector The new vector.
-- @usage
-- -- You can do this.
-- vec = Common.Vector:Create( 1 , 2 , 3 )
-- -- or do this.
-- vec = Common.Vector:Create( { x = 1 , y = 2 , z = 3 } )
-- -- or do this.
-- vec = Common.Vector:Create( "1 2 3" )
function Common.Vector:Create ( X , Y , Z )
    -- Class properties.
    local o =
    {
        x = 0
        , y = 0
        , z = 0
    };

    if math.type( X )
    then
        AssertType( "Y", "number", Y, nil, math.type( Y ), 2 );
        AssertType( "Z", "number", Z, nil, math.type( Z ), 2 );

        o.x = X;
        o.y = Y;
        o.z = Z;

    elseif type( X ) == "string"
    then
        return self:FromString ( X );

    else
        o = X;
        self:AssertTable( o );
    end

    setmetatable( o, baseVector3D );

    -- Checks again.
    self:AssertTable( o , true );

    return o;
end


--- Constructs a 3D vector from a string.
-- Format should be:  x y z
--
-- @string stringVector The string vector.
-- @treturn Common.Vector The new vector.
function Common.Vector:FromString ( stringVector )
    local vec = string.explode( stringVector, ' ' );
    return self:Create( tonumber(vec[1]), tonumber(vec[2]), tonumber(vec[3]) );
end


--- Returns a clone of this vector.
--
-- @treturn Common.Vector The new vector.
function Common.Vector:Clone ()
    return self:Create{ x = self.x , y = self.y , z = self.z };
end


--- Gets the length of this vector.
--
-- @treturn number The length.
function Common.Vector:Length ()
    local x, y, z = self.x, self.y, self.z;
    return math.sqrt(x*x + y*y + z*z);
end


--- Returns the normalized form of this vector.
--
-- @treturn Common.Vector The normalized vector.
function Common.Vector:Normalize ()
    local flLen = self:Length();
    if ( flLen == 0 ) then return self:Create{ x = 0 , y = 0 , z = 1 }; end -- ????
    flLen = 1 / flLen;
    return self:Create{ x = self.x * flLen , y = self.y * flLen , z = self.z * flLen };
end


--- Returns the 2D form of this vector.
--
-- @treturn Common.Vector2D The new 2D vector.
function Common.Vector:Make2D ()
    return Common.Vector2D:Create( self:Clone() );
end


--- Gets the length of this vector in 2D.
--
-- @treturn number The length.
function Common.Vector:Length2D ()
    return self:Make2D():Length();
end


--- Returns a string representation of this vector.
--
-- @treturn string The string of integers.
function Common.Vector:ToString ()
    return string.format( "%.0f %.0f %.0f" , self.x , self.y , self.z );
end


--- Returns a dot product from 2 vectors.
--
-- @tparam Common.Vector v The other vector.
-- @treturn Common.Vector The dot product.
function Common.Vector:DotProduct ( v )
    self:AssertTable( v , true );

    return self.x * v.x + self.y * v.y + self.z * v.z;
end


--- Returns a cross product from 2 vectors.
--
-- @tparam Common.Vector v The other vector.
-- @treturn number The cross product.
function Common.Vector:CrossProduct ( v )
    self:AssertTable( v , true );

    return self:Create( self.y*v.z - self.z*v.y, self.z*v.x - self.x*v.z, self.x*v.y - self.y*v.x );
end


--- Metamethods
-- @section metamethod

--- Base class.
-- @tfield Common.Vector __index
Common.Vector.__index = Common.Vector;


--- Returns a string representation of this vector.
-- @tfield Common.Vector.ToString __tostring
Common.Vector.__tostring = Common.Vector.ToString;


--- Returns a negated form of this vector.
--
-- @treturn Common.Vector The new vector.
-- @usage
-- local vec = Common.Vector:Create( 1 , 2 , 3 );
-- vec = -vec;
-- print( vec:ToString() ); -- prints "-1 -2 -3".
function Common.Vector:__unm ()
    return self:Create{ x = -self.x , y = -self.y , z = -self.z };
end


--- Compares this vector.
--
-- @tparam Common.Vector v The other vector.
-- @treturn bool Returns true if equals.
-- @usage
-- local vec = Common.Vector:Create();
-- print( vec == Common.vecZero ); -- prints "true".
function Common.Vector:__eq ( v )
    self:AssertTable( v , true );

    return self.x == v.x and self.y == v.y and self.z == v.z;
end


--- Returns a vector from addition of 2 vectors.
--
-- @tparam Common.Vector v The other vector.
-- @treturn Common.Vector The new vector.
-- @usage
-- local vec = Common.Vector:Create( 2 , 3 , 4 );
-- vec = vec + {x = 2 , y = 1 , z = 0};
-- print( vec:ToString() ); -- prints "4 4 4".
function Common.Vector:__add ( v )
    self:AssertTable( v );

    local result = self:Clone();
    result.x = result.x + v.x;
    result.y = result.y + v.y;
    result.z = result.z + v.z;

    return result;
end


--- Returns a vector from subtraction of 2 vectors.
--
-- @tparam Common.Vector v The other vector.
-- @treturn Common.Vector The new vector.
-- @usage
-- local vec = Common.Vector:Create( 2 , 3 , 4 );
-- vec = vec - {x = 2 , y = 1 , z = 3};
-- print( vec:ToString() ); -- prints "0 2 1".
function Common.Vector:__sub ( v )
    self:AssertTable( v );

    local result = self:Clone();
    result.x = result.x - v.x;
    result.y = result.y - v.y;
    result.z = result.z - v.z;

    return result;
end


--- Multiplies this vector with a number value.
--
-- @number fl The modifier.
-- @treturn Common.Vector The new vector.
-- @usage
-- local vec = Common.Vector:Create( 2 , 3 , 4 );
-- vec = vec * 2;
-- print( vec:ToString() ); -- prints "4 6 8".
function Common.Vector:__mul ( fl )
    self:AssertNumber( fl );

    local result = self:Clone();
    result.x = result.x * fl;
    result.y = result.y * fl;
    result.z = result.z * fl;

    return result;
end


--- Divides this vector with a number value.
--
-- @number fl The modifier.
-- @treturn Common.Vector The new vector.
-- @usage
-- local vec = Common.Vector:Create( 4 , 6 , 8 );
-- vec = vec / 2;
-- print( vec:ToString() ); -- prints "2 3 4".
function Common.Vector:__div ( fl )
    self:AssertNumber( fl );

    local result = self:Clone();
    result.x = result.x / fl;
    result.y = result.y / fl;
    result.z = result.z / fl;

    return result;
end


--- Event Callbacks
-- @section callback

--- @section end


------------
-- Network Message Builder class.
--
-- Used to builds network messages
-- that will be sent from server
-- to client(s).
--
-- @classmod Common.NetMessage
Common.NetMessage = {};
local baseNetMessage = Common.NetMessage;

--- Name of this network message.
-- @tfield string name

--- The syncvalue of this network message.
-- @local
-- @tfield ?Game.SyncValue|UI.SyncValue syncvalue

--- Group separator.
-- @local
-- @tfield string GRPSEP
Common.NetMessage.GRPSEP = string.char(30);

--- Argument separator.
-- @local
-- @tfield string ARGSEP
Common.NetMessage.ARGSEP = string.char(31);


--- The net message argument properties.
--
-- @struct .netMessageArgumentProperty
-- @tfield anything value The argument value.
-- @tfield string format The argument format/datatype.


--- Network message destination types.
--
-- @see Game.NetMessage:Begin
Common.NetMessage.MSG = {
    BROADCAST       =   0,  -- **Same as ALL** unreliable to all.
    ONE             =   1,  -- reliable to one (msg_entity).
    ALL             =   2,  -- reliable to all.
    INIT            =   3,  -- **Unsupported** write to the init string.
    PVS             =   4,  -- **Unsupported** Ents in PVS of org.
    PAS             =   5,  -- **Unsupported** Ents in PAS of org.
    PVS_R           =   6,  -- **Unsupported** Reliable to PVS.
    PAS_R           =   7,  -- **Unsupported** Reliable to PAS.
    ONE_UNRELIABLE  =   8,  -- **Same as ONE** Send to one client, got don't put in reliable stream, put in unreliable datagram ( could be dropped ).
    SPEC            =   9,  -- **Unsupported** Sends to all spectator proxies.
}; Common.NetMessage.MSG = table.readonly( Common.NetMessage.MSG );


--- Network message types.
--
-- @see Common.NetMessage:Register
-- @see Game.NetMessage:Begin
Common.NetMessage.TYPE = {
    SHOWMENU        =   nil,  -- This message displays a "menu" to a player (text on the left side of the screen).
    SCREENFADE      =   nil,  -- This message fades the screen.
    BARTIME         =   nil,  -- This message draws a HUD progress bar which is filled from 0% to 100% for the time Duration seconds. Once the bar is fully filled it will be removed from the screen automatically.
    BARTIME2        =   nil,  -- The message is the same as BarTime, but StartPercent specifies how much of the bar is (already) filled.
    TE_TEXTMESSAGE  =   nil,  -- This message draws a HUD text message.
};


--- Argument formats.
Common.NetMessage.ARGFORMAT = {
    BYTE    = "byte", -- Unsigned char
    CHAR    = "char", -- Signed char.
    SHORT   = "short", -- Signed short.
    LONG    = "long", -- Signed long.
    ANGLE   = "angle", -- Float in signed char form.
    FLOAT   = "float", -- Float.
    VECTOR  = "vector", -- Vector string.
    STRING  = "string", -- String.
    NUMBER  = "number", -- Lua number.
}; Common.NetMessage.ARGFORMAT = table.readonly( Common.NetMessage.ARGFORMAT );

--- Methods
-- @section method

--- Checks whether the table is compatible with network message class.
--
-- @local
-- @tparam table v The table to check.
-- @bool[opt=true] checkMembers Asserts members data type.
-- @treturn bool Return true if table is compatible.
function Common.NetMessage:AssertTable ( v , checkMembers )
    AssertType( "v", "table", v, nil, nil, 3 );
    checkMembers = (checkMembers == nil) and true or checkMembers;
    if checkMembers then
        AssertType( "name", "string", v.name, "property", nil, 3 );
        AssertType( "syncvalue", "table|userdata", v.syncvalue, "property", type(v.syncvalue) == "table" or type(v.syncvalue) == "userdata", 3 );
    end

    return true;
end


--- Constructs a network message.
--
-- **Note:** This will not register the network message.
--
-- @see Common.NetMessage:Register
-- @string name The name of this network message.
-- @treturn Common.NetMessage The new network message.
-- @usage
-- local myMsg = Common.NetMessage:Create( "MyNetMessage" );
function Common.NetMessage:Create ( name )
    -- Class properties.
    local o =
    {
        name = name
        , syncvalue = nil
    };

    setmetatable( o, baseNetMessage );

    -- Creates the communication bridge.
    local varName = string.format( "NetMsg %s" , name );
    if IsGameModule()
    then
        o.syncvalue = {};
        for i = 1, Common.maxPlayer do
            o.syncvalue[i] = Game.SyncValue.Create( varName ..i );
            o.syncvalue[i].value = nil;
        end
    elseif IsUIModule()
    then
        local i = UI.PlayerIndex();
        o.syncvalue = UI.SyncValue.Create( varName ..i );
        o.syncvalue.OnSync = function (var)
            local value = var.value;
            if type(value) ~= "string" then return; end
            local groups = string.explode( value, Common.NetMessage.GRPSEP );

            local ent = tonumber( groups[1] );
            if ent == nil then
                Debug.print( "[NM]", "(OR)", "Broken ent index." );
                return;
            end

            -- Skips when this message is not for me.
            if ent ~= 0 and ent ~= UI.PlayerIndex() then
                return;
            end

            Debug.print( "[NM]", "(OR)", o.name );
            local args, formats = string.explode( groups[3] , Common.NetMessage.ARGSEP ), string.explode( groups[2] , Common.NetMessage.ARGSEP );
            for i = 1, #args do
                args[i] = { value = self:ToFormatType( formats[i], args[i] ), format = formats[i] };
            end
            o:OnReceived( args );
        end
    else
        error( "No system module is loaded.", 2 )
    end

    -- Checks again.
    self:AssertTable( o );

    -- Multiple hooks.
    o = Hook:Create( table.extend( o, {} ) );

    Debug.print( "[NM]", "(C)", name );
    return o;
end


--- Checks whether the network message is registered.
--
-- @string[opt] name The network message name.
-- @treturn bool Returns true if already registered.
function Common.NetMessage:IsRegistered (name)
    name = name or self.name;
    return Common.NetMessage.TYPE[ string.upper(name) ] ~= nil;
end


--- Registers the network message into `Common.NetMessage.TYPE` table.
--
-- The table index will be formatted as upper-case string.
--
-- @see Common.NetMessage:Create
-- @param[opt] ... Arguments will be passed to constructs a new network message.
-- @treturn Common.NetMessage This network message.
-- @usage
-- local myMsg = Common.NetMessage:Register( "MyNetMessage" );
-- print( Common.NetMessage.TYPE.MYNETMESSAGE:ToString() ); -- print "MyNetMessage".
-- print( myMsg:ToString() ); -- also print "MyNetMessage".
function Common.NetMessage:Register ( ... )
    local arg = {...};
    if #arg > 0 then
        self = self:Create( ... );
    end
    assert( not self:IsRegistered() , "Duplicate netmsg name." );

    local id = string.upper(self.name);
    Common.NetMessage.TYPE[ id ] = self;
    Debug.print( "[NM]", "(R)", id );
    return Common.NetMessage.TYPE[ id ];
end


--- Unregisters the network message from `Common.NetMessage.TYPE` table.
--
-- @string[opt] name The network message name.
-- @treturn Common.NetMessage This network message.
-- @usage
-- -- you can do this,
-- myMsg:Unregister();
-- -- or you can do this,
-- Common.NetMessage:Unregister( "MyNetMessage" );
-- -- but not doing both!
function Common.NetMessage:Unregister (name)
    name = name or self.name;
    assert( self:IsRegistered(name) , "Netmsg is not registered." );

    local id = string.upper(name);
    Common.NetMessage.TYPE[ id ] = nil;
    Debug.print( "[NM]", "(U)", id );
    return self;
end


--- Returns the name of this network message.
--
-- @treturn string The name of this network message.
function Common.NetMessage:ToString ()
    return tostring( self.name );
end


--- Converts a value into a proper data type value.
--
-- @see Game.NetMessage:WriteAngle
-- @tparam Common.NetMessage.ARGFORMAT FormatType The format data type.
-- @tparam anything Value Any value.
-- @treturn ?anything|nil Returns a proper value. | Returns `nil` if invalid format type.
function Common.NetMessage:ToFormatType ( FormatType, Value )
    if FormatType == 'byte'
        or FormatType == 'char'
        or FormatType == 'short'
        or FormatType == 'long'
        or FormatType == 'angle'
        or FormatType == 'float'
        or FormatType == 'number'
    then
        Value = tonumber( Value );

        if FormatType == 'angle' then
            Value = Value * ( 360.0 / 256.0 );
        end

        return Value;

    elseif FormatType == 'vector' then
        return Common.Vector:FromString( tostring(Value) );

    elseif FormatType == 'string' then
        return tostring( Value );
    end

    return nil;
end


--- Metamethods
-- @section metamethod

--- Base class.
-- @tfield Common.NetMessage __index
Common.NetMessage.__index = Common.NetMessage;


--- Returns the name of this network message.
-- @tfield Common.NetMessage.ToString __tostring
Common.NetMessage.__tostring = Common.NetMessage.ToString;


--- Event Callbacks
-- @section callback

--- Called when this network message is sent to client.
--
-- **Note:** This event is called in `Game` module.
--
-- **Note:** This event is using `Hook` management.
--
-- @see Game.NetMessage:End
-- @see Common.NetMessage.ARGFORMAT
-- @tparam .netMessageArgumentProperty[] args The network message arguments.
-- @usage
-- local myMsg = Common.NetMessage:Register( "MyNetMessage" );
-- function myMsg:OnSent (args, format)
--   print (self.name .. 'is sent!' );
-- end
function Common.NetMessage:OnSent (args)
end


--- Called when this network message is received from server.
--
-- **Note:** This event is called in `UI` module.
--
-- **Note:** This event is using `Hook` management.
--
-- @see Game.NetMessage:End
-- @see Common.NetMessage.ARGFORMAT
-- @tparam .netMessageArgumentProperty[] args The network message arguments.
-- @usage
-- local myMsg = Common.NetMessage:Register( "MyNetMessage" );
-- function myMsg:OnReceived (args, format)
--   print (self.name .. 'is received!' );
-- end
function Common.NetMessage:OnReceived (args)
end

--- @section end


------------
-- Common Text Menu class.
--
-- Shared functions and properties for text menu classes.
--
-- @classmod Common.TextMenu
Common.TextMenu = {};


--- Maximum allowed menu slots to drawn.
-- @tfield[opt=10] number Common.TextMenu.maxSlot
Common.TextMenu.maxSlot = 10;


--- Valid menu slots.
--
Common.TextMenu.SLOT = {
    NUM1            =   1, -- Menu key 1.
    NUM2            =   2, -- Menu key 2.
    NUM3            =   3, -- Menu key 3.
    NUM4            =   4, -- Menu key 4.
    NUM5            =   5, -- Menu key 5.
    NUM6            =   6, -- Menu key 6.
    NUM7            =   7, -- Menu key 7.
    NUM8            =   8, -- Menu key 8.
    NUM9            =   9, -- Menu key 9.
    NUM0            =   0, -- Menu key 0.
}; Common.TextMenu.SLOT = table.readonly( Common.TextMenu.SLOT );


--- Valid menu slot bitflags.
--
Common.TextMenu.SLOTBITFLAG = {
    NUM1            =   (1<<1), -- Menu key 1.
    NUM2            =   (1<<2), -- Menu key 2.
    NUM3            =   (1<<3), -- Menu key 3.
    NUM4            =   (1<<4), -- Menu key 4.
    NUM5            =   (1<<5), -- Menu key 5.
    NUM6            =   (1<<6), -- Menu key 6.
    NUM7            =   (1<<7), -- Menu key 7.
    NUM8            =   (1<<8), -- Menu key 8.
    NUM9            =   (1<<9), -- Menu key 9.
    NUM0            =   (1<<0), -- Menu key 0.
}; Common.TextMenu.SLOTBITFLAG = table.readonly( Common.TextMenu.SLOTBITFLAG );


--- Menu status codes.
--
-- Passed on `Game.TextMenu:OnItemSelected`'s `slot` argument.
--
Common.TextMenu.STATUS = {
    NEXT            =   -1, -- Next menu page.
    BACK            =   -2, -- Previous menu page.
    EXIT            =   -3, -- Menu is closed.
    TIMEOUT         =   -4, -- Menu is closed due to display time is expired.
    REPLACED        =   -9 -- Menu is closed due to replaced with another incoming menu.
}; Common.TextMenu.STATUS = table.readonly( Common.TextMenu.STATUS );


--- Text menu key signals.
--
Common.SIGNAL.MENUKEY = {
    NUM1            =   1578534611, -- Menu key 1.
    NUM2            =   1578534612, -- Menu key 2.
    NUM3            =   1578534613, -- Menu key 3.
    NUM4            =   1578534614, -- Menu key 4.
    NUM5            =   1578534615, -- Menu key 5.
    NUM6            =   1578534616, -- Menu key 6.
    NUM7            =   1578534617, -- Menu key 7.
    NUM8            =   1578534618, -- Menu key 8.
    NUM9            =   1578534619, -- Menu key 9.
    NUM0            =   1578534610, -- Menu key 0.
    STATUS_NEXT     =   nil, -- Next page key.
    STATUS_BACK     =   nil, -- Previous page key.
    STATUS_EXIT     =   nil, -- Exit key.
    STATUS_TIMEOUT  =   nil, -- Display time is expired.
    STATUS_REPLACED =   nil, -- Replaced with another incoming menu.
};


Common.SIGNAL.MENUKEY.STATUS_NEXT       = Common.SIGNAL.MENUKEY.NUM0 + Common.TextMenu.STATUS.NEXT;
Common.SIGNAL.MENUKEY.STATUS_BACK       = Common.SIGNAL.MENUKEY.NUM0 + Common.TextMenu.STATUS.BACK;
Common.SIGNAL.MENUKEY.STATUS_EXIT       = Common.SIGNAL.MENUKEY.NUM0 + Common.TextMenu.STATUS.EXIT;
Common.SIGNAL.MENUKEY.STATUS_TIMEOUT    = Common.SIGNAL.MENUKEY.NUM0 + Common.TextMenu.STATUS.TIMEOUT;
Common.SIGNAL.MENUKEY.STATUS_REPLACED   = Common.SIGNAL.MENUKEY.NUM0 + Common.TextMenu.STATUS.REPLACED;


--- Methods
-- @section method


--- Metamethods
-- @section metamethod


--- Event Callbacks
-- @section callback

--- @section end


------------
-- Common Screen Fade class.
--
-- Shared functions and properties for screen fade classes.
--
-- @classmod Common.ScreenFade ScreenFade
Common.ScreenFade = {};

--- Screen fading flags.
--
Common.ScreenFade.FFADE = {
    IN          =   0x0000,     -- Just here so we don't pass 0 into the function.
    OUT         =   0x0001,     -- Fade out (not in).
    MODULATE    =   0x0002,     -- **Unsupported** Modulate (don't blend).
    STAYOUT     =   0x0004,     -- ignores the duration, stays faded out until new ScreenFade message received.
    LONGFADE    =   0x0008,     -- used to indicate the fade can be longer than 16 seconds (added for czero).
}; table.readonly( Common.ScreenFade.FFADE );


--- Methods
-- @section method


--- Metamethods
-- @section metamethod


--- Event Callbacks
-- @section callback

--- @section end


------------
-- Common HUD Text class.
--
-- Shared functions and properties for HUD text classes.
--
-- @classmod Common.HUDText HUDText
Common.HUDText = {};


--- Maximum text channels.
--
-- @tfield number maxChannel
Common.HUDText.maxChannel = 4;


--- Text effect mode.
--
Common.HUDText.EFFECT = {
    FADE            =   0,      -- Fade In/Out.
    CREDITS         =   1,      -- Flickery credits.
    SCANOUT         =   2,      -- Scan-out.
}; table.readonly( Common.HUDText.EFFECT );


--- Methods
-- @section method


--- Metamethods
-- @section metamethod


--- Event Callbacks
-- @section callback

--- @section end
--[[=========================================================
--  [COMMON] Post-loading
=========================================================--]]

-- Sets the zero vector.
Common.vecZero = table.readonly( Common.Vector:Create( 0 , 0 , 0 ) );

-- Init net messages.
Common.NetMessage:Register( "ShowMenu" );
Common.NetMessage:Register( "ScreenFade" );
Common.NetMessage:Register( "BarTime" );
Common.NetMessage:Register( "BarTime2" );
Common.NetMessage:Register( "TE_TEXTMESSAGE" );

-- Init colors.
Common.COLOR = {
    YELLOWISH   = Common.Color.FromHex( 0x00FFA000 ),
    REDISH      = Common.Color.FromHex( 0x00FF1010 ),
    GREENISH    = Common.Color.FromHex( 0x0000A000 ),
};

-- Replaces global module with ours.
_G.Common = table.extend( baseCommon , Common );

-- Lock up all tables.
Debug = table.readonly( Debug );
Hook = table.readonly( Hook );
_G.StringBuffer = table.readonly( StringBuffer );
Common.SIGNAL.MENUKEY = table.readonly( Common.SIGNAL.MENUKEY );
Common.SIGNAL = table.readonly( Common.SIGNAL );
Common.NetMessage.TYPE = table.extend( table.readonly( Common.NetMessage.TYPE, "Read-only built-in net msg." ), {} ); -- extended so scripters can insert new messages.
Common.COLOR = table.extend( table.readonly( Common.COLOR, "Read-only built-in color." ), {} ); -- extended so scripters can insert colors.
Common.Color = table.readonly( Common.Color );
Common.HUDText = table.readonly( Common.HUDText );
Common.ScreenFade = table.readonly( Common.ScreenFade );
Common.TextMenu = table.readonly( Common.TextMenu );
Common.NetMessage = table.readonly( Common.NetMessage );
Common.Vector = table.readonly( Common.Vector );
Common.Vector2D = table.readonly( Common.Vector2D );
Common = table.readonly( Common );
System = table.readonly( System );


print("[Donxon] Common is loaded.");