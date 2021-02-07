------------
-- Donxon UI module.
--
-- This module contains the functionality for scripts running on the client.
--
-- It can be used in script files registered in the "ui" array of `project.json`.
--
-- @module UI


--[[=========================================================
--  [UI] Pre-loading.
=========================================================--]]

--- Stores original `UI` table for later usages.
-- @local
-- @tfield UI baseUI
local baseUI = UI;

--- UI module.
-- @local
-- @tfield UI UI
local UI = {};


--- The `UI:GetCenterPosition` options.
--
-- @struct .uiGetCenterPositionOption
-- @tfield[opt] int x The value of X.
-- @tfield[opt] int y The value of Y.
-- @tfield[opt] int width Width.
-- @tfield[opt] int height Height.


--- Delta timing.
-- @local
-- @table deltaTime
local deltaTime = { last = baseUI.GetTime(), delta = 0 };

--- Text alignment.
UI.ALIGN = {
    LEFT = 'left', -- Left text alignment.
    CENTER = 'center', -- Center text alignment.
    RIGHT = 'right', -- Right text alignment.
}; table.readonly( UI.ALIGN );


UI.FONT = {};
--- Small font table.
UI.FONT.SMALL = {
    font = 'small', -- Font type.
    height = 16, -- Font height.
}; table.readonly( UI.FONT.SMALL );


--- Medium font table.
UI.FONT.MEDIUM = {
    font = 'medium', -- Font type.
    height = 33, -- Font height.
}; table.readonly( UI.FONT.MEDIUM );


--- Large font table.
UI.FONT.LARGE = {
    font = 'large', -- Font type.
    height = 50, -- Font height.
}; table.readonly( UI.FONT.LARGE );


--- Very Large font table.
UI.FONT.VERYLARGE = {
    font = 'verylarge', -- Font type.
    height = 90, -- Font height.
}; table.readonly( UI.FONT.VERYLARGE );


--- Gets screen's relative position calculated from absolute position.
--
-- @tparam[opt=0] ?number|table x The value of X. | The vector-compatible table.
-- @number[opt=0] y The value of Y (Ignored if `x` is table).
-- @treturn Common.Vector2D The relative position.
function UI:GetScreenRelativePosition ( x , y )
    if x == nil then x = 0; end
    if math.type( y ) == nil then y = 0; end

    x = Common.Vector2D:Create( x , y );
    x,y = x.x, x.y;

    local size = UI.ScreenSize();
    if x ~= 0 then
        x = (size.width / x);
    end
    if y ~= 0 then
        y = (size.height / y);
    end

    return Common.Vector2D:Create( math.clamp( 0, 1, x ), math.clamp( 0, 1, y ) );
end


--- Gets screen's absolute position calculated from relative position.
--
-- @tparam[opt=0.0] ?number|table x The value of X (-1 = center position). | The vector-compatible table.
-- @number[opt=0.0] y The value of Y (-1 = center position)(Ignored if `x` is table).
-- @treturn Common.Vector2D The absolute position.
function UI:GetScreenAbsolutePosition ( x , y )
    if x == nil then x = 0; end
    if math.type( y ) == nil then y = 0; end

    x = Common.Vector2D:Create( x , y );
    x,y = x.x, x.y;

    -- Default parameters.

    if x == -1.0 then x = 0.5;
    elseif x < 0.0 then x = 1.0 + x;
    elseif x > 1.0 then x = 1.0; end
    if y == -1.0 then y = 0.5;
    elseif y < 0.0 then y = 1.0 + y;
    elseif y > 1.0 then y = 1.0; end

    local size = UI.ScreenSize();
    return Common.Vector2D:Create( (size.width * x), (size.height * y) );
end


--- Gets center position on the screen.
--
-- @tparam[opt] ?number|.uiGetCenterPositionOption x The value of X. | The options table.
-- @number[opt] y The value of Y (Ignored if `x` is option table).
-- @number[opt] width Width (Ignored if `x` is option table).
-- @number[opt] height Height (Ignored if `x` is option table).
-- @treturn Common.Vector2D The center position.
function UI:GetCenterPosition ( x, y, width, height )
    local center = UI:GetScreenAbsolutePosition( -1 , -1 );
    if x == nil then x = center.x; end
    if math.type( y ) == nil then y = center.y; end
    if type( x ) == "table" then
        width = x.width;
        height = x.height;
    end

    x = Common.Vector2D:Create( x , y );
    x,y = x.x, x.y;

    if math.type( width ) == nil then width = 0; end
    if math.type( height ) == nil then height = 0; end

    return Common.Vector2D:Create( x - (width/2), y - (height/2) );
end


--- Gets the delta time.
--
-- @treturn number The delta time.
function UI.GetDeltaTime()
    return deltaTime.delta;
end


--- Classes
-- @section classes


--- UI Rectangle class.
--
-- For drawing rectangles.
--
-- @tfield UI.Rectangle Rectangle


--- UI Progress Bar class.
--
-- For drawing progress bars.
--
-- @tfield UI.ProgressBar ProgressBar


--- UI HUD Text class.
--
-- For drawing HUD texts.
--
-- @tfield UI.HUDText HUDText


--- UI Text Menu class.
--
-- To displays text menus.
--
-- This class should be ignored.
-- Use `Game.TextMenu` class instead.
--
-- @tfield UI.TextMenu TextMenu


