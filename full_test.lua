--[[
	A full test of all features in QuickPrint.

	TODO: This is a few things short of being a true full test.
	* Missing align overrides, I think (qp align vs tab align vs function align?)
	* I added some more getters while prepping the Git repository.
--]]

--[[
	BUGS:
	#1: Text:addf() crashes in 11.4 if given a very small wraplimit value. Fixed in LÖVE 12.
--]]

require("demo_libs.test.strict")
local quickPrint = require("quick_print")

-- Set up LÖVE.
love.window.setTitle("QuickPrint: Full Feature Test")
love.window.updateMode(love.graphics.getWidth(), love.graphics.getHeight(), {resizable = true})
love.keyboard.setKeyRepeat(true)


-- This would prevent Bug #1 in the specific case of this test/demo.
--love.window.updateMode(love.graphics.getWidth(), love.graphics.getHeight(), {minwidth=64})


local scroll_x = 0
local scroll_y = 125

local show_tab_lines = false

local font1 = love.graphics.newFont(12)
local font2 = love.graphics.newFont(16)
local font3 = love.graphics.newFont(72)

local qp = quickPrint.new()

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

local txt = love.graphics.newText(font1)


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
	
	elseif sc == "tab" then
		show_tab_lines = not show_tab_lines
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
	-- (1) qp:getFont()
	local test_font = qp:getFont()
	qp:print("(1) getFont object:", test_font)
	
	-- (3) qp:setTabs(tabs)
	qp:setTabs(tabs)
	qp:print("(3) Tabs ", "on")
	qp:setTabs()
	qp:print("(3) Tabs ", "off")
	qp:setTabs(tabs)
	
	-- (4) qp:getTabs()
	local get_tabs = qp:getTabs()
	qp:print("(4) getTabs: ")
	qp:printSeq(get_tabs)
	
	-- (5) qp:setAlign()
	qp:print("(5) setAlign()")
	
	qp:setAlign("left")
	qp:print("left", "left", "left", "left", "left")
	
	qp:setAlign("center")
	qp:print("center", "center", "center", "center", "center")
	
	qp:setAlign("right")
	qp:print("right", "right", "right", "right", "right")
	
	qp:setAlign("justify")
	qp:print("('justify' should be the same as 'left' in plain print calls.)")
	qp:print("justify", "justify", "justify", "justify", "justify")
	
	-- (6) qp:getAlign()
	qp:print("(6) getAlign: ", qp:getAlign())
	
	qp:setAlign("left")
	
	-- (7) qp:down(qty)
	qp:print("(7) down()")
	qp:down()
	qp:print("(7) down(2)")
	qp:down(2)
	qp:print("(7) down(3)")
	qp:down(3)
	qp:print("____________")
	
	-- (8) qp:advanceX(width)
	qp:setTabs()
	
	qp:write("(8) advanceX(48):|")
	qp:advanceX(48)
	qp:write("|")
	qp:down()

	-- CHANGE: 1.0.2: advanceX() was split into advanceX() and advanceXStr().
	-- (8.5a) qp:advanceXStr(str)
	qp:write("(8.5a) advanceXStr('This Much'):|")
	qp:advanceXStr("'This Much'")
	qp:write("|")
	qp:down()

	-- CHANGE: 1.0.2: Added advanceXCoarse(), setXMin()
	-- (8.5b) qp:advanceXCoarse(coarse_x, margin)
	qp:print("(8.5b) advanceXCoarse(32, 16):")
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

	-- (8.5c) qp:setXMin(x_min)
	qp:print("(8.5c) setXMin(128) (before, after):")
	qp:write("before")
	qp:setXMin(128)
	qp:write("after")
	qp:setXMin(128)
	qp:write("  < can't go back")

	qp:down()

	qp:setTabs(tabs)
	qp:down()

	-- (9) qp:advanceTab()
	qp:write("(9) advanceTab")
	qp:advanceTab()
	qp:write("(View with tabs visible)")
	qp:down()


	-- (10) qp:getPosition()
	local pos_x, pos_y = qp:getPosition()
	qp:print("(10) getPosition: " .. pos_x .. ", " .. pos_y)

	-- (11) qp:setPosition()
	pos_x, pos_y = qp:getPosition()
	qp:setPosition(pos_x + 4, pos_y + 4)
	qp:print("(11) setPosition")

	qp:setPosition(pos_x, pos_y)
	qp:down(2)

	-- CHANGE: 1.0.2: setPosition(), getPosition() and movePosition() have single-axis variants.
	-- (11.5a) setXPosition(x)
	qp:setXPosition(64)
	qp:write("(11.5a) setXPosition(64)")
	qp:moveXPosition(32)
	-- (11.5b) moveXPosition(dx)
	qp:write("(11.5b) moveXPosition(32)")

	qp:down()
	
	-- (11.5c) setYPosition(y)
	qp:setYPosition(qp:getYPosition() + 8)
	qp:write("(11.5c) qp:setYPosition(plus 8)")

	-- (11.5d) moveYPosition(dy)
	qp:moveYPosition(8)
	qp:write("(11.5d) moveYPosition(8)")

	qp:down()

	-- (11.5e) qp:getXPosition()
	qp:print("(11.5e) getXPosition: ", qp:getXPosition())
	
	qp:down()

	-- (12) qp:movePosition()
	local n_moves = 18
	pos_x, pos_y = qp:getPosition()
	qp:print("(12) movePosition")
	for i = 1, n_moves do
		qp:movePosition(i^2, 0)
		qp:print("m")
	end
	
	qp:setPosition(pos_x, pos_y)
	qp:down(n_moves + 2)
	
	-- (13) qp:setOrigin()
	qp:print("(13) setOrigin (before)")
	
	pos_x, pos_y = qp:getPosition()
	
	qp:setOrigin(pos_x + 4, pos_y + 4)
	qp:print("(13) setOrigin (changed)")
	
	local orig_x, orig_y = qp:getOrigin()
	qp:print("(14) getOrigin: " .. orig_x .. ", " .. orig_y)
	
	-- (15) moveOrigin
	qp:moveOrigin(0, 32)
	local n_origs = 4
	for i = 1, n_origs do
		qp:moveOrigin(16, 16)
		qp:write("(15) moveOrigin")
	end
	
	qp:setOrigin(0, 0)
	qp:setPosition(pos_x, pos_y)
	qp:down(n_origs + 5)
	
	-- (16) qp:setScale(sx, sy)
	qp:setScale(2, 2)
	qp:print("(16) setScale")
	
	-- (17) qp:getScale()
	local sx, sy = qp:getScale()
	qp:print("(17) getScale: " .. sx .. ", " .. sy)
	
	qp:setScale(1, 1)
	qp:print("(back to 1,1)")
	
	qp:down()
	
	-- (18) qp:setVerticalPadding(pad_v)
	qp:setVerticalPadding(8)
	qp:print("(18) setVerticalPadding to 8")
	qp:print("\"Dot dot dot.\"")
	
	-- (19) qp:getVerticalPadding()
	qp:print("(19) getVerticalPadding: " .. qp:getVerticalPadding())
	
	qp:setVerticalPadding(0)
	qp:print("(Back to zero.)")
	
	-- (21) qp:writeSeq(tbl)
	qp:print("(21) writeSeq (next line)")
	qp:writeSeq(prefab_string_seq)
	qp:down()
	
	-- (22) qp:write1..4()
	qp:print("(22) write1..4 (next lines)")
	qp:write1("write1", "dropped")
	qp:down()
	
	qp:write2("write1", "write2", "dropped")
	qp:down()
	
	qp:write3("write1", "write2", "write3", "dropped")
	qp:down()
	
	qp:write4("write1", "write2", "write3", "write4", "dropped")
	
	qp:down()
	
	-- (23) qp:printSeq(tbl)
	qp:print("(23) printSeq (next_line)")
	qp:printSeq(prefab_string_seq)
	
	-- (24) qp:print1..4()
	qp:print("(24) print1..4 (next lines)")
	
	qp:print1("print1", "dropped")
	qp:print2("print1", "print2", "dropped")
	qp:print3("print1", "print2", "print3", "dropped")
	qp:print4("print1", "print2", "print3", "print4", "dropped")

	-- (25) (26) qp:setReferenceDimensions(ref_w, ref_h)
	qp:print("(25) (26) setReferenceDimensions / getReferenceDimensions")
	qp:setReferenceDimensions(love.graphics.getWidth()/2, love.graphics.getHeight())
	local ref_w, ref_h = qp:getReferenceDimensions()
	qp:print("getReferenceDimensions: " .. ref_w .. ", " .. ref_h)
	
	-- (25) qp:writefSingle(text, align)
	qp:setTabs()
	
	qp:print("(25) writefSingle, left, center, right, justify")
	qp:writefSingle("|LEFT|")
	qp:writefSingle("|CENTER|", "center")
	qp:writefSingle("|RIGHT|", "right")
	qp:down()
	qp:writefSingle("j u s t i f y", "justify")
	
	qp:setTabs(tabs)
	
	qp:down(2)
	
	-- (26) qp:printfSingle(text, align)
	qp:print("(26) printfSingle, left, center, right, justify")
	
	qp:setTabs()
	
	qp:printfSingle("|LEFT|")
	qp:printfSingle("|CENTER|", "center")
	qp:printfSingle("|RIGHT|", "right")
	qp:printfSingle("j u s t i f y", "justify")
	
	qp:down()
	
	qp:setTabs(tabs)
	
	-- (27) qp:printf(text, align)
	qp:printf("(27) (printf start)\n...\n...\n(end)")
	qp:print("^ This line should be below the '(end)'")
	
	-- coloredtext test
	qp:printf(col_txt)
	
	-- (28) get/set ref w/h
	do
		local some_obscene_number = 20000
		qp:print("(28) reference width/height get/set, using " .. some_obscene_number)
		
		qp:setReferenceWidth(some_obscene_number)
		qp:setReferenceHeight(some_obscene_number)
		
		local rf_w = qp:getReferenceWidth()
		local rf_h = qp:getReferenceHeight()
		qp:print("getReferenceWidth: " .. rf_w)
		qp:print("getReferenceHeight: " .. rf_h)
	end
