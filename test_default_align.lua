-- v1.0.8 test of default align and default vAlign. See comments for expected behavior.

local quickPrint = require("quick_print")
local qp = quickPrint.new()
local tabs = {256}

local font = love.graphics.newFont(16)


function love.keypressed(kc)if kc == "escape" then love.event.quit() end end


local function drawTabLine(tab_t, i) -- assumes all table values are numbers
	local tab_x = tab_t[i]
	if tab_x then
		love.graphics.push("all")
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.line(
			0.5 + tab_x,
			0.5,
			0.5 + tab_x,
			love.graphics.getHeight() + 1
		)
		love.graphics.pop()
	end
end


local function drawCursorXLine(qp)
	love.graphics.push("all")

	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle("rough")

	love.graphics.setColor(0, 0, 1, 1)
	love.graphics.line(0.5, qp.y + qp.origin_y, love.graphics.getWidth() - 1 + 0.5, qp.y + qp.origin_y)

	love.graphics.pop()
end


local first_run = true
function love.update(dt)
	if first_run then
		qp:setDefaultAlign("left")
		print(qp:getDefaultAlign()) -- Should be left

		qp:setDefaultAlign("right")
		print(qp:getDefaultAlign()) -- Should be right

		qp:setDefaultVAlign("top")
		print(qp:getDefaultVAlign()) -- Should be top

		qp:setDefaultVAlign("bottom")
		print(qp:getDefaultVAlign()) -- Should be bottom

		first_run = false
	end
end


function love.draw()
	love.graphics.setFont(font)
	qp:setDefaultAlign("left")
	qp:setDefaultVAlign("top")
	qp:setTabs(tabs)
	qp:setOrigin(0, 64)
	qp:reset()

	qp:setDefaultAlign("center")

	drawTabLine(tabs, 1)

	qp:print("One") -- Should be left
	-- [=[
	qp:reset()
	qp:down(1)

	qp:print("Two") -- Should be center
	qp:setDefaultAlign("right")
	qp:reset()
	qp:down(2)

	qp:print("Three") -- Should be right
	qp:reset()
	qp:down(3)

	qp:setDefaultVAlign("true-middle")
	drawCursorXLine(qp)
	qp:write("A") -- Should be top
	qp:reset()
	qp:down(6)

	qp:write("B") -- Should be true-middle
	drawCursorXLine(qp)
	qp:setDefaultVAlign("baseline")
	qp:reset()
	qp:down(8)

	qp:write("C") -- Should be baseline
	drawCursorXLine(qp)
	qp:reset()
	qp:down(10)
	--]=]

	first_print = false
end
