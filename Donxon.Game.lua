------------
-- Donxon Game module.
--
-- This module contains the functionality for scripts running on the server.
--
-- It can be used in script files registered in the "game" array of `project.json`.
--
-- @module Game


--[[=========================================================
--  [GAME] Pre-loading.
=========================================================--]]

--- Stores original `Game` table for later usages.
--
-- @local
-- @tfield Game baseGame
local baseGame = Game;

--- Game module.
--
-- @local
-- @tfield Game Game
local Game = {};

--- Delta timing.
--
-- @local
-- @table deltaTime
local deltaTime = { last = baseGame.GetTime(), delta = 0 };


--- The `Common.NetMessage.TYPE.SHOWMENU` parameters.
--
-- @struct .netMessageShowMenuParameter
-- @tfield short KeysBitSum
-- @tfield char Time
-- @tfield byte Multipart
-- @tfield string Text


--- The `Common.NetMessage.TYPE.SCREENFADE` parameters.
--
-- **Note:** Duration and HoldTime are in special units.
--
-- If FFADE_LONGFADE flag is set, 1 second is equal to (1<<8) i.e. 256 units.
-- Otherwise, 1 second is equal to (1<<12) i.e. 4096 units.
--
-- @struct .netMessageScreenFadeParameter
-- @tfield short Duration
-- @tfield short HoldTime Sets to 0 to remove the screenfade.
-- @tfield short Flags
-- @tfield byte ColorR
-- @tfield byte ColorG
-- @tfield byte ColorB
-- @tfield byte Alpha


--- The `Common.NetMessage.TYPE.BARTIME` parameters.
--
-- @struct .netMessageBarTimeParameter
-- @tfield short Duration Sets to 0 to hide the bar.


--- The `Common.NetMessage.TYPE.BARTIME2` parameters.
--
-- **Note:** Display time can be calculated with this formula:
-- (1 - (StartPercent / 100)) / Duration
--
-- @struct .netMessageBarTime2Parameter
-- @tfield short Duration Sets to 0 to hide the bar.
-- @tfield short StartPercent


--- The `Common.NetMessage.TYPE.TE_TEXTMESSAGE` parameters.
--
-- **Note:** Channel, X, Y, FadeInTime, FadeOutTime, HoldTime and FXTime are in special units.
--
-- Channel -> Must be assigned with operator AND 0xFF (Channel & 0xFF).
--
-- X, Y -> 1 unit is equal to (1<<13) i.e. 8192 units.
--
-- FadeInTime, FadeOutTime, HoldTime and FXTime -> 1 second is equal to (1<<8) i.e. 256 units.
--
-- @struct .netMessageTETextMessageParameter
-- @tfield byte Channel (Range = 1~`Common.HUDText.maxChannel`)(0 = auto, overwrites next iteration if full).
-- @tfield short X (Range = 0~1.0)(-1.0 = centered).
-- @tfield short Y (Range = 0~1.0)(-1.0 = centered).
-- @tfield byte Effect
-- @tfield byte TextColorR
-- @tfield byte TextColorG
-- @tfield byte TextColorB
-- @tfield byte TextAlpha
-- @tfield byte EffectColorR
-- @tfield byte EffectColorG
-- @tfield byte EffectColorB
-- @tfield byte EffectAlpha
-- @tfield short FadeInTime
-- @tfield short FadeOutTime
-- @tfield short HoldTime
-- @tfield[opt] short EffectTime Time the highlight lags behing the leading text in scan-out effect.
-- @tfield string Text


--- List of spawnable monsters.
--
-- @see Game.Monster.type
-- @see Game.Monster:Create
Game.MONSTERTYPE = {
    NONE                = nil,  -- None.
    NORMAL0             = nil,  -- Normal Zombie (Level 0).
    NORMAL1             = nil,  -- Normal Zombie (Level 1).
    NORMAL2             = nil,  -- Normal Zombie (Level 2).
    NORMAL3             = nil,  -- Normal Zombie (Level 3).
    NORMAL4             = nil,  -- Normal Zombie (Level 4).
    NORMAL5             = nil,  -- Normal Zombie (Level 5).
    NORMAL6             = nil,  -- Normal Zombie (Level 6).
    RUNNER0             = nil,  -- Runner Zombie (Level 0).
    RUNNER1             = nil,  -- Runner Zombie (Level 1).
    RUNNER2             = nil,  -- Runner Zombie (Level 2).
    RUNNER3             = nil,  -- Runner Zombie (Level 3).
    RUNNER4             = nil,  -- Runner Zombie (Level 4).
    RUNNER5             = nil,  -- Runner Zombie (Level 5).
    RUNNER6             = nil,  -- Runner Zombie (Level 6).
    HEAVY1              = nil,  -- Armored Zombie (Level 1).
    HEAVY2              = nil,  -- Armored Zombie (Level 2).
    GHOST               = nil,  -- Cloth Ghost (Halloween).
    PUMPKIN             = nil,  -- Pumpkin-headed Scarecrow (Halloween).
    PUMPKINHEAD         = nil,  -- Pumpkin Head (Halloween).
    A101AR              = nil,  -- A101AR (Assault Rifle).
    A104RL              = nil,  -- A104RL (Rocket Launcher).
    MUSHROOM1           = 248,  -- Orange Mushroom (Maple).
    MUSHROOM2           = 249,  -- Trail Mushroom (Maple).
    MUSHROOM3           = 250,  -- Horny Mushroom (Maple).
    SLIME1              = 251,  -- Crown Slime (Maple).
    SLIME2              = 687,  -- Slime (Maple).
    CHINA1              = 688,  -- Yellow Turban Soldier (China).
    CHINA2              = 689,  -- Yellow Turban General (China).
    SNOWMAN             = 763,  -- Snowman (Xmas).
    MINION1             = 940,  -- Red Minion (Space).
    MINION2             = 941,  -- Blue Minion (Space).
    HOOLIGAN1           = 1097, -- Hooligan A (Melee) (Soccer).
    HOOLIGAN2           = 1098, -- Hooligan B (Can Thrower) (Soccer).
    PROTOPHOBOS         = 1289, -- Phobos Prototype (Boss).
    GASTOWER            = 1509, -- Plague Turret (Shelter).
    BOMBER              = 1520, -- Normal Zombie (Bomber) (Shelter).
    BOOMER              = 1521, -- Runner Zombie (Self-destruct) (Shelter).
    KINGDOM1            = 1650, -- Runner Zombie (King) (Joseon Kingdom).
    KINGDOM2            = 1651, -- Runner Zombie (Level 1) (Male) (Joseon Kingdom).
    KINGDOM3            = 1652, -- Runner Zombie (Level 2) (Male) (Joseon Kingdom).
    KINGDOM4            = 1653  -- Runner Zombie (Level 3) (Female) (Joseon Kingdom).
}; Game.MONSTERTYPE = table.readonly( table.extend( baseGame.MONSTERTYPE, Game.MONSTERTYPE ) );


