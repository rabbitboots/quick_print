--[[
	QuickPrint Demo for printed range memory.
--]]

require("demo_libs.test.strict")
local quickPrint = require("quick_print")

-- Set up LÖVE.
love.window.setTitle("QuickPrint Demo (Printed Ranges)")
love.window.updateMode(love.graphics.getWidth(), love.graphics.getHeight(), {resizable = true})
--love.keyboard.setKeyRepeat(true)


local main_font = love.graphics.newFont(16)
main_font:setLineHeight(1.5)
love.graphics.setFont(main_font)


local love_major, love_minor = love.getVersion()

local qp = quickPrint.new()
local text_obj = love.graphics[love_major >= 12 and "newTextBatch" or "newText"](main_font)
qp:setTextObject(text_obj)


local demo_phaser = 0.0


function love.keypressed(kc, sc)
	if sc == "escape" then
		love.event.quit()
	end
end


function love.update(dt)
	demo_phaser = (demo_phaser + dt * 2.5) % math.pi
end


local demo_message = [[
The rectangle shows the result of 'qp:getPrintedRange()' after having
printed a few lines of text. The cursor is just a 2D point, so you should
move the cursor down one line to capture the full height of the text.
(This is done automatically at the end of calls to 'qp:print()'.)
]]


function love.draw()
	love.graphics.setFont(main_font)

	local PAD = 32
	qp:setOrigin(PAD, PAD)
	qp:setReferenceDimensions(love.graphics.getWidth() - PAD*2, love.graphics.getHeight() - PAD*2)

	qp:reset()
	qp.text_object:clear()

	qp:print("Ammo is cyan")
	qp:print("Abundant no more")
	qp:print("Suddenly, lions!")
	qp:print("Time to restore")

	local c = math.abs(math.sin(demo_phaser))

	--love.graphics.translate(PAD, PAD)
	love.graphics.setColor(c, c, c, 1.0)
	local x1, y1, x2, y2 = qp:getPrintedRange()
	love.graphics.rectangle("line", PAD + x1, PAD + y1, x2 - x1, y2 - y1)

	love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
	love.graphics.draw(qp.text_object)

	love.graphics.print(demo_message, PAD, math.floor(love.graphics.getHeight() / 2)
	)
end

