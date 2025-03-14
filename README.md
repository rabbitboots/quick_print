Version: **v1.1.1**

# quick\_print.lua

QuickPrint is a text drawing library for the [LÖVE](https://love2d.org/) Framework.


![quickprint\_gh\_1](https://user-images.githubusercontent.com/23288188/168460007-1d08b8ba-3893-4e07-a01b-21a2f3332a8e.png)


## Features

* Virtual tab stops
* Can print to LÖVE Text Objects
* Basic support for scaled text (for pixel-art LÖVE ImageFonts)
* Tweak per-font vertical metrics and scale using an intermediate table


## Hello World

```lua
local quickPrint = require("quick_print")
local qp = quickPrint.new()

local tabs = {0, 128, 160, 256}

function love.update(dt)
	tabs[2] = love.mouse.getX()
end

function love.draw()
	qp:reset()
	qp:setTabs(tabs)

	qp:print("Hello ", "World! ", "Lorem ", "Ipsum")

	qp:setTabs()
end
```

Check out the demo files for more examples.


## How it works

QuickPrint updates an internal cursor position with every draw. When virtual tab stops are enabled, the next write is positioned relative to the current tab X position. It can draw text to the screen/canvas, or add text to a LÖVE Text object.

Functions take effect immediately (there is no reshaping step, and limited memory of previous drawing operations), so it's limited in the kinds of layouts it supports. The library was originally written for debug-printing.

QuickPrint's writing functions are split into "plain" and "formatted" categories. The plain functions convert all values to be printed to strings. As a result, LÖVE `coloredtext` sequences won't work. The formatted writing functions do not apply any type conversion, and are programmed to handle `coloredtext`.


## Public Functions


### quickPrint.new

Creates and returns a new quick\_print state table.

`quickPrint.new(ref_w, ref_h)`

* `ref_w`: (math.huge) Reference width for the cursor. Affects formatted print calls with non-left alignment.
* `ref_h`: (math.huge) Reference height for the cursor. Doesn't affect printing, but may help with other tasks such as setting a draw scissor.

**Returns:** A new `qp` state table.


### quickPrint.registerFont

Registers a font with the auxiliary font database (see *Auxiliary Data* section). All fonts are registered upon first being used with QuickPrint, but you may register fonts ahead of time to apply additional tweaks. This can be helpful with LÖVE ImageFonts. Note that if there is an existing aux table for this font, it will be overwritten by a new one.

`local aux = quickPrint.registerFont(font)`

* `font`: The LÖVE Font object to register.

**Returns:** The aux data table for this font.


### quickPrint.getAux

Gets a font's auxiliary data table (see *Auxiliary Data* section). If not found, creates, registers and returns a new table.

`local aux = quickPrint.getAux(font)`

* `font`: The LÖVE Font object to register.

**Returns:** The font's auxiliary data table.


## State Get/Set, Cursor Movement, Tab Advance

### qp:getFont

Gets the LÖVE graphics state font, or the font associated with a LÖVE Text object which is assigned to `qp`.

`qp:getFont()`

**Returns:** A LÖVE Font object.


### qp:setTextObject

Assigns a LÖVE Text object to `qp`, or removes any existing object. All print commands will be directed to the Text object instead of the framebuffer/canvas. The `qp` table should be reset after calling, and you should call `Text:clear()` to ensure you are working with a clean slate.

`qp:setTextObject(text_object)`

* `text_object`: The LÖVE Text object to assign, or false/nil to remove any existing Text object.


### qp:getTextObject

Returns the currently assigned `qp` Text object, or nil if none is assigned.

`local text_object = qp:getTextObject()`

**Returns:** A LÖVE Text object or nil.


### qp:setTabs

Assigns a table of virtual tab stops, or removes any existing tab sequence. Each entry is either a number representing the tab's absolute X position, or a sub-table containing `x` and `align` fields. Although the X positions are absolute, they should be ordered left-to-right in the table.

`qp:setTabs(tabs)`

* `tabs`: A sequence of tab stops, or `false`/`nil` to remove any assigned tabs.


### qp:getTabs

Gets the currently-assigned table of tabs, or nil if no tabs are assigned.

`local tabs_t = qp:getTabs()`

**Returns:** Table of tabs if present, or nil if nothing is assigned.


### qp:setTabIndex

Sets the current tab index. Does not check if the index is valid or that the qp state has a tabs table assigned. Note that the cursor will not automatically go backwards to a tab that is behind.

`qp:setTabIndex(i)`

* `i`: The tab index to jump to.


### qp:getTabIndex

Gets the tab index, or false if tab state is invalid.

`local tab_i = qp:getTabIndex()`

**Returns:** The current tab index, or false if tab state is invalid.


### qp:setAlign

Sets the horizontal align mode. Alignment behavior varies between plain and formatted print functions. `justify` mode behaves like `left` in plain functions. Some printing functions have arguments which override this setting.

`qp:setAlign(align)`

* `align`: The LÖVE align mode. Can be `left`, `center`, `right`, or `justify`.

**See:** LÖVE Wiki: [AlignMode](https://love2d.org/wiki/AlignMode)


### qp:getAlign

Gets the horizontal align mode.

`local align = qp:getAlign()`

**Returns:** The align LÖVE enum.


### qp:setDefaultAlign

Sets the default horizontal align mode, which is applied by `qp:reset()`.

`qp:setDefaultAlign(align)`

* `align`: The LÖVE align mode. Can be `left`, `center`, `right`, or `justify`.

**Notes:**

* For plain text, alignment is relative to the current cursor X position. For formatted text, it is relative to the reference width and the current tab stop, if tabs are enabled. Some functions can override alignment. `justify` applies to formatted-print calls only, and will be treated as `left` for plain writes.

* LÖVE Wiki: [AlignMode](https://love2d.org/wiki/AlignMode)


### qp:getDefaultAlign

Gets the default horizontal align mode.

`local default_align = qp:getAlign()`

**Returns:** The default align LÖVE enum.


### qp:setVAlign

Sets the vertical align mode. Text is placed relative to the cursor Y and the current font's vertical metrics.

`qp:setVAlign(v_align)`

* `v_align`: The vertical align mode. Can be `top`, `middle`, `true-middle`, `baseline`, or `bottom`.

**Notes:**

* The vertical align modes are:

  * `top`: (default) Cursor is at the top of the text.

  * `middle`: Cursor is at the midpoint between the ascent and baseline metrics.

  * `true-middle`: Cursor is at half the font height.

  * `bottom`: Cursor is at the bottom of the text.

* `top` is recommended when using a single font. The other modes may be helpful when mixing fonts.

* If using `middle` or `baseline` with an ImageFont, you must set the baseline metric in the font's aux table, (Except for height, ImageFonts do not have valid vertical metrics.) Otherwise, the text will appear at the wrong vertical position. See *Auxiliary Data* for more info.


### qp:getVAlign

Gets the vertical align mode.

`local v_align = qp:getVAlign()`

**Returns:** The vertical align mode.


### qp:setDefaultVAlign

Sets the default vertical align mode, applied in `qp:reset()`.

`qp:setDefaultVAlign(v_align)`

* `v_align`: The vertical align mode. Can be `top`, `middle`, `true-middle`, `baseline`, or `bottom`. *(See qp:setVAlign() for more info.)*


### qp:getDefaultVAlign

Gets the default vertical align mode.

`local default_v_align = qp:getDefaultVAlign()`

**Returns:** The default vertical align mode.


### qp:advanceX

Moves the X cursor by a number of pixels. (Cursor X advance is generally only useful with left alignment. The other align modes are intended to be used with virtual tab stops.) Clears kerning memory.

`qp:advanceX(width)`

* `width`: Number of pixels to move


### qp:advanceXStr

Moves the X cursor by the pixel-width of a string, measured in reference to the current active font. Clears kerning memory.

`qp:advanceXStr(str)`

* `str`: The string whose width will be used (via `Font:getWidth()`.)


### qp:setXMin

Moves the X cursor to at least the requested minimum position. Clears kerning memory, even if the X position is unaffected.

`qp:advanceXMin(x_min)`

* `x_min`: The minimum position.


### qp:advanceXCoarse

Moves the X cursor right in "coarse" steps, acting somewhat like a tab stop without involving the `qp.tabs` table. Clears kerning memory.

`qp:advanceXMod(coarse_x, margin)`

* `coarse_x`: The "snap-to" width to use when positioning the cursor, in pixels.

* `margin`: (0) Adds pixel padding to the current X position, making it jump to the next coarse position earlier. Use to ensure there is a buffer of empty space between printed text.


### qp:advanceTab

If tab stops are assigned, moves the X cursor to the current virtual tab stop, if it is currently behind. Increments the tab stop index. Clears kerning memory. If no tabs are assigned, does nothing.

`qp:advanceTab()`


### qp:setPosition

Moves the cursor to an arbitrary position, relative to the origin. Clears kerning memory and invalidates tab stop state.

`qp:setPosition(x, y)`

* `x`: X position, relative to `qp.origin_x`.
* `y`: Y position, relative to `qp.origin_y`.


### qp:setXPosition

Moves the cursor to an arbitrary horizontal position, relative to the origin. Clears kerning memory and invalidates tab stop state.

`qp:setXPosition(x)`

* `x`: X position, relative to `qp.origin_x`.


### qp:setYPosition

Moves the cursor to an arbitrary vertical position, relative to the origin. Does not clear kerning memory or tab stop state.

`qp:setYPosition(y)`

* `y`: Y position, relative to `qp.origin_y`.


### qp:getPosition

Gets the current cursor position, relative to the origin.

`local x, y = qp:getPosition()`

**Returns:** The cursor X and Y positions (`qp.x` and `qp.y`).


### qp:getXPosition

Gets the current cursor X position, relative to the origin.

`local x = qp:getXPosition()`

**Returns:** The cursor X position (`qp.x`).


### qp:getYPosition

Gets the current cursor Y position, relative to the origin.

`local y = qp:getYPosition()`

**Returns:** The cursor Y position (`qp.y`).


### qp:movePosition

Moves the cursor, relative to the current position. Resets kerning memory and invalidates tab stop state.

`qp:movePosition(dx, dy)`

* `x`: Amount to add to the current X position (`qp.x`).
* `y`: Amount to add to the current Y position (`qp.y`).


### qp:moveXPosition

Moves the cursor horizontally, relative to the current position. Resets kerning memory and invalidates tab stop state.

`qp:moveXPosition(dx)`

* `x`: Amount to add to the current X position (`qp.x`).


### qp:moveYPosition

Moves the cursor vertically, relative to the current position. Does not reset kerning memory or tab stop state.

`qp:moveYPosition(dy)`

* `y`: Amount to add to the current Y position (`qp.y`).


### qp:setOrigin

Repositions the `qp` origin (top-left printing area). Resets cursor position to (0, 0). Resets kerning memory and the printed range rectangle.

`qp:setOrigin(origin_x, origin_y)`

* `origin_x`: New X origin.
* `origin_y`: New Y origin.


### qp:setXOrigin

Repositions the `qp` X origin (left printing area). Resets cursor position to (0, 0). Resets kerning memory and the printed range rectangle.

`qp:setXOrigin(origin_x)`

* `origin_x`: New X origin.


### qp:setYOrigin

Repositions the `qp` Y origin (top printing area). Resets cursor position to (0, 0). Resets kerning memory and the printed range rectangle.

`qp:setYOrigin(origin_y)`

* `origin_y`: New Y origin.


### qp:getOrigin

Gets the current `qp` origin.

`local orig_x, orig_y = qp:getOrigin()`

**Returns:** The `qp` origin X and Y (`qp.origin_x` and `qp.origin_y`).


### qp:getXOrigin

Gets the current `qp` X axis origin.

`local orig_x = qp:getXOrigin()`

**Returns:** The `qp` X origin (`qp.origin_x`).


### qp:getYOrigin

Gets the current `qp` Y axis origin

`local orig_y = qp:getYOrigin()`

**Returns:** The `qp` Y origin (`qp.origin_y`).


### qp:moveOrigin

Moves the `qp` origin relative to its current location. Resets cursor position to (0, 0). Resets kerning memory and the printed range rectangle.

`qp:moveOrigin(dx, dy)`:

* `dx`: Amount to add to the current X origin (`qp.origin_x`).
* `dy`: Amount to add to the current Y origin (`qp.origin_y`).


### qp:setReferenceDimensions

Sets the current reference width and height (of the printing area). Resets kerning memory.

`qp:setReferenceDimensions(ref_w, ref_h)`

* `ref_w`: New base width (`qp.ref_w`).
* `ref_h`: New base height (`qp.ref_h`).

**Note:** Reference height is not currently used by QuickPrint, but is provided in case it helps with positioning and applying scissor-boxes.


### qp:getReferenceDimensions

Gets the current reference dimensions.

`local ref_w, ref_h = qp:getReferenceDimensions()`

**Returns:** The current reference dimensions.


### qp:setReferenceWidth

Sets the `qp` reference width (of the printing area). Resets kerning memory.

`qp:setReferenceWidth(ref_w)`

* `ref_w`: The new reference width.


### qp:getReferenceWidth

Gets the `qp` reference width.

`local ref_w = qp:getReferenceWidth()`

**Returns:** The reference width.


### qp:setReferenceHeight

Sets the `qp` reference height (of the printing area). Resets kerning memory.

`qp:setReferenceHeight(ref_h)`

* `ref_h`: The new reference height.

**Note:** Reference height is not currently used by QuickPrint, but is provided in case it helps with positioning and applying scissor-boxes.


### qp:getReferenceHeight()

Gets the current reference height.

`local ref_h = qp:getReferenceHeight()`

**Returns:** The reference height.


### qp:setScale

Sets the `qp` scale. Intended to help with drawing pixel art ImageFonts within a scaled interface. These values will be passed as the `sx` and `sy` arguments for `love.graphics.print()` and `love.graphics.printf()`, and the cursor will attempt to take the scale into account when moving forward.

`qp:setScale(sx, sy)`

* `sx` X scale. 1.0 is normal size, 2.0 is double, 0.5 is half, etc.
* `sy` *(sx)* Y scale.


### qp:getScale

Gets the current `qp` scale.

`local sx, sy = qp:getScale()`

**Returns:** The X scale and Y scale values (`qp.sx`, `qp.sy`).


### qp:setVerticalPadding

Sets a vertical padding value, which is applied whenever the cursor moves down a line.

`qp:setVerticalPadding(pad_v)`

* `pad_v` Additional padding (in pixels).

**Note:** It may be more effective to set a custom line height multiplier in your LÖVE Font objects. See: [Font:setLineHeight()](https://love2d.org/wiki/Font:setLineHeight)


### qp:getVerticalPadding

Gets the current vertical padding value.

`local pad_v = qp:getVerticalPadding()`

**Returns:** The vertical padding value (`qp.pad_v`)


### qp:getPrintedRange

Gets the cursor's rectangular travel area since the last call to `qp:reset()`, or since any changes have been made to the cursor origin.

`local x1, y1, x2, y2 = _mt_qp:getPrintedRange()`

**Returns:** The furthest left, top, right and bottom cursor positions from origin (0,0).

#### Notes

* This method can be used along with a Text object to determine the rectangular space of what has been printed (to the Text object, internally) before actually drawing it.


### qp:reset

Moves the cursor to (0, 0), resetting:

* Alignment modes to the defaults
* The tab stop index to 1
* The printed range rectangle
* Kerning memory

It does not clear the `qp.tabs` table, nor does it remove bound Text objects.

`qp:reset()`


### qp:down

Moves the cursor down by a number of lines. Line height is determined by the current font, its line height setting, and the `qp`'s Y scaling. Vertical padding (`qp.pad_v`) is applied once per call. Clears kerning memory.

`qp:down(qty)`

* `qty`: (1) How many lines to move down. Numbers less than 1 are ignored.


### qp:up

Like `qp:down()`, but moves the cursor up by a number of lines. Clears kerning memory.

`qp:up(qty)`

* `qty`: (1) How many lines to move up. Numbers less than 1 are ignored.

#### Notes

* This method is intended to help place multiple lines against the bottom of a container or the screen, when the number of lines isn't known ahead of time. Position the cursor, write the lines in reverse order with `qp:write()`, and use `qp:up()` to step upwards.


### qp:clearKerningMemory

Clears kerning memory, and nothing else.

`qp:clearKerningMemory()`


## Plain Writing Functions

In all plain writing functions, values are converted to strings before being passed to `love.graphics.print()`.


### qp:write

Writes a varargs series of strings to a line.

`qp:write(...)`

* `...` Varargs list of variables to write.


### qp:writeSeq

A version of `qp:write()` that takes one sequence (array table).

`qp:writeSeq(tbl)`

* `tbl`: Table of values to write. Values can be any type except `nil`.


### qp:print

Writes a varargs list of arguments to a line, and then moves the cursor to the start of the next line.

`qp:print(...)`

* `...` Varargs list of variables to write.


### qp:printSeq

Version of `qp:print()` that takes one sequence (array table).

`qp:printSeq(tbl)`

* `tbl`: Table of values to write. Values can be any type except `nil`.


## Formatted Writing Functions

These do not convert values to strings, and are programmed to support `coloredtext` sequences. Unlike the plain functions, they take only one string or `coloredtext` sequence per call.


### qp:writefSingle

Prints one string or `coloredtext` sequence using formatting features provided by `love.graphics.printf()`. This function assumes that the text will not exceed one line (or that the caller is not concerned if it happens to wrap). If you use horizontal align modes other than `"left"`, you must set a reference width (`qp.ref_w`), or else the text will render infinitely to the right. This function is also affected by virtual tab stop state. It does not advance the X cursor.

`qp:writefSingle(text, align)`

* `text`: The string or `coloredtext` sequence to print.
* `align`: (`qp.align`) LÖVE AlignMode enum: `"left"`, `"center"`, `"right"` or `"justify"`.


### qp:printfSingle

Like `qp:writefSingle()`, but automatically moves the cursor down one line after printing.

`qp:printfSingle(text, align)`

* `text`: The string or `coloredtext` sequence to print.
* `align`: (`qp.align`) LÖVE AlignMode enum: `"left"`, `"center"`, `"right"` or `"justify"`.


### qp:printf

Prints one string or `coloredtext` sequence using formatting features provided by `love.graphics.printf()`, and then moves the cursor down to the next free line. Unlike `qp:writefSingle()` and `qp:printfSingle()`, this does not take the virtual tab state into account.

`qp:printf(text, align)`

* `text`: The string or `coloredtext` sequence to print.
* `align`: (`qp.pf_align`) LÖVE AlignMode enum: `"left"`, `"center"`, `"right"` or `"justify"`.

**Notes:**

* This function will generate a temporary table and some strings in order to calculate the new Y cursor position.


## Auxiliary Data

The `quickPrint.aux_db` table holds supplemental metadata for fonts. It can help with the placement of LÖVE ImageFonts, which do not have a baseline metric. The table uses weak references so that it does not prevent LÖVE Font objects from being destroyed by the garbage collector.

An aux data table contains the following fields:

* `height`: Defaults to `font:getHeight()`.

* `ascent`: Defaults to `font:getAscent()`.

* `descent`: Defaults to `font:getDescent()`.

* `baseline`: Defaults to `font:getBaseline()`.

* `sx`: (1.0) Horizontal scale, multiplied with `qp.sx`.

* `sy`: (1.0) Vertical scale, multiplied with `qp.sy`.

* `ox`: (0) Horizontal drawing offset in pixels. Not scaled by `aux.sx`.

* `oy`: (0) Vertical drawing offset in pixels. Not scaled by `aux.sy`.

The ascent, descent and baseline metrics are invalid for LÖVE ImageFonts, so if you want to use baseline vertical alignment with them, you should change those settings in their aux tables.

As Font objects are used as keys, a font may have only one aux data table assigned at a time.


## Tips, Limitations

* QuickPrint does not currently handle RTL text.

* Text objects do not support multiple simultaneous fonts, so you shouldn't change a Text object's font as you write to it.

* QuickPrint is not optimized, and cannot be optimized very much given its design. (It's quick as in *quick and dirty*.) If you have a lot of text that rarely changes, you can save some CPU cycles by printing it to a LÖVE Text object and drawing that, only clearing and rewriting the Text when there's a change. Rendering to a canvas is another option.
