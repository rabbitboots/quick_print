# QuickPrint Changelog

## v1.0.6: 2023-02-28
* Added `aux_db`, a table of supplementary font information. Allows setting stand-in vertical metrics and scaling for LÖVE ImageFonts, thereby solving some issues in 1.0.5 related to vertical alignment. New public functions:
  * `quickPrint.registerFont(font)`
  * `local aux = quickPrint.getAux(font)`
* Added `qp.line_font` as a way to automatically clear kerning memory when the current font doesn't match the last-known used font between write calls (on a single line).
* Shuffled some internal functions around while adding `aux_db`.
* Changed policy on not doing type-check assertions on LÖVE Objects. LÖVE Text Objects / TextBatches and Fonts are now checked as `userdata`.
* Removed obsolete comments in `qp:writeFSingle`.


## v1.0.5: 2023-02-27
* Added `qp.v_align` (`top` (default), `middle`, `true-middle`, `baseline`, `bottom`) and associated methods:
  * `qp:setVAlign(v_align)`
  * `local v_align = qp:getVAlign()`

Note that `middle` and `baseline` modes should not be used with LÖVE ImageFonts, as they rely on vertical font metrics that are not valid for this type of font.

* Minor fix to enum_align error message.
* Added `demo_v_align.lua`, and Vertical Alignment tests to `full_test.lua`.


## v1.0.4: 2023-02-10
* Added `qp:setTabIndex(i)` and `qp:getTabIndex()`.
* Removed `qp.pf_justify_threshold (0-1)`.
  * This was only applicable to `qp:printfSingle()` and `qp:writefSingle()` with no tabs set. None of the bundled demos or tests touched it (including the supposed `full_test.lua`. *Oops*). Both functions have align parameters, so the caller can switch align modes before invoking the function, making it redundant.
* Minor edits to README.md.
* Minor changes to demo/test files:
  * Added check for "Text" -> "TextBatch" object renaming in LÖVE 12.0 dev builds.
  * `demo_align.lua`: Fixed incorrect placement of `love.graphics.origin()`. Centered instructions and increased font size.
  * `full_test.lua`: Merged content from (and deleted) `test_v1_0_3.lua`. Added align-priority test. Reviewed and renumbered tests.


### Upgrading From 1.0.3 To 1.0.4
* In the small chance that you used `pf_justify_threshold`, you will have to set alignment manually for the final line sent to `qp:writefSingle()` or `qp:printfSingle()`. For example:

```lua
local quickPrint = require("quick_print")
local font = love.graphics.newFont(16)
local text_w = 160
local qp = quickPrint.new(text_w, 600)

function love.draw()
	qp:reset()
	local width, lines = font:getWrap("In the dark hotel room, CRT static danced on his sullen face.", text_w)

	qp:setAlign("justify")
	for i = 1, #lines - 1 do
		qp:printfSingle(lines[i])
	end

	qp:setAlign("left")
	qp:printfSingle(lines[#lines])
end
```


## v1.0.3: 2022-06-22
* Added single-axis versions of:
  * `setOrigin()`: `setXOrigin()` and `setYOrigin()`
  * `getOrigin()`: `getXOrigin()` and `getYOrigin()`


## v1.0.2: 2022-05-28

* Added `advanceXCoarse()`, which provides basic "snap to grid"-like positioning of the cursor X position.
* Added `setXMin()`, which moves the cursor X only if the current X position is less than the requested position.
* Split the string-accepting logic of `advanceX()` into a separate function: `advanceXStr()`.
* Added some single-axis versions of cursor position methods:
  * `setPosition()`: `setXPosition()` and `setYPosition()`
  * `getPosition()`: `getXPosition()` and `getYPosition()`
  * `movePosition()`: `moveXPosition()` and `moveYPosition()`


## v1.0.1: 2022-05-16

* Started changelog.
* Changed alignment priority: 1) explicit `align` function arguments, if specified, 2) tab stop `align` fields, if present, 3) the `qp` table's default `align` setting.

