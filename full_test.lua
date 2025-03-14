--[[
	A nearly-full* test of all features in QuickPrint.

	The test is divided into two columns. The left column is drawn directly, while the right
	column is added to a LÖVE TextBatch and drawn in one call. The right column eventually stops
	because some tests are not applicable, or are impractical to implement with a TextBatch.

	Test range 1-99: left and right columns
	Test range 100-* left column only

	(*) This is in dire need of a rewrite, with pages separated by topic.
	Missing tests -- see 'test_default_align.lua`
		qp:setDefaultAlign()
		qp:getDefaultAlign()
		qp:setDefaultVAlign()
		qp:getDefaultVAlign()
--]]


-- [UPGRADE] Remove once fully migrated to LÖVE 12.
local love_major, love_minor, love_revision, love_codename = love.getVersion()
local _lg_newText = love_major == 12 and love.graphics.newTextBatch or love.graphics.newText


require("demo_libs.test.strict")
local quickPrint = require("quick_print")

-- Set up LÖVE.
love.window.setTitle("QuickPrint: Full Feature Test")
love.window.updateMode(love.graphics.getWidth(), love.graphics.getHeight(), {resizable = true})
love.keyboard.setKeyRepeat(true)


local scroll_x = 0
local scroll_y = 125

local show_tab_lines_and_ref_w = false

local font1 = love.graphics.newFont(12)
local font1_dupe = love.graphics.newFont(12)
local font2 = love.graphics.newFont(16)
local font3 = love.graphics.newFont(72)
local font3_dupe = love.graphics.newFont(72)

local qp = quickPrint.new()

local demo_show_text_object = true
local demo_scale_div = 16
local demo_scale = demo_scale_div -- demo_scale_div..(demo_scale_div/8)


local C_WHITE = {1, 1, 1, 1}
local C_RED = {1, 0, 0, 1}
local C_GREEN = {0, 1, 0, 1}
local C_BLUE = {0, 0, 1, 1}

local col_txt = {C_WHITE, "Colored ", C_RED, "text ", C_GREEN, "sequence ", C_BLUE, "test."}

local prefab_string_seq = {
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
	"A", "B", "C", "D", "E", "F"
}

local tabs = {}
local tabs_align_test = {x=0, align="right"}


local txt = _lg_newText(font1)


local function drawCursorXLine(qp)
	local rr, gg, bb, aa = love.graphics.getColor()

	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.line(0.5, qp.y + qp.origin_y, love.graphics.getWidth() - 1 + 0.5, qp.y + qp.origin_y)
	love.graphics.setColor(rr, gg, bb, aa)
end


function love.keypressed(kc, sc)
	if sc == "escape" then
		love.event.quit()
		return

	elseif sc == "up" then
		scroll_y = scroll_y + 16

	elseif sc == "pageup" then
		scroll_y = scroll_y + 16*8

	elseif sc == "down" then
		scroll_y = scroll_y - 16

	elseif sc == "pagedown" then
		scroll_y = scroll_y - 16*8

	elseif sc == "left" then
		scroll_x = scroll_x + 16

	elseif sc == "right" then
		scroll_x = scroll_x - 16

	elseif sc == "tab" then
		show_tab_lines_and_ref_w = not show_tab_lines_and_ref_w

	elseif sc == "1" then
		demo_show_text_object = not demo_show_text_object

	elseif sc == "-" then
		demo_scale = math.max(demo_scale_div, demo_scale - 1)

	elseif sc == "=" then
		demo_scale = math.min(demo_scale_div*8, demo_scale + 1)
	end
end


function love.wheelmoved(x, y)
	scroll_y = scroll_y + y*16
end


function love.update(dt)
	local mouse_x = love.mouse.getX()

	-- Continously update tab stops based on mouse position
	tabs[1] = 0
	tabs[2] = math.floor(0.5 + mouse_x / 4)
	tabs[3] = math.floor(0.5 + mouse_x / 3)
	tabs[4] = math.floor(0.5 + mouse_x / 2)
	tabs[5] = math.floor(0.5 + mouse_x)
end