--- Render FX modes (entvars_t::renderfx).
--
-- @see Game.Entity:SetRenderFX
Game.RENDERFX = {
    NONE             =   0,   -- No effect (default).
    PULSESLOW        =   1,
    PULSEFAST        =   2,
    PULSESLOWWIDE    =   3,
    PULSEFASTWIDE    =   4,
    FADESLOW         =   5,
    FADEFAST         =   6,
    SOLIDSLOW        =   7,
    SOLIDFAST        =   8,
    STROBESLOW       =   9,
    STROBEFAST       =   10,
    STROBEFASTER     =   11,
    FLICKERSLOW      =   12,
    FLICKERFAST      =   13,
    NODISSIPATION    =   14,
    DISTORT          =   15,   -- Distort/scale/translate flicker.
    HOLOGRAM         =   16,   -- kRenderFxDistort + distance fade.
    DEADPLAYER       =   17,   -- kRenderAmt is the player index.
    EXPLODE          =   18,   -- Scale up really big!
    GLOWSHELL        =   19,   -- Glowing Shell.
    CLAMPMINSCALE    =   20,   -- Keep this sprite from getting very small (SPRITES only!).
    LIGHTMULTIPLIER  =   21    -- CTM !!!CZERO added to tell the studiorender that the value in iuser2 is a lightmultiplier.
}; Game.RENDERFX = table.readonly( table.extend( baseGame.RENDERFX, Game.RENDERFX ) );


--- Gets the delta time.
--
-- @treturn number The delta time.
function Game.GetDeltaTime()
    return deltaTime.delta;
end


--- Clamps an unsigned short value.
--
local function FixedUnsigned16 ( value, scale )
	return math.clamp( 0, 0xFFFF, value * scale );
end


--- Classes
-- @section classes


--- Network Message Sender class.
--
-- To sends messages to clients.
--
-- @tfield Game.NetMessage NetMessage


--- Game Text Menu class.
--
-- Main class.
-- To builds and displays text menus.
--
-- @tfield Game.TextMenu TextMenu

--- Game Screen Fade class.
--
-- Main class.
-- To fades the player's screen.
--
-- @tfield Game.ScreenFade ScreenFade


--- Game BarTime class.
--
-- Main class.
-- To displays progress bar similar to C4 planting/defusing progress bar.
--
-- @tfield Game.BarTime BarTime

--- @section end


--- Event Callbacks
-- @section callback
Game.Rule = {};

--- @section end


------------
-- Network Message Sender class.
--
-- To sends messages to clients.
--
-- @classmod Game.NetMessage
Game.NetMessage = {};


--- Net message buffers.
local netmsg = {
    instance = nil, -- Builder instance.
    started = false, -- Is started yet?
    org = nil, -- World destination.
    dest = nil, -- Network message destination type.
    ent = nil, -- Entity destination.
    list = nil, -- Argument list.
    args = nil, -- Argument values buffer.
    formats = nil, -- Argument formats buffer.
};


--- Argument format lookups table.
local argtype = {
    [Common.NetMessage.ARGFORMAT.BYTE] = 'B', -- Unsigned char.
    [Common.NetMessage.ARGFORMAT.CHAR] = 'b', -- Signed char.
    [Common.NetMessage.ARGFORMAT.SHORT] = 'h', -- Signed short.
    [Common.NetMessage.ARGFORMAT.LONG] = 'l', -- Signed long.
    [Common.NetMessage.ARGFORMAT.ANGLE] = 'B', -- Float in signed char.
    [Common.NetMessage.ARGFORMAT.FLOAT] = 'f', -- Float.
    [Common.NetMessage.ARGFORMAT.VECTOR] = 'z', -- Vector string.
    [Common.NetMessage.ARGFORMAT.STRING] = 'z', -- String.
    [Common.NetMessage.ARGFORMAT.NUMBER] = 'n', -- Lua number.
};


--- The `Game.NetMessage:Begin` options.
--
-- @struct .netMessageBeginOption
-- @tfield Common.NetMessage.MSG destination The destination type.
-- @tfield ?Common.NetMessage.TYPE|Common.NetMessage message The network message builder instance.
-- @tfield[opt] ?Common.Vector|table position The message's position on map.
-- @tfield[opt] ?number|Game.Entity player The player index receiving the message (0 = all players).


--- Methods
-- @section method

--- Marks the beginning of a client message.
--
-- @see Common.NetMessage:Register
-- @tparam ?Common.NetMessage.MSG|.netMessageBeginOption dest The destination type. | Options table.
-- @tparam ?Common.NetMessage.TYPE|Common.NetMessage msg The network message builder instance (Ignored if `dest` is a table).
-- @tparam[opt] ?Common.Vector|table origin The message's position on world (Ignored if `dest` is a table).
-- @tparam[opt] ?number|Game.Entity ent The player index receiving the message (0 = all players)(Ignored if `dest` is a table).
-- @treturn Game.NetMessage Returns this class for fluent interface.
function Game.NetMessage:Begin (dest, msg, origin, ent)
    if type( dest ) == "table" then
        return self:Begin (dest.destination, dest.message, dest.position, dest.player);
    end

    assert( not netmsg.started, "New message started when msg '"..(netmsg.instance and netmsg.instance.name or "nil").."' has not been sent yet." );
    netmsg.started = true;

    netmsg.instance = msg;
    Common.NetMessage:AssertTable( netmsg.instance );
    Debug.print( "[NM]", "(B)", netmsg.instance.name );

    -- save message destination.
    netmsg.org = origin;
    if netmsg.org ~= nil then
        Common.Vector:AssertTable( netmsg.org, true );
    end

    netmsg.dest = dest;
    assert( math.type(netmsg.dest), "Invalid dest." );

    if not math.type(ent) and ent ~= nil and ent.index ~= nil then
        ent = ent.index;
    end
    netmsg.ent = math.tointeger( ent );
    assert( netmsg.ent == nil or math.type(netmsg.ent), "Invalid ent index." );

    netmsg.list = {};
    netmsg.args = StringBuffer:Create();
    netmsg.formats = StringBuffer:Create();

    return self;
end