--- UI Screen Fade class.
--
-- To fades the screen.
--
-- @tfield UI.ScreenFade ScreenFade


--- UI BarTime class.
--
-- To displays progress bar similar to C4 planting/defusing progress bar.
--
-- @tfield UI.BarTime BarTime

--- @section end


--- Event Callbacks
-- @section callback
UI.Event = {};

--- @section end


------------
-- UI Rectangle class.
--
-- For drawing rectangles.
--
-- @classmod UI.Rectangle
UI.Rectangle = {};
local baseRectangle = UI.Rectangle;


--- Rectangle's stroke/border options.
--
-- @struct .rectangleStrokeOption
-- @tfield[opt=true] bool visible Draws rectangle stroke line borders.
-- @tfield[opt=1] integer size Line size.
-- @tfield[opt] integer r Red color composition (Range = 0~255).
-- @tfield[opt] integer g Green color composition (Range = 0~255).
-- @tfield[opt] integer b Blue color composition (Range = 0~255).
-- @tfield[opt=255] integer a Transparency (Range = 0~255).


--- Rectangle options.
--
-- @struct .rectangleOption
-- @tfield[opt] integer x Coordinate of X on screen.
-- @tfield[opt] integer y Coordinate of Y on screen.
-- @tfield[opt] integer width Width.
-- @tfield[opt] integer height Height.
-- @tfield[opt] integer r Red color composition (Range = 0~255).
-- @tfield[opt] integer g Green color composition (Range = 0~255).
-- @tfield[opt] integer b Blue color composition (Range = 0~255).
-- @tfield[opt] integer a Transparency (Range = 0~255).
-- @tfield[opt] .rectangleStrokeOption stroke Rectangle stroke line borders option.


--- The base class.
--
-- @tfield UI.Box _base

--- The stroke line borders.
--
-- @tfield UI.Box[] border


--- Methods
-- @section method

--- Checks whether the table is compatible with rectangle class.
--
-- @local
-- @tparam table v The table to check.
-- @bool[opt=false] checkMembers Asserts members data type.
-- @bool[opt=true] setDefault Set invalid members with default value (Ignored if `checkMembers` is true).
-- @treturn bool Return true if table is compatible.
function UI.Rectangle:AssertTable ( v , checkMembers , setDefault )
    AssertType( "v", "table", v, nil, nil, 3 );
    setDefault = (setDefault == nil) and true or setDefault;
    if checkMembers then
        AssertType( "_base", "userdata", v._base, "property", nil, 3 );
        AssertType( "option", "table", v.option, "property", nil, 3 );
        AssertType( "option.stroke", "table", v.option.stroke, "property", nil, 3 );
        AssertType( "border", "table", v.border, "property", nil, 3 );
    elseif setDefault then
        if type( v._base ) ~= "userdata" then v._base = baseUI.Box.Create(); end
        if type( v.option ) ~= "table" then v.option = {}; end
        if type( v.option.stroke ) ~= "table" then v.option.stroke = {
            visible = true,
            size = 1,
            r = Common.COLOR.YELLOWISH.r,
            g = Common.COLOR.YELLOWISH.g,
            b = Common.COLOR.YELLOWISH.b,
            a = 255,
        }; end
        if type( v.border ) ~= "table" then v.border = {}; end
    end

    return true;
end


--- Creates a rectangle.
--
-- @treturn UI.Rectangle This rectangle.
function UI.Rectangle:Create ()
    -- Class properties.
    local o =
    {
        option = nil
        , border = nil
    };

    setmetatable( o, table.clone( baseRectangle, false ) );

    -- Sets default values.
    self:AssertTable( o );
    o.option = table.merge( o.option, o._base:Get(), false );

    -- Extends from base.
    o = table.extend ( o._base, o );

    -- Checks again.
    self:AssertTable( o, true );

    return o;
end


--- Shows this rectangle to the screen.
--
-- @treturn UI.Rectangle This rectangle.
function UI.Rectangle:Show ()
    self._base:Show();
    self:UpdateStroke();

    return self;
end


--- Hides this rectangle from the screen.
--
-- @treturn UI.Rectangle This rectangle.
function UI.Rectangle:Hide ()
    self._base:Hide();
    self:UpdateStroke();

    return self;
end


--- Checks whether this rectangle is visible on the screen.
--
-- @function IsVisible
-- @treturn bool Returns `true` if visible.
--[[function UI.Rectangle:IsVisible ()
    return self._base:IsVisible();
end]]--