end


function love.draw()
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
	if show_tab_lines then
		love.graphics.push("all")
		
		love.graphics.setColor(1, 0, 0, 1)
		for i, stop in ipairs(tabs) do
			love.graphics.line(qp.origin_x + stop, 0, qp.origin_x + stop, love.graphics.getHeight())
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
	
	-- Test font changes (unbinded)
	qp:down(2)
	qp:print("* N/A, or tests not suitable for Text objects *")
	love.graphics.setFont(font2)
	qp:print("New font")
	qp:print("~~~")
	love.graphics.setFont(font1)
	
	-- (20) qp:clearKerningMemory()
	qp:setTabs()
	
	qp:print("(20) clearKerningMemory")
	love.graphics.setFont(font3)
	qp:print("LT")

	qp:write("L")
	qp:clearKerningMemory()
	qp:write("T")
	qp:down()
	
	love.graphics.setFont(font1)
	
	qp:setTabs(tabs)

	-- Right side: print to LÖVE Text object
	-- (2) qp:setTextObject(text_object)
	qp:setTextObject(txt)
	qp:reset()
	txt:clear()
	testVolley(qp)
	love.graphics.draw(txt, love.graphics.getWidth() / 2, 0)
	qp:setTextObject()

	love.graphics.pop()
	
	love.graphics.setColor(0, 0, 0, 0.75)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 100)
	love.graphics.setColor(1, 1, 1, 1)
	
	qp:moveOrigin(16, 16)
	qp:reset()
	qp:setTabs()
	qp:print("up/down, pgup/pgdn: Scroll\t\tLEFT is printed to screen, RIGHT is added to LÖVE Text Object\n\nSWIPE MOUSE to change tab stop positions\t\tTAB to show virtual tab stops\n\nESCAPE to get outta here")
	qp:moveOrigin(love.graphics.getWidth() - 200, 0)
	qp:print("FPS: ", love.timer.getFPS())
	qp:print("AvgDelta: ", love.timer.getAverageDelta())
end