-- The main volley of tests, applicable to both rendering to screen and adding to a Text object.
local function testVolley(qp)

	-- Shared locals
	local pos_x, pos_y
	local orig_x, orig_y

	-- (1.1) qp:setOrigin()
	qp:print("(1.1) qp:setOrigin() (before)")
	pos_x, pos_y = qp:getPosition()
	orig_x, orig_y = qp:getOrigin()

	qp:setOrigin(orig_x + pos_x + 4, orig_y + pos_y + 4)
	qp:print("(1.1) qp:setOrigin() (changed)")

	-- (1.2) qp:getOrigin()
	orig_x, orig_y = qp:getOrigin()
	qp:print("(1.2) qp:getOrigin(): " .. orig_x .. ", " .. orig_y)

	pos_x, pos_y = qp:getPosition()
	qp:setOrigin(0, orig_y + pos_y)

	-- (1.3) qp:setXOrigin()
	qp:print("(1.3) qp:setXOrigin() (@: before, #: after)")
	pos_x, pos_y = qp:getPosition()
	orig_x, orig_y = qp:getOrigin()
	qp:setOrigin(pos_x, orig_y + pos_y)
	qp:write("@")
	qp:setXOrigin(64)
	qp:write("#")
	qp:down()

	-- (1.4) qp:getXOrigin()
	qp:print("(1.4) qp:getXOrigin(): " .. qp:getXOrigin())

	orig_x, orig_y = qp:getOrigin()
	pos_x, pos_y = qp:getPosition()
	qp:setOrigin(0, orig_y + pos_y)

	-- (1.5) qp:setYOrigin()
	qp:print("(1.5) setYOrigin (@: before, #: after)")
	pos_x, pos_y = qp:getPosition()
	orig_x, orig_y = qp:getOrigin()
	qp:write("@")
	qp:setYOrigin(orig_y + pos_y + 32)
	qp:write("#")
	qp:down()

	-- (1.6) qp:getYOrigin()
	qp:print("(1.6) qp:getYOrigin(): " .. qp:getYOrigin())

	orig_x, orig_y = qp:getOrigin()
	pos_x, pos_y = qp:getPosition()
	qp:setOrigin(0, orig_y + pos_y)

	-- (2) moveOrigin
	qp:moveOrigin(0, 32)
	local n_origs = 4
	for i = 1, n_origs do
		qp:moveOrigin(16, 16)
		qp:write("(2) qp:moveOrigin() (x4)")
	end

	orig_x, orig_y = qp:getOrigin()
	pos_x, pos_y = qp:getPosition()
	qp:setOrigin(0, orig_y + pos_y)
	qp:down(n_origs)


	-- (3) qp:getFont()
	local test_font = qp:getFont()
	qp:print("(3) qp:getFont() object:", test_font)

	-- (4.1) qp:setTabs(tabs)
	qp:setTabs(tabs)
	qp:print("(4.1) qp:setTabs() ", "on")
	qp:setTabs()
	qp:print("(4.1) qp:setTabs() ", "off")
	qp:setTabs(tabs)

	-- (4.2) qp:getTabs()
	local get_tabs = qp:getTabs()
	qp:print("(4.2) qp:getTabs(): ")
	qp:printSeq(get_tabs)

	-- (4.3) qp:setTabIndex(), qp:getTabIndex()
	qp:setTabIndex(3)
	qp:print("(4.3) qp:set/setTabIndex(3): ", qp:getTabIndex())

	-- (5.1) qp:setAlign()
	qp:print("(5.1) qp:setAlign()")

	qp:setAlign("left")
	qp:print("left", "left", "left", "left", "left")

	qp:setAlign("center")
	qp:print("center", "center", "center", "center", "center")

	qp:setAlign("right")
	qp:print("right", "right", "right", "right", "right")

	qp:setAlign("justify")
	qp:print("('justify' should be the same as 'left' in plain print calls.)")
	qp:print("justify", "justify", "justify", "justify", "justify")

	-- (5.2) qp:getAlign()
	qp:print("(5.2) qp:getAlign: ", qp:getAlign())

	qp:setAlign("left")

	-- (6) qp:down(qty)
	qp:print("(6) qp:down()")
	qp:down()
	qp:print("(6) qp:down(2)")
	qp:down(2)
	qp:print("(6) qp:down(3)")
	qp:down(3)
	qp:print("____________")

	-- (6.1) qp:up(qty)
	qp:print("(6.1) qp:up() (lines are printed in reverse order)")
	qp:down(5)
	qp:write("Five")
	qp:up()
	qp:write("Four")
	qp:up()
	qp:write("Three")
	qp:up()
	qp:write("Two")
	qp:up()
	qp:write("One")
	qp:up()

	qp:down(7)

	-- (7.1) qp:advanceX(width)
	qp:setTabs()

	qp:write("(7.1) qp:advanceX(48):|")
	qp:advanceX(48)
	qp:write("|")
	qp:down()

	-- (7.2) qp:advanceXStr(str)
	qp:write("(7.2) qp:advanceXStr('This Much'):|")
	qp:advanceXStr("'This Much'")
	qp:write("|")
	qp:down()

	-- (7.3) qp:advanceXCoarse(coarse_x, margin)
	qp:print("(7.3) qp:advanceXCoarse():")
	qp:write("|")
	qp:advanceXCoarse(32, 8)
	qp:write("||")
	qp:advanceXCoarse(32, 8)
	qp:write("|||")
	qp:advanceXCoarse(32, 8)
	qp:write("||||")
	qp:advanceXCoarse(32, 8)
	qp:write("|||||")
	qp:advanceXCoarse(32, 8)
	qp:write("||||||")
	qp:advanceXCoarse(32, 8)
	qp:write("|||||||")
	qp:advanceXCoarse(32, 8)
	qp:write("||||||||")
	qp:advanceXCoarse(32, 8)

	qp:down()

	-- (7.4) qp:setXMin(x_min)
	qp:print("(7.4) qp:setXMin(128) (before, after):")
	qp:write("before")
	qp:setXMin(128)
	qp:write("after")
	qp:setXMin(128)
	qp:write("  < can't go back")

	qp:down()

	qp:setTabs(tabs)
	qp:down()

	-- (7.5) qp:advanceTab()
	qp:write("(7.5) qp:advanceTab()")
	qp:advanceTab()
	qp:write("(View with tabs visible)")
	qp:down()


	-- (8.1) qp:getPosition()
	local pos_x, pos_y = qp:getPosition()
	qp:print("(8.1) qp:getPosition(): " .. pos_x .. ", " .. pos_y)

	-- (8.2) qp:setPosition()
	pos_x, pos_y = qp:getPosition()
	qp:setPosition(pos_x + 4, pos_y + 4)
	qp:print("(8.2) qp:setPosition()")

	qp:setPosition(pos_x, pos_y)
	qp:down(2)

	-- (8.3) qp:setXPosition(x)
	qp:setXPosition(64)
	qp:write("(8.3) qp:setXPosition(64)")
	qp:moveXPosition(32)
	-- (8.4) moveXPosition(dx)
	qp:write("(8.4) qp:moveXPosition(32)")

	qp:down()

	-- (8.5) setYPosition(y)
	qp:setYPosition(qp:getYPosition() + 8)
	qp:write("(8.5) qp:setYPosition(plus 8)")

	-- (8.6) moveYPosition(dy)
	qp:moveYPosition(8)
	qp:write("(8.6) qp:moveYPosition(8)")

	qp:down()

	-- (8.7) qp:getXPosition()
	qp:print("(8.7) qp:getXPosition(): ", qp:getXPosition())

	-- (8.8) qp:getYPosition()
	qp:print("(8.8) qp:getYPosition(): ", qp:getYPosition())

	qp:down()

	-- (8.9) qp:movePosition()
	local n_moves = 18
	pos_x, pos_y = qp:getPosition()
	qp:print("(8.9) qp:movePosition()")
	for i = 1, n_moves do
		qp:movePosition(i^2, 0)
		qp:print("m")
	end

	qp:setPosition(pos_x, pos_y)
	qp:down(n_moves + 2)

	-- (10.1) qp:setScale(sx, sy)
	qp:setScale(2, 2)
	qp:print("(10.1) qp:setScale()")

	-- (10.2) qp:getScale()
	local sx, sy = qp:getScale()
	qp:print("(10.2) qp:getScale(): " .. sx .. ", " .. sy)

	qp:setScale(1, 1)
	qp:print("(back to 1,1)")

	qp:down()

	-- (11.1) qp:setVerticalPadding(pad_v)
	qp:setVerticalPadding(8)
	qp:print("(11.1) qp:setVerticalPadding(8)")
	qp:print("\"Dot dot dot.\"")

	-- (11.2) qp:getVerticalPadding()
	qp:print("(11.2) qp:getVerticalPadding(): " .. qp:getVerticalPadding())

	qp:setVerticalPadding(0)
	qp:print("(Back to zero.)")

	-- (12.1) qp:writeSeq(tbl)
	qp:print("(12.1) qp:writeSeq() (next line)")
	qp:writeSeq(prefab_string_seq)
	qp:down()

	-- (12.2) -- deleted in 1.1.0

	-- (12.3) qp:printSeq(tbl)
	qp:print("(12.3) printSeq (next_line)")
	qp:printSeq(prefab_string_seq)

	-- (12.4) -- deleted in 1.1.0

	-- (13.1) qp:setReferenceDimensions(ref_w, ref_h), qp:getReferenceDimensions()
	qp:print("(13.1) setReferenceDimensions / getReferenceDimensions")
	qp:setReferenceDimensions(love.graphics.getWidth()/2, love.graphics.getHeight())
	local ref_w, ref_h = qp:getReferenceDimensions()
	qp:print("getReferenceDimensions: " .. ref_w .. ", " .. ref_h)

	do
		-- (13.2) getReferenceWidth, setReferenceWidth, getReferenceHeight, setReferenceHeight
		local some_obscene_number = 20000
		qp:print("(13.2) reference width/height get/set, using " .. some_obscene_number)

		qp:setReferenceWidth(some_obscene_number)
		qp:setReferenceHeight(some_obscene_number)

		local rf_w = qp:getReferenceWidth()
		local rf_h = qp:getReferenceHeight()
		qp:print("getReferenceWidth: " .. rf_w)
		qp:print("getReferenceHeight: " .. rf_h)
	end
	qp:setReferenceDimensions(love.graphics.getWidth()/2, love.graphics.getHeight())

	-- (14.1) qp:writefSingle(text, align)
	qp:setTabs()

	qp:print("(14.1) qp:writefSingle(), left, center, right, justify")
	qp:writefSingle("|LEFT|")
	qp:writefSingle("|CENTER|", "center")
	qp:writefSingle("|RIGHT|", "right")
	qp:down()
	qp:writefSingle("j u s t i f y", "justify")

	qp:setTabs(tabs)

	qp:down(2)

	-- (14.2) qp:printfSingle(text, align)
	qp:print("(14.2) qp:printfSingle(), left, center, right, justify")

	qp:setTabs()

	qp:printfSingle("|LEFT|")
	qp:printfSingle("|CENTER|", "center")
	qp:printfSingle("|RIGHT|", "right")
	qp:printfSingle("j u s t i f y", "justify")

	qp:down()

	qp:setTabs(tabs)

	-- (14.3) qp:printf(text, align)
	qp:printf("(14.3) (qp:printf() start)\n...\n...\n(end)")
	qp:print("^ This line should be below the '(end)'")

	-- coloredtext test
	qp:printf(col_txt)

	-- (15) qp:getTextObject()
	qp:print("(15) qp:getTextObject() (TextBatch only): " .. tostring(qp:getTextObject()))
	qp:down()

	-- (16.1) Align override: tab
	-- "bar" has right alignment against the fifth tab, even though qp.align is "left"
	local old_tab5 = tabs[5]
	tabs[5] = tabs_align_test
	tabs_align_test.x = old_tab5
	tabs_align_test.align = "right"

	qp:print("(16.1) Align override: tab", "foo", "foo", "foo", "bar")

	-- (16.2) Align override: qp:writefSingle()
	-- "bar" has center alignment against the fifth tab, even though qp.align is "left" and
	-- the fifth tab contains 'align = "right"'
	qp:writefSingle("(16.2) Align override: qp:writefSingle()")
	qp:down()
	qp:setTabIndex(5)
	qp:writefSingle("bar", "center")
	qp:down()

	tabs[5] = old_tab5

	-- (17.x) Test all vertical align modes.
	-- This also tests 1.0.6 aux_db font metric stand-ins.
	qp:down(3)
	qp:print("(17.1) Vertical align: top, middle, true-middle, baseline, bottom")
	qp:down(3) -- make space
	drawCursorXLine(qp)
	qp:setVAlign("top"); qp:write("M");
	qp:setVAlign("middle"); qp:write("M")
	qp:setVAlign("true-middle"); qp:write("M")
	qp:setVAlign("baseline"); qp:write("M")
	qp:setVAlign("bottom"); qp:write("M")

	qp:down(2)
	qp:setVAlign("top")
	qp:print("(17.2) Now with 2x2y scaling.")
	qp:down(3) -- make space
	qp:setScale(2, 2)
	drawCursorXLine(qp)
	qp:setVAlign("top"); qp:write("M");
	qp:setVAlign("middle"); qp:write("M")
	qp:setVAlign("true-middle"); qp:write("M")
	qp:setVAlign("baseline"); qp:write("M")
	qp:setVAlign("bottom"); qp:write("M")
	qp:setScale(1, 1)

	qp:down(2)
	qp:setVAlign("top")
	qp:print("(17.3) Same, but with formatted print.")
	drawCursorXLine(qp); qp:setVAlign("top"); qp:printf("M_____"); qp:down(2);
	drawCursorXLine(qp); qp:setVAlign("middle"); qp:printf("_M___"); qp:down(2);
	drawCursorXLine(qp); qp:setVAlign("true-middle"); qp:printf("__M__"); qp:down(2);
	drawCursorXLine(qp); qp:setVAlign("baseline"); qp:printf("___M_"); qp:down(2);
	drawCursorXLine(qp); qp:setVAlign("bottom"); qp:printf("____M"); qp:down(2);
	qp:down()
	qp:setVAlign("top")

	love.graphics.setFont(font1)