--- Sets this rectangle's options.
--
-- @tparam .rectangleOption arg The rectangle options to set.
-- @treturn UI.Rectangle This rectangle.
function UI.Rectangle:Set (arg)
    self._base:Set( arg );
    self.option = table.merge( self.option, arg, true );
    self.option = table.merge( self.option, self._base:Get(), false );
    self:AssertTable( self, true );

    local option = self.option.stroke;
    if option.visible then
        local border = self.border;
        local max = 4;
        for i = 1, max do
            local config = self:Get();
            config.r = option.r;
            config.g = option.g;
            config.b = option.b;
            config.a = option.a;

            border[i] = border[i] or baseUI.Box.Create();
            assert( type( border[i] ) == "userdata", "failed to create border[" .. i .. "]." );

            if i == 1 then
                config.x        = config.x - option.size;
                config.y        = config.y - option.size;
                config.width    = config.width + (option.size * 2);
                config.height   = option.size;

            elseif i == 2 then
                config.x        = config.x - option.size;
                config.y        = config.y - option.size;
                config.width    = option.size;
                config.height   = config.height + (option.size * 2);

            elseif i == 3 then
                config.x        = config.x + config.width;
                config.y        = config.y - option.size;
                config.width    = option.size;
                config.height   = config.height + (option.size * 2);

            else
                config.x        = config.x - option.size;
                config.y        = config.y + config.height;
                config.width    = config.width + (option.size * 2);
                config.height   = option.size;
            end

            border[i]:Set( config );
        end
    end
    self:UpdateStroke();

    return self;
end


--- Gets this rectangle's options.
--
-- @treturn .rectangleOption The options table.
function UI.Rectangle:Get ()
    return table.clone( self.option, true );
end


--- Updates this rectangle's stroke borders based on its options.
--
-- @treturn UI.Rectangle This rectangle.
function UI.Rectangle:UpdateStroke ()
    for i = 1, #self.border do
        if self.option.stroke.visible and self:IsVisible() then
            self.border[i]:Show();

        else
            self.border[i]:Hide();
        end
    end

    return self;
end


--- Metamethods
-- @section metamethod

--- Base class.
-- @tfield UI.Rectangle __index
UI.Rectangle.__index = UI.Rectangle;


--- Event Callbacks
-- @section callback

--- @section end


------------
-- UI Progress Bar class.
--
-- For drawing progress bars.
--
-- @classmod UI.ProgressBar
UI.ProgressBar = {};
local baseProgressBar = UI.ProgressBar;


--- Progress Bar's flexible bar options.
--
-- @struct .progressBarFlexibleBarOption
-- @tfield[opt] number percent Progress percentage (Range = 0~1).
-- @tfield[opt] integer r Red color composition (Range = 0~255).
-- @tfield[opt] integer g Green color composition (Range = 0~255).
-- @tfield[opt] integer b Blue color composition (Range = 0~255).
-- @tfield[opt=255] integer a Transparency (Range = 0~255).


--- Progress Bar options.
--
-- @struct .progressBarOption
-- @tfield[opt] .rectangleOption ... All rectangle options are applied here.
-- @tfield[opt] .progressBarFlexibleBarOption bar The bar options.


--- The base class.
--
-- @tfield UI.Box _base

--- The parent class.
--
-- @tfield UI.Rectangle _parent

--- The flexible bar.
--
-- @tfield UI.Box bar


--- Methods
-- @section method

--- Checks whether the table is compatible with progress bar class.
--
-- @local
-- @tparam table v The table to check.
-- @bool[opt=false] checkMembers Asserts members data type.
-- @bool[opt=true] setDefault Set invalid members with default value (Ignored if `checkMembers` is true).
-- @treturn bool Return true if table is compatible.
function UI.ProgressBar:AssertTable ( v , checkMembers , setDefault )
    setDefault = (setDefault == nil) and true or setDefault;
    UI.Rectangle:AssertTable( v , checkMembers , setDefault );
    if checkMembers then
        AssertType( "_parent", "table", v._parent, "property", nil, 3 );
        AssertType( "bar", "userdata", v.bar, "property", nil, 3 );
        AssertType( "option.bar", "table", v.option.bar, "property", nil, 3 );
    elseif setDefault then
        if type( v._parent ) ~= "table" then v._parent = UI.Rectangle:Create(); end
        if type( v.bar ) ~= "userdata" then v.bar = baseUI.Box.Create(); end
        if type( v.option.bar ) ~= "table" then v.option.bar = {
            x = 0,
            y = 0,
            width = 0,
            height = 0,
            r = Common.COLOR.YELLOWISH.r,
            g = Common.COLOR.YELLOWISH.g,
            b = Common.COLOR.YELLOWISH.b,
            a = 255,
            percent = 0,
        }; end
    end

    return true;
end


--- Creates a progress bar.
--
-- @treturn UI.ProgressBar This progress bar.
function UI.ProgressBar:Create ()
    -- Class properties.
    local o =
    {
        bar = nil
    };

    setmetatable( o, table.clone( baseProgressBar, false ) );

    -- Sets default values.
    self:AssertTable( o );
    o._parent:Set( o.option );
    o.option = nil;

    -- Extends from base.
    o = table.extend ( o._parent, o );

    -- Checks again.
    self:AssertTable( o, true );

    return o;
end


--- Shows this progress bar to the screen.
--
-- @treturn UI.ProgressBar This progress bar.
function UI.ProgressBar:Show ()
    self._parent:Show();
    self.bar:Show();

    return self;
end


--- Hides this progress bar from the screen.
--
-- @treturn UI.ProgressBar This progress bar.
function UI.ProgressBar:Hide ()
    self._parent:Hide();
    self.bar:Hide();

    return self;
end


--- Checks whether this progress bar is visible on the screen.
--
-- @function IsVisible
-- @treturn bool Returns `true` if visible.


