--[[
	A test of methods added to v1.0.3:

	qp:setXOrigin()
	qp:setYOrigin()
	qp:getXOrigin()
	qp:getYOrigin()
--]]

require("demo_libs.test.strict")
local quickPrint = require("quick_print")

-- Set up LÖVE.
love.window.setTitle("QuickPrint Test: v1.0.3")
love.window.updateMode(love.graphics.getWidth(), love.graphics.getHeight(), {resizable = true})
love.keyboard.setKeyRepeat(true)

love.graphics.setFont(love.graphics.newFont(16))

local qp = quickPrint.new()


local err_t = {}
err_t[1] = function(qp)
	print("Type check setXOrigin")
	qp:setXOrigin("wrong type")
end


err_t[2] = function(qp)
	print("Type check setYOrigin")
	qp:setYOrigin("wrong type")
end


function love.keypressed(kc, sc)
	local n = tonumber(sc)

	if sc == "escape" then
		love.event.quit()
		return

	elseif n and n >= 1 and n <= #err_t then
		if err_t[n] then
			err_t[n](qp)
		end
	end
end


function love.draw()
	love.graphics.setColor(1, 1, 1, 1)

	qp:reset()
	qp:setOrigin(64, 64)

	do
		local ox, oy = qp:getOrigin() -- should say 64, 64
		qp:print("getOrigin: ", ox, ", ", oy)
	end

	-- (1) qp:getXOrigin()
	do
		local ox = qp:getXOrigin()
		qp:print("(1) getXOrigin: ", ox) -- should say 64
	end

	-- (2) qp:getYOrigin()
	do
		local oy = qp:getYOrigin()
		qp:print("(2) getYOrigin: ", oy) -- should say 64
	end

	-- (3) qp:setXOrigin()
	do
		qp:setXOrigin(256)
		local ox = qp:getXOrigin()
		qp:print("(3) setXOrigin: ", ox) -- should say 256
	end
	-- (4) qp:setYOrigin()
	do
		qp:setYOrigin(128)
		local oy = qp:getYOrigin()
		qp:print("(4) setYOrigin: ", oy) -- should say 128
	end

	do
		qp:down(4)
		local ox, oy = qp:getOrigin()
		qp:print("Final origin: ", ox, ", ", oy) -- should say 256, 128
	end

	qp:setOrigin(16, love.graphics.getHeight() - 64)
	qp:print("Press [1-2] to test assertion failures.")
	qp:print("Press ESCAPE to quit!")
end