end


function love.draw()

	love.graphics.scale(demo_scale / demo_scale_div, demo_scale / demo_scale_div)

	-- The following should be covered by existing tests:
	-- qp:reset()
	-- qp:write(...)
	-- qp:print(...)

	love.graphics.setColor(1, 1, 1, 1)

	qp:reset()
	qp:setTabs()
	qp:setOrigin(0, 0)
	qp:setScale(1)

	-- Render tab lines
	if show_tab_lines_and_ref_w then
		love.graphics.push("all")

		love.graphics.setColor(0, 0, 1, 1)
		love.graphics.line(
			scroll_x + qp.ref_w,
			0,
			scroll_x + qp.ref_w,
			love.graphics.getHeight()
		)

		love.graphics.setColor(1, 0, 0, 1)
		for i, stop in ipairs(tabs) do
			love.graphics.line(
				scroll_x + qp.origin_x + stop,
				0,
				scroll_x + qp.origin_x + stop,
				love.graphics.getHeight()
			)
		end

		love.graphics.pop()
	end

	love.graphics.push("all")

	love.graphics.translate(scroll_x, scroll_y)
	love.graphics.setFont(font1)

	qp:setReferenceWidth(love.graphics.getWidth())

	-- Left side: print to framebuffer
	qp:setTabs(tabs)

	testVolley(qp)

	-- (100) Test font changes (unbound)
	qp:down(2)
	qp:print("* N/A, or tests not suitable for Text objects *")
	love.graphics.setFont(font2)
	qp:print("(100) New font")
	qp:print("~~~")
	love.graphics.setFont(font1)

	-- (101.1) qp:clearKerningMemory()
	qp:setTabs()

	qp:print("(101.1) qp:clearKerningMemory()")
	love.graphics.setFont(font3)

	-- These two lines should look the same.
	qp:print("LT")

	qp:write("L") -- v1.1.1: 'qp.line_font' change
	qp:write("T")
	qp:down()

	-- This line should have different glyph placement.
	qp:write("L")
	qp:clearKerningMemory()
	qp:write("T")
	qp:down()
	love.graphics.setFont(font1)

	-- (101.2) Clear kerning on font change
	qp:print("(101.2) Clear kerning on font change")
	love.graphics.setFont(font3)
	qp:write("L")
	love.graphics.setFont(font3_dupe)
	qp:write("T")
	qp:down()
	love.graphics.setFont(font3)

	love.graphics.setFont(font1)

	qp:setTabs(tabs)

	-- (102.x) Test aux_db parameters
	qp:print("(102.1) Test aux_db parameters")
	qp:down()
	qp:print("plain aux.ox, aux.oy")
	-- Grab the current aux table and temporarily overwrite it with one that we will modify.
	local old_aux = quickPrint.getAux(font1)
	local aux = quickPrint.registerFont(font1)

	aux.ox = -5
	love.graphics.setFont(font1_dupe); qp:write("ox = -5: M")
	love.graphics.setFont(font1); qp:write("M")
	aux.ox = 0

	aux.oy = -6
	love.graphics.setFont(font1_dupe); qp:write("oy = -6: M")
	love.graphics.setFont(font1); qp:write("M")
	aux.oy = 0

	qp:down(2)
	love.graphics.setFont(font1)
	qp:print("(102.2) aux.ox, aux.oy should not be affected by aux scaling:")
	aux.sx = 2
	aux.sy = 2
	aux.ox = -5
	love.graphics.setFont(font1_dupe); qp:write("ox = -5: M")
	love.graphics.setFont(font1); qp:write("M")
	aux.ox = 0

	aux.oy = -6
	love.graphics.setFont(font1_dupe); qp:write("oy = -6: M")
	love.graphics.setFont(font1); qp:write("M")
	aux.oy = 0
	aux.sx = 1
	aux.sy = 1

	qp:down(2)
	love.graphics.setFont(font1_dupe)
	qp:print("(102.5) formatted print aux.ox, aux.oy")
	qp:print("\tox=-5, oy= -8 -- a bit up and off the left edge")
	aux.ox = -5
	aux.oy = -8
	love.graphics.setFont(font1); qp:printfSingle("M1")
	aux.sx = 2
	aux.sy = 2
	love.graphics.setFont(font1); qp:printfSingle("M2")
	aux.ox = 0
	aux.oy = 0
	aux.sx = 1
	aux.sy = 1

	-- Restore old aux data settings
	quickPrint.aux_db[font1] = old_aux

	-- Right side: print to LÖVE Text object
	if demo_show_text_object then
		qp:setTextObject(txt)
		qp:setOrigin(0, 0)
		qp:reset()
		txt:clear()
		testVolley(qp)
		love.graphics.draw(txt, math.floor(love.graphics.getWidth() / 2 + 0.5), 0)
		qp:setTextObject()
	end

	love.graphics.pop()

	-- Draw controls.
	qp:setOrigin(0, 0)
	qp:reset()

	love.graphics.origin()

	love.graphics.setColor(0, 0, 0, 0.75)
	-- [UPGRADE] Rectangle needs to be slightly larger for the LÖVE 12 font.
	local rec_h = 100
	if love_major == 12 then
		rec_h = 110
	end

	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), rec_h)
	love.graphics.setColor(1, 1, 1, 1)

	qp:moveOrigin(16, 16)
	qp:reset()
	qp:setTabs()
	qp:print("up/down, left/right, pgup/pgdn: Scroll\t-/=: Zoom\t1: Toggle TextBatch\nTab: show virtual tab stops + ref_w\nSWIPE MOUSE to change tab stop positions\t\t\n\nESCAPE to get outta here")
	qp:moveOrigin(love.graphics.getWidth() - 200, 0)
	qp:print("FPS: ", love.timer.getFPS())
	qp:print("AvgDelta: ", love.timer.getAverageDelta())
end