--- Sets this progress bar's options.
--
-- @tparam .progressBarOption arg The progress bar options to set.
-- @treturn UI.ProgressBar This progress bar.
function UI.ProgressBar:Set (arg)
    self._parent:Set( arg );
    self:AssertTable( self, true );

    local option = self.option.bar;
    option.x = self.option.x;
    option.y = self.option.y;
    option.height = self.option.height;
    option.width = math.min( self.option.width * option.percent, self.option.width );
    self.bar:Set( option );

    return self;
end


--- Gets this progress bar's options.
--
-- @function Get
-- @treturn .progressBarOption The options table.


--- Metamethods
-- @section metamethod

--- Base class.
-- @tfield UI.ProgressBar __index
UI.ProgressBar.__index = UI.ProgressBar;


--- Event Callbacks
-- @section callback

--- @section end


------------
-- UI Text Menu class.
--
-- To displays text menus.
--
-- This class should be ignored.
-- Use `Game.TextMenu` class instead.
--
-- @classmod UI.TextMenu
UI.TextMenu = {};

--- Right-alignment items's horizontal position.
--
-- To avoids blocking player's crosshairs.
--
-- @tfield[opt=300] number rightAlignmentXPos.
UI.TextMenu.rightAlignmentXPos = 300;

--- Bottom padding size for each lines.
--
-- @tfield[opt=2] number bottomPaddingSize
UI.TextMenu.bottomPaddingSize = 2;


--- Text menu configs.
local txtmenu = {
    title = nil, -- Menu title/header.
    menuDisplayed = false, -- Menu display state.
    shutOffTime = -1, -- Next hide time.
    bitsValidSlots = 0, -- Valid slots bitfield.
    waitingForMore = false, -- Multipart finish state.
    prelocalisedMenuString = "", -- Prelocalised menu string buffer.
    menuString = "", -- Menu string buffer.
    txtLabels = {}, -- UI.Text elements.
    r = 255,
    g = 255,
    b = 255,
    x = 20,
    ralign = false,
};


--- Checks whether menu is expired.
--
local function MenuExpirationUpdate ()
    if ( UI.TextMenu:IsVisible() )
    then
        -- check for if menu is set to disappear
        if ( txtmenu.shutOffTime > 0 and txtmenu.shutOffTime <= UI:GetTime() )
        then  -- times up, shutoff
            UI.TextMenu:Close( false, true );
            return true;
        end
    end

    return false;
end


--- Methods
-- @section method

--- Interprets the given escape token (backslash followed by a letter).
--
-- The first character of the token must be a backslash.
-- The second character specifies the operation to perform:
--
-- \w : White text (this is the default)
--
-- \d : Dim (gray) text
--
-- \y : Yellow text
--
-- \r : Red text
--
-- \R : Right-align (just for the remainder of the current line)
--
-- @local
-- @string str Menu string buffer.
-- @number token Character position.
-- @treturn number The next character position.
function UI.TextMenu:ParseEscapeToken ( str, token )
    local nextStr = string.sub( str, token, token );
    if ( nextStr ~= '\\' ) then
        return token;
    end

    token = token + 1;
    nextStr = string.sub( str, token, token );

    if ( nextStr == '\0' ) then
        return token;

    elseif ( nextStr == 'w' ) then
        txtmenu.r = 255;
        txtmenu.g = 255;
        txtmenu.b = 255;

    elseif ( nextStr == 'd' ) then
        txtmenu.r = 100;
        txtmenu.g = 100;
        txtmenu.b = 100;

    elseif ( nextStr == 'y' ) then
        txtmenu.r = 255;
        txtmenu.g = 210;
        txtmenu.b = 64;

    elseif ( nextStr == 'r' ) then
        txtmenu.r = 210;
        txtmenu.g = 24;
        txtmenu.b = 0;

    elseif ( nextStr == 'R' ) then
        txtmenu.x = UI.TextMenu.rightAlignmentXPos;
        txtmenu.ralign = true;

    end

    return token + 1;
end


--- Checks whether current text menu is visible.
--
-- @treturn bool Returns true if visible.
function UI.TextMenu:IsVisible ()
    return txtmenu.menuDisplayed and true or false;
end