--- Ends the message and sends the message.
--
-- Automatically clears the message buffers.
--
-- @see Common.NetMessage:OnSent
-- @see Common.NetMessage:OnReceived
-- @treturn Game.NetMessage Returns this class for fluent interface.
function Game.NetMessage:End ()
    assert( netmsg.started, "Called with no active message." );
    local isGood = true;

    if netmsg.dest == Common.NetMessage.MSG.ALL
       or netmsg.dest == Common.NetMessage.MSG.BROADCAST
    then
        netmsg.ent = 0;

    elseif netmsg.dest == Common.NetMessage.MSG.ONE
           or netmsg.dest == Common.NetMessage.MSG.ONE_UNRELIABLE
    then
        if netmsg.ent == nil or netmsg.ent <= 0 then
            isGood = false;
            Debug.print( "[NM]", "(E)", "Bad ent index." );
        end

    else
        error( "Unsupported dest (" .. tostring(netmsg.dest) .. ").", 2 );
    end

    if isGood
    then
        for i = (netmsg.ent == 0 and 1 or netmsg.ent), (netmsg.ent == 0 and #netmsg.instance.syncvalue or netmsg.ent) do
            netmsg.instance.syncvalue[i].value = string.format(
                "%d%s%s%s%s",
                netmsg.ent, Common.NetMessage.GRPSEP
                , netmsg.formats:ToString(), Common.NetMessage.GRPSEP
                , netmsg.args:ToString()
            );
            -- Then, sets it to nil to prevents new connected players receiving same message.
            netmsg.instance.syncvalue[i].value = nil;
        end
        Debug.print( "[NM]", "(OS)", netmsg.instance.name );
        netmsg.instance:OnSent( netmsg.list );
    end

    Debug.print( "[NM]", "(E)", "End of message." );
    -- Post-clean ups.
    self:Clear();

    return self;
end


--- Clears the message buffers to make them available to send another message.
--
-- @treturn Game.NetMessage Returns this class for fluent interface.
function Game.NetMessage:Clear ()
    netmsg.started = false;
    netmsg.instance = nil;
    netmsg.org = nil;
    netmsg.dest = nil;
    netmsg.ent = nil;
    netmsg.list = nil;
    netmsg.args = nil;
    netmsg.formats = nil;

    return self;
end


--- Writes a value to the buffer.
--
-- @see Common.NetMessage.ARGFORMAT
-- @local
-- @string format The value format/datatype.
-- @param value The value to write in.
-- @treturn Game.NetMessage Returns this class for fluent interface.
function Game.NetMessage:Write (format , value)
    assert( netmsg.started, "Called with no active message." );
    -- Checks value validity.
    local packFmt = argtype[format];
    local arg = { string.unpack( packFmt, string.pack( packFmt, value ) ) };
    arg = arg[1];
    netmsg.args = netmsg.args .. (#netmsg.args > 0 and Common.NetMessage.ARGSEP or '') .. arg;
    netmsg.formats = netmsg.formats .. (#netmsg.formats > 0 and Common.NetMessage.ARGSEP or '') .. format;
    table.insert( netmsg.list, { value = arg, format = format });

    return self;
end


--- Writes a byte to the buffer.
--
-- @number value An unsigned char value.
-- @treturn Game.NetMessage Returns this class for fluent interface.
function Game.NetMessage:WriteByte (value)
    if value == -1 then value = 0xFF end; -- convert char to byte.
    self:Write( Common.NetMessage.ARGFORMAT.BYTE , value );

    return self;
end


--- Writes a character to the buffer.
--
-- @tparam ?number|string value A signed char value.
-- @treturn Game.NetMessage Returns this class for fluent interface.
function Game.NetMessage:WriteChar (value)
    if not math.type(value) then value = string.byte(value); end
    self:Write( Common.NetMessage.ARGFORMAT.CHAR , value );

    return self;
end


--- Writes a short to the buffer.
--
-- @number value A signed short value.
-- @treturn Game.NetMessage Returns this class for fluent interface.
function Game.NetMessage:WriteShort (value)
    self:Write( Common.NetMessage.ARGFORMAT.SHORT , value );

    return self;
end


--- Writes a long to the buffer.
--
-- @number value A signed long value.
-- @treturn Game.NetMessage Returns this class for fluent interface.
function Game.NetMessage:WriteLong (value)
    self:Write( Common.NetMessage.ARGFORMAT.LONG , value );

    return self;
end


--- Writes an angle to the buffer.
--
-- This is low-res angle.
--
-- @see Common.NetMessage:ToFormatType
-- @number value A float value.
-- @treturn Game.NetMessage Returns this class for fluent interface.
function Game.NetMessage:WriteAngle (value)
    value = math.floor((value) * 256 / 360) & 255;
    self:Write( Common.NetMessage.ARGFORMAT.ANGLE , value );

    return self;
end


--- Writes a coordinate to the buffer.
--
-- @number value A float value.
-- @treturn Game.NetMessage Returns this class for fluent interface.
function Game.NetMessage:WriteCoord (value)
    self:Write( Common.NetMessage.ARGFORMAT.FLOAT , value );

    return self;
end


--- Writes a vector to the buffer.
--
-- @tparam ?Common.Vector|table value A 3D vector table value.
-- @bool[opt=false] asVector Writes as vector value.
-- @treturn Game.NetMessage Returns this class for fluent interface.
function Game.NetMessage:WriteVector (value, asVector)
    Common.Vector:AssertTable( value, true );

    if not asVector then
        self:WriteCoord( value.x );
        self:WriteCoord( value.y );
        self:WriteCoord( value.z );
    else
        self:Write( Common.NetMessage.ARGFORMAT.VECTOR, Common.Vector.ToString(value) );
    end

    return self;
end


--- Writes a string to the buffer.
--
-- @number value A string value.
-- @treturn Game.NetMessage Returns this class for fluent interface.
function Game.NetMessage:WriteString (value)
    self:Write( Common.NetMessage.ARGFORMAT.STRING , value );

    return self;
end


--- Writes an entity index to the buffer.
--
-- @tparam ?number|Game.Entity value An entity index.
-- @treturn Game.NetMessage Returns this class for fluent interface.
function Game.NetMessage:WriteEntity (value)
    if not math.type(value) and value.index ~= nil then
        value = value.index;
    end
    self:WriteShort( value );

    return self;
end


--- Writes a float to the buffer.
--
-- Same as `Game.NetMessage:WriteCoord`.
--
-- @number value A float value.
-- @treturn Game.NetMessage Returns this class for fluent interface.
function Game.NetMessage:WriteFloat (value)
    self:WriteCoord( value );

    return self;
end


--- Writes a lua_Number to the buffer.
--
-- @number value A lua_Number value.
-- @treturn Game.NetMessage Returns this class for fluent interface.
function Game.NetMessage:WriteNumber (value)
    self:Write( Common.NetMessage.ARGFORMAT.NUMBER , value );

    return self;
end


--- Metamethods
-- @section metamethod


--- Event Callbacks
-- @section callback

--- @section end


------------
-- Game Text Menu class.
--
-- Main text menu class.
-- To builds and displays text menus.
--
-- @set wrap=true
-- @classmod Game.TextMenu
Game.TextMenu = {};
local baseTextMenu = Game.TextMenu;

--- The menu items.
--
-- @tfield table item

--- The menu configs.
--
-- @local
-- @tfield table config


--- The menu item's properties.
--
-- @struct .textMenuItemProperty
-- @tfield string text The display text.
-- @tfield[opt=nil] anything userdata A variable for storing arbitrary data.
-- @tfield[opt=false] boolean isDisabled The item has grey color and won't invokes callback.
-- @tfield[opt=false] boolean isVisualOnly The item should be a visual shift only (not shifting the slot numbering down).


--- The text menu configuration table.
--
-- @struct .textMenuConfiguration
-- @tfield[opt=7] number itemPerPage Number of items per page (0 = no paginating)(minimum = 1).
-- @tfield[opt="Back"] string backName Name of the back button.
-- @tfield[opt="More"] string nextName Name of the next button.
-- @tfield[opt="Exit"] string exitName Name of the exit button.
-- @tfield[opt="New text menu"] string title Menu title text.
-- @tfield[opt=Game.TextMenu.EXIT.ALL] number exit Exit mode.
-- @tfield[opt=false] boolean noColors Sets whether colors are not auto-assigned.
-- @tfield[opt="\r"] string numberColor Color indicator to use for slot numbers.
-- @tfield[opt=false] boolean pageCallback Whether to forward pagination slots to text menu callback.
-- @tfield[opt=true] boolean showPage Whether to show the page number in menu title.
-- @tfield[opt=false] boolean extraSlots Whether to use slot #8, #9, and #0 for items if possible.


--- The `Game.TextMenu:Add*` options.
--
-- @struct .textMenuAddOption
-- @tfield string text The display text.
-- @tfield[opt] anything userdata A variable for storing arbitrary data.
-- @tfield[opt] number position The menu item position.
-- @tfield[opt=false] boolean disabled The item has grey color and won't invokes callback.
-- @tfield[opt=false] boolean visualOnly The item should be a visual shift only (not shifting the slot numbering down).


--- The `Game.TextMenu:Open` options.
--
-- @struct .textMenuOpenOption
-- @tfield[opt=nil] ?Game.Player|nil player A player that receive this menu. | All connected players will receive this menu.
-- @tfield[opt=-1] number duration If >=0 menu will timeout after this many seconds (maximum = 255 seconds)(-2 = Don't change currently time set).
-- @tfield[opt=1] number page Page to start from (starting from 1).


--- List of available exit modes.
--
Game.TextMenu.EXIT = {
    ALL     = 1, -- Menu will have an exit option (default).
    NEVER   = -1, -- Menu will not have an exit option.
}; Game.TextMenu.EXIT = table.readonly( Game.TextMenu.EXIT );


--- List of available configurations to set.
--
-- @table Game.TextMenu.CONFIG
Game.TextMenu.CONFIG = {
    ITEM_PER_PAGE   = 'itemPerPage',    -- Number of items per page.
    BACK_NAME       = 'backName',       -- Name of the back button.
    NEXT_NAME       = 'nextName',       -- Name of the next button.
    EXIT_NAME       = 'exitName',       -- Name of the exit button.
    TITLE           = 'title',          -- Menu title text.
    EXIT            = 'exit',           -- Exit mode.
    NO_COLORS       = 'noColors',       -- Sets whether colors are not auto-assigned.
    NUMBER_COLOR    = 'numberColor',    -- Color indicator to use for slot numbers.
    PAGE_CALLBACK   = 'pageCallback',   -- Whether to forward pagination slots to text menu callback.
    SHOW_PAGE       = 'showPage',       -- Whether to show the page number in menu title.
    EXTRA_SLOTS     = 'extraSlots',     -- Whether to use slot #8, #9, and #0 for items if possible.
}; Game.TextMenu.CONFIG = table.readonly( Game.TextMenu.CONFIG );


--- Exit key slot.
--
local SLOT_EXIT = Common.TextMenu.SLOT.NUM0;

--- Players's text menu.
--
local plrActiveMenu = {};


--- Methods
-- @section method

--- Text menu's `Game.Rule.OnPlayerSignal` hook.
--
local function OnTextMenuItemSelected (self, player, signal)
    if player == nil then return; end
    if signal < Common.SIGNAL.MENUKEY.STATUS_REPLACED or signal > Common.SIGNAL.MENUKEY.NUM9 then return; end
    local plrIndex = player.index;
    local plrMenu = plrActiveMenu[ plrIndex ];
    if type(plrMenu) ~= "table" then Debug.print( "[TM]", "(OTMIS)", "Invalid menu." ); return; end
    local menuhandle = plrMenu.handle;
    if type(menuhandle) ~= "table" then Debug.print( "[TM]", "(OTMIS)", "Invalid handle." ); return; end
    local currPage = plrMenu.page or 1;
    local maxPerPage = menuhandle:GetMaxItemPerPage();

    -- Translates it back to original value.
    signal = signal - Common.SIGNAL.MENUKEY.NUM0;

    -- Handles special status codes.
    local hasPage = menuhandle:GetPageCount() > 1;
    if signal >= Common.TextMenu.SLOT.NUM0 then
        -- Has pagination.
        if hasPage then
            local displayTime = nil;
            if not math.type( plrMenu.nextCloseTime ) then
                displayTime = -1;
            else
                displayTime = plrMenu.nextCloseTime - Game.GetTime();

                if displayTime <= 0 then
                    displayTime = nil;
                    signal = Common.TextMenu.STATUS.TIMEOUT;
                    Debug.print( "[TM]", "(OTMIS)", "Menu is expired." );
                end
            end

            if displayTime then
                local backSignal = maxPerPage + 2;
                if backSignal >= Common.TextMenu.maxSlot then backSignal = 0; end
                if signal == maxPerPage + 1 then
                    signal = Common.TextMenu.STATUS.BACK;
                    menuhandle:Open( player, displayTime, currPage - 1 );

                elseif signal == backSignal then
                    signal = Common.TextMenu.STATUS.NEXT;
                    menuhandle:Open( player, displayTime, currPage + 1 );
                end
            end
        end

        -- Has exit key.
        if menuhandle:Get(Game.TextMenu.CONFIG.EXIT) ~= Game.TextMenu.EXIT.NEVER then
            if signal == SLOT_EXIT then
                signal = Common.TextMenu.STATUS.EXIT;
            end
        end
    end

    -- Retrieves item property.
    local prop = nil;
    if signal >= Common.TextMenu.SLOT.NUM0 then
        local index = maxPerPage * currPage;
        if signal ~= Common.TextMenu.SLOT.NUM0 then
            index = maxPerPage * (currPage-1) + signal;
        end
        prop = menuhandle:GetSelectableItems()[ index ];
        if type( prop ) ~= "table" then prop = nil; end
    end

    -- Forwards to callback.
    local isPageKey = (signal == Common.TextMenu.STATUS.NEXT or signal == Common.TextMenu.STATUS.BACK);
    local isPagePass = hasPage and menuhandle:Get( Game.TextMenu.CONFIG.PAGE_CALLBACK ) and isPageKey;
    if not hasPage or not isPageKey or isPagePass then
        Debug.print( "[TM]", "(OTMIS)", "OnSlotSelected." );
        menuhandle:OnSlotSelected( player, signal, currPage, prop );
    end

    -- Special case when menu is replacing by itself.
    if plrActiveMenu[ plrIndex ] and plrActiveMenu[ plrIndex ] ~= plrMenu then
        signal = Common.TextMenu.STATUS.REPLACED;
    end

    -- Clears the handle.
    if signal ~= Common.TextMenu.STATUS.REPLACED and not isPageKey then
        plrActiveMenu[ plrIndex ] = nil;
    end
end


--- Checks whether the table is compatible with text menu builder class.
--
-- @local
-- @tparam table v The table to check.
-- @bool[opt=false] checkMembers Asserts members data type.
-- @bool[opt=true] setDefault Set invalid members with default value (Ignored if `checkMembers` is true).
-- @treturn bool Return true if table is compatible.
function Game.TextMenu:AssertTable ( v , checkMembers , setDefault )
    AssertType( "v", "table", v, nil, nil, 3 );
    setDefault = (setDefault == nil) and true or setDefault;
    if checkMembers then
        AssertType( "item", "table", v.item, "property", nil, 3 );
        AssertType( "config", "table", v.config, "property", nil, 3 );
    elseif setDefault then
        if type( v.item ) ~= "table" then v.item = {}; end
        if type( v.config ) ~= "table" then
            v.config = {
                [self.CONFIG.ITEM_PER_PAGE] =   7,
                [self.CONFIG.BACK_NAME]     =   "Back",
                [self.CONFIG.NEXT_NAME]     =   "More",
                [self.CONFIG.EXIT_NAME]     =   "Exit",
                [self.CONFIG.TITLE]         =   "New text menu",
                [self.CONFIG.EXIT]          =   Game.TextMenu.EXIT.ALL,
                [self.CONFIG.NO_COLORS]     =   false,
                [self.CONFIG.NUMBER_COLOR]  =   [[\r]],
                [self.CONFIG.PAGE_CALLBACK] =   false,
                [self.CONFIG.SHOW_PAGE]     =   true,
                [self.CONFIG.EXTRA_SLOTS]   =   false,
            };
            -- Prevents unknown indexes.
            local errorFunc = function(_, key)error("Unknown config (" ..key.. ").", 2);end;
            setmetatable( v.config, {__index = errorFunc, __newindex = errorFunc} );
        end
    end

    return true;
end


--- Constructs a text menu builder.
--
-- @tparam ?string|nil title The menu title to set. Sets to `nil` to excludes title.
-- @treturn Game.TextMenu A new text menu builder.
function Game.TextMenu:Create ( title )
    -- Class properties.
    local o =
    {
        item = nil
        , config = nil
    };

    setmetatable( o, baseTextMenu );

    -- Sets default values.
    self:AssertTable( o );

    -- Passes the parameters.
    if title then o:Set( self.CONFIG.TITLE, tostring( title ) );
    else o:Set( self.CONFIG.TITLE, nil ); end

    -- Checks again.
    self:AssertTable( o, true );

    -- Multiple hooks.
    o = Hook:Create( table.extend( o, {} ) );

    Debug.print( "[TM]", "(C)", title );
    return o;
end


--- Gets the menu configuration(s).
--
-- @tparam[opt] Game.TextMenu.CONFIG configName The name of the configuration to get.
-- @treturn ?anything|.textMenuConfiguration Returns the configuration value(s).
function Game.TextMenu:Get ( configName )
    if configName ~= nil then AssertType( "configName", "string", configName, nil, nil, 2 ); end
    return configName == nil and self.config or self.config[ configName ];
end


--- Sets the menu configuration(s).
--
-- @tparam ?Game.TextMenu.CONFIG|.textMenuConfiguration configs The configuration to set (Name of the configuration | Configurations table).
-- @param[opt] ... The configuration parameters to set (Ignored if `configs` is a table).
-- @treturn self This text menu.
function Game.TextMenu:Set ( configs, ... )
    if type( configs ) == "table" then
        for k,v in pairs( configs ) do
            self:Set ( k,v );
        end
        return self;
    end

    AssertType( "configs", "string", configs, nil, nil, 2 );

    local varags = {...};
    if #varags == 1 then varags = varags[1]; end
    self.config[ configs ] = varags;

    return self;
end


--- Gets all selectable items from this menu.
--
-- @treturn table All selectable items.
function Game.TextMenu:GetSelectableItems ()
    local result = {};
    for _,v in ipairs(self.item) do
        if type( v ) == "table" and not v.isVisualOnly then
            table.insert( result, v );
        end
    end
    return result;
end


--- Gets an item from this menu.
--
-- @tparam number index The menu item index.
-- @treturn .textMenuItemProperty A menu item property.
function Game.TextMenu:GetItem ( index )
    return self.item[ index ];
end


--- Adds an item to this menu.
--
-- @tparam ?string|.textMenuAddOption displayText The display text. | Options table.
-- @tparam[opt] anything userData A variable for storing arbitrary data (Ignored if `displayText` is a table).
-- @tparam[opt=false] boolean isDisabled The item has grey color and won't invokes callback (Ignored if `displayText` is a table).
-- @tparam[opt=false] boolean isVisualOnly The item should be a visual shift only (not shifting the slot numbering down)(Ignored if `displayText` is a table).
-- @tparam[opt] number pos The menu item position (Ignored if `displayText` is a table).
-- @treturn self This text menu.
function Game.TextMenu:AddItem ( displayText, userData, isDisabled, isVisualOnly, pos )
    if type( displayText ) == "table" then
        return self:AddItem( displayText.text, displayText.userdata, displayText.disabled, displayText.visualOnly, displayText.position );
    end

    displayText = tostring( displayText );
    pos = math.tointeger( pos ) or #self.item + 1;

    -- Inserts into item table.
    table.insert( self.item, pos, { text = displayText , userdata = userData , isDisabled = isDisabled , isVisualOnly = isVisualOnly } );

    return self;
end


--- Adds a text line to this menu.
--
-- @tparam ?string|.textMenuAddOption displayText The display text. | Options table.
-- @tparam[opt=false] boolean isVisualOnly The line should be a visual shift only (not shifting the slot numbering down)(Ignored if `displayText` is a table).
-- @tparam[opt] number pos The menu item position (Ignored if `displayText` is a table).
-- @treturn self This text menu.
function Game.TextMenu:AddText ( displayText, isVisualOnly, pos )
    if type( displayText ) == "table" then
        return self:AddText( displayText.text, displayText.visualOnly, displayText.position );
    end

    if isVisualOnly == nil then isVisualOnly = false; end
    return self:AddItem( displayText, nil, false, isVisualOnly, pos );
end


--- Adds a blank line to this menu.
--
-- @tparam[opt=false] ?boolean|.textMenuAddOption isVisualOnly The line should be a visual shift only (not shifting the slot numbering down). | Options table.
-- @tparam[opt] number pos The menu item position (Ignored if `isVisualOnly` is a table).
-- @treturn self This text menu.
function Game.TextMenu:AddBlank ( isVisualOnly, pos )
    if type( isVisualOnly ) == "table" then
        return self:AddBlank( isVisualOnly.visualOnly, isVisualOnly.position );
    end

    if isVisualOnly == nil then isVisualOnly = false; end
    return self:AddText( '', isVisualOnly, pos );
end


--- Opens this menu.
--
-- @tparam[opt=nil] ?Game.Player|nil|.textMenuOpenOption player A player that receive this menu. | All connected players will receive this menu. | Options table.
-- @tparam[opt=-1] number displayTime If >=0 menu will timeout after this many seconds (maximum = 255 seconds)(-2 = Don't change currently time set)(Ignored if `player` is a table).
-- @tparam[opt=1] number pageIndex Page to start from (starting from 1)(Ignored if `player` is a table).
-- @treturn self This text menu.
function Game.TextMenu:Open ( player, displayTime, pageIndex )
    if player == "table" then
        return self:Open( player.player, player.duration , player.page );
    end

    if displayTime == nil then displayTime = -1; end
    if pageIndex == nil then pageIndex = 1; end
    local pageCount = self:GetPageCount();
    pageIndex = math.clamp( 1, pageCount, pageIndex );

    local maxPerPage = self:GetMaxItemPerPage();
    local hasPagination = pageCount > 1;
    local autoColor = not self:Get( self.CONFIG.NO_COLORS );
    local nextSlot = 1;
    local keyBitsums = 0;
    local buffer = StringBuffer:Create();

    -- Inserts menu title.
    local title = self:Get( self.CONFIG.TITLE ) or '';
    if self:Get( self.CONFIG.SHOW_PAGE ) and hasPagination then
        if autoColor then
            buffer = buffer .. string.format( "\\y%s %d/%d\n\\w\n", title, pageIndex, pageCount );

        else
            buffer = buffer .. string.format( "%s %d/%d\n\n", title, pageIndex, pageCount );
        end

    else
        if autoColor then
            buffer = buffer .. string.format( "\\y%s\n\\w\n", title );

        else
            buffer = buffer .. string.format( "%s\n\n", title );
        end
    end

    -- Finds the correct item index based on pagination.
    local startIndex = math.max( 1, (pageIndex-1) * maxPerPage );
    if hasPagination and startIndex > 1 then
        local startItem = self:GetSelectableItems()[startIndex];
        for k,v in ipairs(self.item)
        do
            if k >= startIndex then
                if v == startItem then
                    startIndex = k + 1;
                    break;
                end
            end
        end
    end

    -- Inserts menu items.
    local isBlank = false; -- Saved for padding spaces later.
    local parsedItems = 0;
    local numberColor = self:Get( self.CONFIG.NUMBER_COLOR ) or '';
    for i = startIndex, #self.item do
        if nextSlot > maxPerPage then break; end
        local isLastSlot = false;
        if nextSlot >= Common.TextMenu.maxSlot then isLastSlot = true; nextSlot = 0; end

        local currItem = self.item[i];
        local isVisualOnly = true; -- Ignores invalid items.
        if type( currItem ) == "table" then
            local displayText = currItem.text;
            isBlank = (not displayText or string.match( displayText, "%S") == nil);
            local isEnabled = not currItem.isDisabled;
            isVisualOnly = currItem.isVisualOnly;

            if isBlank then
                buffer = buffer .. "\n";

            elseif isVisualOnly then
                buffer = buffer .. string.format( "%s\n", displayText );

            else
                if isEnabled then
                    keyBitsums = keyBitsums | (1<<nextSlot);

                    if autoColor then
                        buffer = buffer .. string.format( "%s%d.\\w %s\n", numberColor, nextSlot, displayText );

                    else
                        buffer = buffer .. string.format( "%d. %s\n", nextSlot, displayText );
                    end

                else
                    if autoColor then
                        buffer = buffer .. string.format( "\\d%d. %s\n\\w", nextSlot, displayText );

                    else
                        buffer = buffer .. string.format( "#. %s\n", displayText );
                    end
                end
            end
        end

        parsedItems = parsedItems + 1;
        if isLastSlot then break; end
        if not isVisualOnly then nextSlot = nextSlot + 1; end
    end

    -- Inserts newlines.
    for i = 1, math.max( isBlank and 0 or 1, Common.TextMenu.maxSlot - parsedItems - (hasPagination and 2 or 0) ) do
        buffer = buffer .. "\n";
    end

    -- Inserts pagination keys.
    if hasPagination then
        local hasBackKey, hasNextKey = pageIndex ~= 1, pageIndex ~= pageCount;
        local displayText = self:Get( self.CONFIG.BACK_NAME ) or "Back";
        nextSlot = maxPerPage + 1;
        if hasBackKey then
            keyBitsums = keyBitsums | (1<<nextSlot);

            if autoColor then
                buffer = buffer .. string.format( "%s%d.\\w %s\n", numberColor, nextSlot, displayText );

            else
                buffer = buffer .. string.format( "%d. %s\n", nextSlot, displayText );
            end

        else
            if autoColor then
                buffer = buffer .. string.format( "\\d%d. %s\n\\w", nextSlot, displayText );

            else
                buffer = buffer .. string.format( "#. %s\n", displayText );
            end
        end

        displayText = self:Get( self.CONFIG.NEXT_NAME ) or "More";
        nextSlot = nextSlot + 1;
        if nextSlot >= Common.TextMenu.maxSlot then nextSlot = 0; end
        if hasNextKey then
            keyBitsums = keyBitsums | (1<<nextSlot);

            if autoColor then
                buffer = buffer .. string.format( "%s%d.\\w %s\n", numberColor, nextSlot, displayText );

            else
                buffer = buffer .. string.format( "%d. %s\n", nextSlot, displayText );
            end

        else
            if autoColor then
                buffer = buffer .. string.format( "\\d%d. %s\n\\w", nextSlot, displayText );

            else
                buffer = buffer .. string.format( "#. %s\n", displayText );
            end
        end
    end

    -- Inserts exit key.
    if self:Get(Game.TextMenu.CONFIG.EXIT) ~= self.EXIT.NEVER then
        keyBitsums = keyBitsums | (1<<0);

        local displayText = self:Get( self.CONFIG.EXIT_NAME ) or "Exit";
        if autoColor then
            buffer = buffer .. string.format( "%s%d.\\w %s\n", numberColor, SLOT_EXIT, displayText );

        else
            buffer = buffer .. string.format( "%d. %s\n", SLOT_EXIT, displayText );
        end
    end

    -- Saves the menu.
    local f,t = 1, Common.maxPlayer;
    if player then
        f,t = player.index, player.index;
    end
    for i = f, t do
        plrActiveMenu[ i ] = { handle = self, page = pageIndex, nextCloseTime = displayTime >= 0 and Game.GetTime() + displayTime or nil };
    end

    -- Fix value.
    displayTime = displayTime >= 1 and math.round( displayTime ) or math.ceil( displayTime );
    displayTime = math.clamp( 0, 255, displayTime );

    -- Sends to client(s).
    Game.NetMessage:Begin( player and Common.NetMessage.MSG.ONE or Common.NetMessage.MSG.ALL, Common.NetMessage.TYPE.SHOWMENU, nil, player and player.index or nil )
    :WriteShort( keyBitsums )
    :WriteChar( displayTime )
    :WriteByte( 0 )
    :WriteString( buffer:ToString() )
    :End();

    Debug.print( "[TM]", "(O)", "Menu is opened." );
    return self;
end


--- Closes a player's menu.
--
-- Effectively forcing the player to select exit slot.
-- The menu will removed on their screen, any results are invalidated and the callback is invoked.
--
-- @tparam Game.Player player The player.
-- @treturn self This text menu, if any.
function Game.TextMenu:Close ( player )
    if player == nil then return; end

    -- Calls the hook naturally.
    OnTextMenuItemSelected( nil, player, Common.SIGNAL.MENUKEY.STATUS_EXIT );

    -- Closes client's menu HUD.
    Game.NetMessage:Begin( Common.NetMessage.MSG.ONE, Common.NetMessage.TYPE.SHOWMENU, nil, player.index )
    :WriteShort( 0 )
    :WriteChar( 0 )
    :WriteByte( 0 )
    :WriteString( "" )
    :End();
end


--- Gets the number of selectable items in this menu.
--
-- @treturn number The number of selectable items in this menu.
function Game.TextMenu:GetItemCount ()
    return #self:GetSelectableItems();
end


--- Gets allowed maximum items per page.
--
-- @treturn number Maximum items per page.
function Game.TextMenu:GetMaxItemPerPage ()
    local perPage = self:Get( self.CONFIG.ITEM_PER_PAGE );
    if not math.type( perPage ) then perPage = 7; end
    local extraSlot = self:Get( self.CONFIG.EXTRA_SLOTS ) and ((perPage == 0 and 2 or 0) + (self:Get(Game.TextMenu.CONFIG.EXIT) == self.EXIT.NEVER and 1 or 0)) or 0;
    if perPage == 0 then perPage = 7; end
    perPage = math.clamp( 1, 7, perPage );
    return perPage + extraSlot;
end


--- Gets the number of pages in this menu.
--
-- @treturn number The number of pages in this menu.
function Game.TextMenu:GetPageCount ()
    local perPage = self:GetMaxItemPerPage();
    local counts = self:GetItemCount();
    if counts <= 0 or perPage <= 0 then return 1; end
    return math.ceil( counts / perPage );
end


--- Returns the title of this menu.
--
-- @treturn string The title of this text menu.
function Game.TextMenu:ToString ()
    return tostring( self:Get( self.CONFIG.TITLE ) );
end


--- Metamethods
-- @section metamethod

--- Base class.
-- @tfield Game.TextMenu __index
Game.TextMenu.__index = Game.TextMenu;


--- Returns the title of this menu.
-- @tfield Game.TextMenu.ToString __tostring
Game.TextMenu.__tostring = Game.TextMenu.ToString;


--- Event Callbacks
-- @section callback

--- Called when this menu's slot is selected.
--
-- **Note:** This event is using `Hook` management.
--
-- @see UI.TextMenu:SelectMenuItem
-- @tparam Game.Player player The player who accessing this menu.
-- @tparam ?number|Common.TextMenu.STATUS slot The selected item slot. | The menu status code.
-- @tparam number page Current menu page index.
-- @tparam ?.textMenuItemProperty|nil item The menu item property.
function Game.TextMenu:OnSlotSelected ( player, slot, page, item )
end

--- @section end


------------
-- Game Screen Fade class.
--
-- Main class.
-- To fades the player's screen.
--
-- @set wrap=true
-- @classmod Game.ScreenFade
Game.ScreenFade = {};


--- The `Game.ScreenFade:Show` options.
--
-- @see Common.ScreenFade.FFADE
-- @struct .screenFadeShowOption
-- @tfield[opt=nil] ?Game.Player|nil player A player that receive screen fade. | All connected players will receive screen fade.
-- @tfield[opt=Common.ScreenFade.FFADE.IN] number mode Fading mode.
-- @tfield[opt=false] bool modulate Modulate (don't blend).
-- @tparam[opt=0] number duration Fading duration (in second unit).
-- @tparam[opt=0] number holdTime Display duration after fading finished (in second unit).
-- @tparam[opt=0] number r Red color composition.
-- @tparam[opt=0] number g Green color composition.
-- @tparam[opt=0] number b Blue color composition.
-- @tparam[opt=0] number a Transparency.


--- Methods
-- @section method

--- Shows the screen fade.
--
-- @see Common.ScreenFade.FFADE
-- @tparam[opt=nil] ?Game.Player|nil|.screenFadeShowOption Player A player that receive screen fade. | All connected players will receive screen fade. | Options table.
-- @tparam[opt=0] number Duration Fading duration (in second unit)(Ignored if `player` is a table).
-- @tparam[opt=0] number HoldTime Display duration after fading finished (in second unit)(Ignored if `player` is a table).
-- @tparam[opt=0] number Flags The screen fading bitflags (Ignored if `player` is a table).
-- @tparam[opt=0] number ColorR Red color composition (Ignored if `player` is a table).
-- @tparam[opt=0] number ColorG Green color composition (Ignored if `player` is a table).
-- @tparam[opt=0] number ColorB Blue color composition (Ignored if `player` is a table).
-- @tparam[opt=0] number Alpha Transparency (Ignored if `player` is a table).
-- @treturn self This class.
function Game.ScreenFade:Show ( Player, Duration, HoldTime, Flags, ColorR, ColorG, ColorB, Alpha )
    if type( Player ) == "table" then
        local flags = Player.mode or 0;
        if Player.modulate then flags = flags | Common.ScreenFade.MODULATE; end
        return self:Show( Player.player, Player.duration, Player.holdTime, flags, Player.r, Player.g, Player.b, Player.a );
    end

    if math.type( Duration ) == nil then Duration = 0; end
    if math.type( HoldTime ) == nil then HoldTime = 0; end
    if math.type( Flags ) == nil then Flags = 0; end
    if math.type( ColorR ) == nil then ColorR = 0; end
    if math.type( ColorG ) == nil then ColorG = 0; end
    if math.type( ColorB ) == nil then ColorB = 0; end
    if math.type( Alpha ) == nil then Alpha = (Flags & Common.ScreenFade.FFADE.IN ~= 0) and 0 or 255; end

    ColorR = math.clamp( 0, 255, ColorR );
    ColorG = math.clamp( 0, 255, ColorG );
    ColorB = math.clamp( 0, 255, ColorB );
    Alpha = math.clamp( 0, 255, Alpha );

    -- Sends to client(s).
    local maxShortFade = 7;
    if Duration > maxShortFade or HoldTime > maxShortFade then Flags = Flags | Common.ScreenFade.FFADE.LONGFADE; end
    local scale = (Flags & Common.ScreenFade.FFADE.LONGFADE ~= 0) and (1<<8) or (1<<12);
    Game.NetMessage:Begin( Player and Common.NetMessage.MSG.ONE or Common.NetMessage.MSG.ALL, Common.NetMessage.TYPE.SCREENFADE, nil, Player and Player.index or nil )
    :WriteShort( FixedUnsigned16( Duration, scale ) )
    :WriteShort( FixedUnsigned16( HoldTime, scale ) )
    :WriteShort( Flags )
    :WriteByte( ColorR )
    :WriteByte( ColorG )
    :WriteByte( ColorB )
    :WriteByte( Alpha )
    :End();

    Debug.print( "[SF]", "(S)", (Flags & Common.ScreenFade.FFADE.LONGFADE ~= 0) and "Long Fade." or "Short Fade." );
    Debug.print( "[SF]", "(S)", "Sent." );
    return self;
end


--- Hides the screen fade.
--
-- @tparam[opt=nil] ?Game.Player|nil player A player that removes his/her screen fade. | All connected players will removes their screen fade.
-- @treturn self This class.
function Game.ScreenFade:Hide ( player )
    self:Show ( player );

    Debug.print( "[SF]", "(H)", "Sent." );
    return self;
end


--- Metamethods
-- @section metamethod


--- Event Callbacks
-- @section callback

--- @section end


------------
-- Game BarTime class.
--
-- Main bar time class.
-- To displays progress bar similar to C4 planting/defusing progress bar.
--
-- @classmod Game.BarTime
Game.BarTime = {};


--- The `Game.BarTime:Show` options.
--
-- **Note:** Display time can be calculated with this formula: (1 - (StartPercent / 100)) / Duration.
--
-- @struct .barTimeShowOption
-- @tfield[opt=nil] ?Game.Player|nil player A player that receive screen fade. | All connected players will receive screen fade.
-- @tparam[opt=0] number duration The display duration (in second unit).
-- @tparam[opt=0] number startPercent Start progress percentage (Range = 0~100).


--- Methods
-- @section method

--- Shows the progress bar.
--
-- **Note:** Display time can be calculated with this formula: (1 - (StartPercent / 100)) / Duration.
--
-- @tparam[opt=nil] ?Game.Player|nil|.barTimeShowOption player A player that displays this progress bar. | All connected players will displays this progress bar. | Optiins table.
-- @tparam[opt=0] number duration The display duration (in second unit)(Ignored if `player` is a table).
-- @tparam[opt=0] number startPercent Start progress percentage (Range = 0~100)(Ignored if `player` is a table).
-- @treturn self This class.
function Game.BarTime:Show ( player, duration, startPercent )
    if type( player ) == "table" then
        return self:Show( player.player, player.duration, player.startPercent );
    end

    if duration == nil then duration = 0; end
    if startPercent == nil then startPercent = 0; end

    startPercent = math.clamp( 0, 100, startPercent );

    -- Sends to client(s).
    Game.NetMessage:Begin( player and Common.NetMessage.MSG.ONE or Common.NetMessage.MSG.ALL, Common.NetMessage.TYPE.BARTIME2, nil, player and player.index or nil )
    :WriteShort( duration )
    :WriteShort( startPercent )
    :End();

    Debug.print( "[BT]", "(S)", "Sent." );
    return self;
end


--- Hides the progress bar.
--
-- @tparam[opt=nil] ?Game.Player|nil player A player that removes his/her progress bar. | All connected players will removes their progress bar.
-- @treturn self This class.
function Game.BarTime:Hide ( player )
    self:Show ( player );

    Debug.print( "[BT]", "(H)", "Sent." );
    return self;
end


--- Metamethods
-- @section metamethod


--- Event Callbacks
-- @section callback

-- @section end
--[[=========================================================
--  [GAME] Post-loading
=========================================================--]]

-- Extensions.
Game.Rule = table.extend( baseGame.Rule, Game.Rule, true );

-- Multiple Hooks.
Game.Rule = Hook:Create( Game.Rule );

-- Replaces global module with ours.
_G.Game = table.extend( baseGame , Game );

-- Lock up all tables.
Game.BarTime = table.readonly( Game.BarTime );
Game.ScreenFade = table.readonly( Game.ScreenFade );
Game.NetMessage = table.readonly( Game.NetMessage );
Game.TextMenu = table.readonly( Game.TextMenu );
Game = table.readonly( Game );

-- Internal hooks.
function Game.Rule:OnUpdate( time ) -- Delta timing calculation.
    deltaTime.delta  = time - deltaTime.last;
    deltaTime.last   = time;
end
function Game.Rule:OnPlayerDisconnect (player) -- TextMenu clear active handle.
    if player == nil then return; end

    plrActiveMenu[ player.index ] = nil;
end
Game.Rule.OnPlayerSignal = OnTextMenuItemSelected; -- TextMenu SelectMenuItem.


print("[Donxon] Game is loaded.");