--- Draws current text menu if permitted.
--
-- @treturn self This class.
function UI.TextMenu:Draw ()
    if ( MenuExpirationUpdate() ) then Debug.print( "[TM]", "(D)", "Can't drawn (expired)." ); return self; end

    txtmenu.menuDisplayed = true;
    local fontType = UI.FONT.SMALL;
    local fontHeight = fontType.height;
    local lineHeight = fontHeight + UI.TextMenu.bottomPaddingSize;

    -- don't draw the menu if the scoreboard is being shown
    --if ( gViewPort && gViewPort->IsScoreBoardVisible() )
    --    return self;

    -- draw the menu, along the left-hand side of the screen

    -- count the number of newlines
    local nlc = 0;
    _,nlc = string.gsub( txtmenu.menuString, "%\n", '' );

    -- center it
    local y = UI:GetCenterPosition().y - ((nlc/2) * lineHeight) - 40; -- make sure it is above the say text

    txtmenu.r        = 255;
    txtmenu.g        = 255;
    txtmenu.b        = 255;
    txtmenu.x        = 20;
    txtmenu.ralign   = false;

    local token = 1;
    local sptr = string.sub( txtmenu.menuString, token, token );
    local txtId = 1;

    while ( sptr ~= '\0' )
    do
        if ( sptr == '\\' )
        then
            token = self:ParseEscapeToken( txtmenu.menuString, token );
            sptr = string.sub( txtmenu.menuString, token, token );

        elseif ( sptr == '\n' )
        then
            txtmenu.ralign   = false;
            txtmenu.x        = 20;
            y                = y + lineHeight;

            token = token + 1;
            sptr = string.sub( txtmenu.menuString, token, token );

        else
            local len = string.len( txtmenu.menuString );
            local fPos = token;
            token = math.min( string.find(txtmenu.menuString, '\0', token, true) or len, string.find(txtmenu.menuString, '\n', token, true) or len, string.find(txtmenu.menuString, '\\', token, true) or len );
            sptr = string.sub( txtmenu.menuString, token, token );
            local menubuf = string.sub( txtmenu.menuString, fPos, token-1 );

            local txtLabel = txtmenu.txtLabels[txtId];
            if txtLabel == nil then
                txtLabel = UI.Text:Create();
                txtLabel:Set({ font = fontType.font, height = fontType.height, a = 255 });
                txtmenu.txtLabels[txtId] = txtLabel;
            end

            -- Probably need a better, optimized way to doing this.
            local labelWidth = 0;
            for unicodeChar in System.UTF8.gensub( menubuf )
            do
                labelWidth = labelWidth + math.ceil( System:GetCharWidth( unicodeChar, fontHeight ) );
            end
            menubuf = menubuf .. '\0';

            if ( txtmenu.ralign )
            then
                -- IMPORTANT: Right-to-left rendered text does not parse escape tokens!
                txtmenu.x = txtmenu.x - labelWidth;
                txtLabel:Set({ width = labelWidth, align = "right", x = txtmenu.x, y = y, r = txtmenu.r, g = txtmenu.g, b = txtmenu.b, text = menubuf });

            else
                txtLabel:Set({ width = labelWidth, align = "left", x = txtmenu.x, y = y, r = txtmenu.r, g = txtmenu.g, b = txtmenu.b, text = menubuf });
                txtmenu.x = txtmenu.x + labelWidth;
            end
            txtLabel:Show();
            txtId = txtId + 1;
        end
    end

    -- Hides the unused elements.
    for i = txtId, #txtmenu.txtLabels do
        txtmenu.txtLabels[i]:Hide();
    end

    Debug.print( "[TM]", "(D)", "Menu is drawned." );
    return self;
end


--- Hides current text menu.
--
-- @treturn self This class.
function UI.TextMenu:Hide ()
    txtmenu.menuDisplayed = false;

    -- Hides all elements.
    for i = 1, #txtmenu.txtLabels do
        txtmenu.txtLabels[i]:Hide();
    end

    Debug.print( "[TM]", "(H)", "Menu is hidden." );
    return self;
end


--- Selects an item from the menu.
--
-- @see Game.TextMenu:OnSlotSelected
-- @number menu_item The selected menu item slot.
-- @treturn self This class.
function UI.TextMenu:SelectMenuItem ( menu_item )
    -- if menu_item is in a valid slot,  send a menuselect command to the server
    if ( self:IsVisible() and (menu_item >= 0) and (menu_item <= 9) and (txtmenu.bitsValidSlots & (1 << (menu_item)) ~= 0) )
    then
        UI.Signal( Common.SIGNAL.MENUKEY.NUM0 + menu_item );
        Debug.print( "[TM]", "(SMI)", menu_item, "." );

        -- remove the menu.
        self:Close();
    end

    return self;
end

--- Loads a text menu config.
--
-- Used for ShowMenu network message parser.
--
-- @tparam short KeysBitfield a bitfield of keys that are valid input.
-- @tparam char DisplayTime the duration, in seconds, the menu should stay up. -1 means is stays until something is chosen.
-- @tparam byte NeedMore a boolean, TRUE if there is more string yet to be received before displaying the menu, FALSE if it's the last string.
-- @tparam string str menu string to display.
-- @tparam[opt=true] bool drawWhenLoaded Draws the menu after fully loaded succesfully.
-- @treturn self This class.
function UI.TextMenu:Load ( KeysBitfield, DisplayTime, NeedMore, str, drawWhenLoaded )
    if drawWhenLoaded == nil then drawWhenLoaded = true; end
    txtmenu.bitsValidSlots = KeysBitfield;

    if DisplayTime > 0 then
        txtmenu.shutOffTime = DisplayTime + UI:GetTime();

    else
        txtmenu.shutOffTime = -1;
    end

    if txtmenu.bitsValidSlots > 0
    then
        if self:IsVisible() then self:Close( false, false, true ); end -- Replaced with another menu.

        if not txtmenu.waitingForMore then -- this is the start of a new menu
            txtmenu.prelocalisedMenuString = str;
        else
            -- append to the current menu string
            local zero = string.find( txtmenu.prelocalisedMenuString, '\0' );
            txtmenu.prelocalisedMenuString = string.sub( txtmenu.prelocalisedMenuString, 1, zero and zero-1 ) .. str;
        end
        txtmenu.prelocalisedMenuString = txtmenu.prelocalisedMenuString .. '\0';  -- ensure null termination (strncat/strncpy does not)

        if not NeedMore
        then  -- we have the whole string, so we can localise it now
            txtmenu.menuString = txtmenu.prelocalisedMenuString;
            if drawWhenLoaded then self:Draw(); end
        end

    else
        self:Close(); -- no valid slots means that the menu should be turned off

    end

    txtmenu.waitingForMore = NeedMore;
    Debug.print( "[TM]", "(L)", "Parsed." );

    return self;
end


--- Close the text menu.
--
-- @bool[opt=true] dontSendSignal Don't send special EXIT signals. Overriden other signal parameters.
-- @bool[opt=false] isTimedOut Menu display time is expired.
-- @bool[opt=false] isReplaced Menu is replaced with another incoming menu.
-- @treturn self This class.
function UI.TextMenu:Close ( dontSendSignal, isTimedOut, isReplaced )
    if self:IsVisible() then self:Hide(); end
    if dontSendSignal == nil then dontSendSignal = (not isTimedOut and not isReplaced);
    elseif dontSendSignal then isTimedOut = false; isReplaced = false; end

    -- Resets them back.
    if not isReplaced then
        txtmenu = {
            title = nil, -- Menu title/header.
            menuDisplayed = false, -- Menu display state.
            shutOffTime = -1, -- Next hide time.
            bitsValidSlots = 0, -- Valid slots bitfield.
            waitingForMore = false, -- Multipart finish state.
            prelocalisedMenuString = "", -- Prelocalised menu string buffer.
            menuString = "", -- Menu string buffer.
            txtLabels = txtmenu.txtLabels, -- UI.Text elements.
            r = 255,
            g = 255,
            b = 255,
            x = 20,
            ralign = false,
        };
    end

    -- Signal sending.
    if not dontSendSignal then
        if isTimedOut then
            UI.Signal( Common.SIGNAL.MENUKEY.STATUS_TIMEOUT );
            Debug.print( "[TM]", "(C)", "Menu is expired." );

        elseif isReplaced then
            UI.Signal( Common.SIGNAL.MENUKEY.STATUS_REPLACED );
            Debug.print( "[TM]", "(C)", "Menu is replaced." );

        else
            UI.Signal( Common.SIGNAL.MENUKEY.STATUS_EXIT );
            Debug.print( "[TM]", "(C)", "EXIT signal is sent." );

        end
    end

    Debug.print( "[TM]", "(C)", "Menu is closed." );
    return self;
end


--- Metamethods
-- @section metamethod


--- Event Callbacks
-- @section callback

--- @section end


------------
-- UI Screen Fade class.
--
-- To fades the screen.
--
-- @classmod UI.ScreenFade
UI.ScreenFade = {};


--- The `UI.ScreenFade:Draw` options.
--
-- @see Common.ScreenFade.FFADE
-- @struct .screenFadeDrawOption
-- @tfield[opt=Common.ScreenFade.FFADE.IN] Common.ScreenFade.FFADE mode Fading mode.
-- @tfield[opt=false] bool modulate Modulate (don't blend).
-- @tparam[opt=0] number duration Fading duration (in second unit).
-- @tparam[opt=0] number holdTime Display duration after fading finished (in second unit).
-- @tparam[opt=0] number r Red color composition.
-- @tparam[opt=0] number g Green color composition.
-- @tparam[opt=0] number b Blue color composition.
-- @tparam[opt=0] number a Transparency.


-- ScreenFade internal table.
local screenfade = {
    overlay = baseUI.Box.Create(),
    fadeSpeed = 0, -- How fast to fade (tics / second) (+ fade in, - fade out).
    fadeEnd = 0, -- When the fading hits maximum.
    fadeReset = 0, -- When to reset to not fading (for fadeout and hold).
    fadeAlpha = 0, -- Fade final alpha.
    fadeFlags = 0, -- Fading flags.
};


--- Updates the screenfade overlay.
--
local function ScreenFadeOverlayUpdate ()
    if not UI.ScreenFade:IsVisible() then return; end
    local time = UI.GetTime();

    -- Keep pushing reset time out indefinitely.
    if ( screenfade.fadeFlags & Common.ScreenFade.FFADE.STAYOUT ) ~= 0 then
        screenfade.fadeReset = time + 0.1;
    end

    if screenfade.fadeReset == 0 and screenfade.fadeEnd == 0 then
        return;	-- inactive.
    end

    -- all done?
    if time > screenfade.fadeReset and time > screenfade.fadeEnd then
        UI.ScreenFade:Hide();
        return;
    end

    local iFadeAlpha = 0;
    local testFlags = (screenfade.fadeFlags & ~Common.ScreenFade.FFADE.MODULATE);

    -- Stays same.
    if testFlags == Common.ScreenFade.FFADE.STAYOUT then
        iFadeAlpha = screenfade.fadeAlpha;

    -- Fading...
    else
        iFadeAlpha = screenfade.fadeSpeed * ( screenfade.fadeEnd - time );
        if ( screenfade.fadeFlags & Common.ScreenFade.FFADE.OUT ) ~= 0 then iFadeAlpha = iFadeAlpha + screenfade.fadeAlpha; end
        iFadeAlpha = math.clamp( 0, screenfade.fadeAlpha, iFadeAlpha );
    end

    -- Sets the transparency.
    screenfade.overlay:Set({ a = iFadeAlpha });
end


--- Methods
-- @section method

--- Draws the screen fade.
--
-- @see Common.ScreenFade.FFADE
-- @tparam[opt=0] ?number|.screenFadeDrawOption Duration Fading duration (in second unit). | Options table.
-- @tparam[opt=0] number HoldTime Display duration after fading finished (in second unit)(Ignored if `Duration` is a table).
-- @tparam[opt=0] number Flags The screen fading bitflags (Ignored if `Duration` is a table).
-- @tparam[opt=0] number ColorR Red color composition (Ignored if `Duration` is a table).
-- @tparam[opt=0] number ColorG Green color composition (Ignored if `Duration` is a table).
-- @tparam[opt=0] number ColorB Blue color composition (Ignored if `Duration` is a table).
-- @tparam[opt=0] number Alpha Transparency (Ignored if `Duration` is a table).
-- @treturn self This class.
function UI.ScreenFade:Draw ( Duration, HoldTime, Flags, ColorR, ColorG, ColorB, Alpha )
    if type( Duration ) == "table" then
        local flags = Duration.mode or 0;
        if Duration.modulate then flags = flags | Common.ScreenFade.MODULATE; end
        return self:Draw( Duration.duration, Duration.holdTime, flags, Duration.r, Duration.g, Duration.b, Duration.a );
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

    screenfade.fadeFlags = Flags;
    screenfade.fadeAlpha = Alpha;
    screenfade.fadeSpeed = 0;
    screenfade.fadeEnd = Duration;
    screenfade.fadeReset = HoldTime;

    -- Calculates fade speed.
    local time = UI.GetTime();
	if Duration > 0 then
        if ( Flags & Common.ScreenFade.FFADE.OUT ) ~= 0 then
            if screenfade.fadeEnd > 0 then
                screenfade.fadeSpeed = -(screenfade.fadeAlpha / screenfade.fadeEnd);
            end

            screenfade.fadeEnd = screenfade.fadeEnd + time;
            screenfade.fadeReset = screenfade.fadeReset + screenfade.fadeEnd;

        else
            if screenfade.fadeEnd > 0 then
                screenfade.fadeSpeed = screenfade.fadeAlpha / screenfade.fadeEnd;
            end

            screenfade.fadeReset = screenfade.fadeReset + time;
            screenfade.fadeEnd = screenfade.fadeEnd + screenfade.fadeReset;
        end
    end

    local overlay = screenfade.overlay;
    overlay:Set({
        x = -100,
        y = -100,
        width = UI.ScreenSize().width + 200,
        height = UI.ScreenSize().height + 200,
        r = ColorR,
        g = ColorG,
        b = ColorB,
        a = ((Flags & Common.ScreenFade.FFADE.OUT) ~= 0) and Alpha or 0,
    });
    overlay:Show();

    return self;
end


--- Hides the screen fade.
--
-- @treturn self This class.
function UI.ScreenFade:Hide ()
    screenfade.fadeReset = 0;
    screenfade.fadeEnd = 0;
    screenfade.overlay:Hide();

    return self;
end


--- Checks whether the screen fade is visible.
--
-- @treturn bool Returns `true` if visible.
function UI.ScreenFade:IsVisible ()
    return screenfade.overlay:IsVisible();
end


--- Metamethods
-- @section metamethod


--- Event Callbacks
-- @section callback

--- @section end


------------
-- UI BarTime class.
--
-- To displays progress bar similar to C4 planting/defusing progress bar.
--
-- @classmod UI.BarTime
UI.BarTime = {};


--- The `UI.BarTime:Draw` options.
--
-- **Note:** Display time can be calculated with this formula: (1 - (StartPercent / 100)) / Duration.
--
-- @struct .barTimeDrawOption
-- @tparam[opt=0] number duration The display duration (in second unit).
-- @tparam[opt=0] number startPercent Start progress percentage (Range = 0~1).


-- BarTime internal table.
local bartime = {
    progress = UI.ProgressBar:Create(),
    speed = math.maxinteger,
};


--- Updates the progress bar.
--
local function BarTimeProgressUpdate ()
    local progress = bartime.progress;
    local current = progress:Get().bar.percent;
    local max = 1;
    if current < max then
        current = current + (bartime.speed * UI.GetDeltaTime());
        --current = math.clamp( 0, max, current );
        progress:Set({ bar = { percent = current } });

    elseif UI.BarTime:IsVisible() then
        UI.BarTime:Hide();
    end
end


--- Methods
-- @section method

--- Draws the BarTime HUD.
--
-- @tparam ?number|.barTimeDrawOption Duration The display duration (in second unit). | Options table.
-- @tparam number StartPercent Start progress percent (Range = 0~1)(Ignored if `Duration` is a table).
-- @treturn self This class.
function UI.BarTime:Draw ( Duration, StartPercent )
    if type( Duration ) == "table" then
        return self:Draw( Duration.duration, Duration.startPercent );
    end

    if Duration == nil then Duration = 0; end
    if StartPercent == nil then StartPercent = 0; end

    if Duration <= 0 then self:Hide(); return; end
    StartPercent = math.clamp( 0, 1, StartPercent );

    local size = UI.ScreenSize();
    local progress = bartime.progress;
    local config = progress:Get();
    local borders = config.stroke.size * 2;
    config.x = (size.width + borders) / 4;
    config.y = (size.height + borders) * 2 / 3;
    config.width = size.width / 2;
    config.height = 10;
    config.r = 0;
    config.g = 0;
    config.b = 0;
    config.a = 153;
    config.bar.r = Common.COLOR.YELLOWISH.r;
    config.bar.g = Common.COLOR.YELLOWISH.g;
    config.bar.b = Common.COLOR.YELLOWISH.b;
    config.bar.a = 255;
    config.bar.percent = StartPercent;
    bartime.speed = 1 / Duration;
    progress:Set( config );
    progress:Show();

    return self;
end


--- Hides the BarTime HUD.
--
-- @treturn self This class.
function UI.BarTime:Hide ()
    local progress = bartime.progress;
    if progress:IsVisible() then
        progress:Hide();
    end

    return self;
end


--- Checks whether the BarTime HUD is visible.
--
-- @treturn bool Returns `true` if visible.
function UI.BarTime:IsVisible ()
    return bartime.progress:IsVisible();
end


--- Metamethods
-- @section metamethod


--- Event Callbacks
-- @section callback

-- @section end
--[[=========================================================
--  [UI] Post-loading
=========================================================--]]

-- Extensions.
UI.Event = table.extend( baseUI.Event, UI.Event, true );

-- Multiple Hooks.
UI.Event = Hook:Create( UI.Event );

-- Init net messages.
function Common.NetMessage.TYPE.SHOWMENU:OnReceived (args)
    if not IsUIModule() then return; end
    if ( #args ~= 4 ) then Debug.print( "[NM]", "(OR)", "Invalid length ", #args, "." ); return; end

    UI.TextMenu:Load( args[1].value, args[2].value, args[3].value ~= nil and args[3].value ~= 0, args[4].value );
end
function Common.NetMessage.TYPE.SCREENFADE:OnReceived (args)
    if not IsUIModule() then return; end
    if ( #args ~= 7 ) then Debug.print( "[NM]", "(OR)", "Invalid length ", #args, "." ); return; end

    local Flags = args[3].value;
    local scale = (Flags & Common.ScreenFade.FFADE.LONGFADE ~= 0) and (1<<8) or (1<<12);
    local Duration = args[1].value / scale;
    local HoldTime = args[2].value / scale;

    UI.ScreenFade:Draw( Duration, HoldTime, Flags, args[4].value, args[5].value, args[6].value, args[7].value );
end
function Common.NetMessage.TYPE.BARTIME:OnReceived (args)
    if not IsUIModule() then return; end
    if ( #args ~= 1 ) then Debug.print( "[NM]", "(OR)", "Invalid length ", #args, "." ); return; end

    UI.BarTime:Draw( args[1].value );
end
function Common.NetMessage.TYPE.BARTIME2:OnReceived (args)
    if not IsUIModule() then return; end
    if ( #args ~= 2 ) then Debug.print( "[NM]", "(OR)", "Invalid length ", #args, "." ); return; end

    UI.BarTime:Draw( args[1].value, args[2].value / 100 );
end

-- Replaces global module with ours.
_G.UI = table.extend( baseUI , UI );

-- Lock up all tables.
UI.BarTime = table.readonly( UI.BarTime );
UI.ScreenFade = table.readonly( UI.ScreenFade );
UI.TextMenu = table.readonly( UI.TextMenu );
UI.ProgressBar = table.readonly( UI.ProgressBar );
UI.Rectangle = table.readonly( UI.Rectangle );
UI.FONT = table.readonly( UI.FONT );
UI = table.readonly( UI );

-- Internal hooks.
function UI.Event:OnKeyDown (inputs) -- TextMenu SelectMenuItem.
    if inputs[UI.KEY.NUM1] then
        UI.TextMenu:SelectMenuItem( 1 );

    elseif inputs[UI.KEY.NUM2] then
        UI.TextMenu:SelectMenuItem( 2 );

    elseif inputs[UI.KEY.NUM3] then
        UI.TextMenu:SelectMenuItem( 3 );

    elseif inputs[UI.KEY.NUM4] then
        UI.TextMenu:SelectMenuItem( 4 );

    elseif inputs[UI.KEY.NUM5] then
        UI.TextMenu:SelectMenuItem( 5 );

    elseif inputs[UI.KEY.NUM6] then
        UI.TextMenu:SelectMenuItem( 6 );

    elseif inputs[UI.KEY.NUM7] then
        UI.TextMenu:SelectMenuItem( 7 );

    elseif inputs[UI.KEY.NUM8] then
        UI.TextMenu:SelectMenuItem( 8 );

    elseif inputs[UI.KEY.NUM9] then
        UI.TextMenu:SelectMenuItem( 9 );

    elseif inputs[UI.KEY.NUM0] then
        UI.TextMenu:SelectMenuItem( 0 );
    end
end
function UI.Event:OnUpdate() -- Delta timing calculation.
    local time = UI.GetTime();
    deltaTime.delta  = time - deltaTime.last;
    deltaTime.last   = time;
end
UI.Event.OnUpdate = ScreenFadeOverlayUpdate; -- ScreenFade overlay updating.
UI.Event.OnUpdate = function() MenuExpirationUpdate() end; -- TextMenu limited display time.
UI.Event.OnUpdate = BarTimeProgressUpdate; -- BarTime progress updating.


print("[Donxon] UI is loaded.");