--[[
	QuickPrint Vertical Alignment Demo
--]]


require("demo_libs.test.strict")
local quickPrint = require("quick_print")


-- Set up LÖVE.
love.window.setTitle("QuickPrint Vertical Alignment Demo")
love.window.updateMode(love.graphics.getWidth(), love.graphics.getHeight(), {resizable = true})
love.keyboard.setKeyRepeat(true)

-- Grab a copy of LÖVE's built-in font.
local _default_font = love.graphics.getFont()


-- Make the QuickPrint state table.
local qp = quickPrint.new(love.graphics.getWidth() - 32, 4)


-- Set up some fonts with different sizes.

local font_ttf_a = love.graphics.newFont("demo_fonts/ttf/DejaVu_Mono/dejavu_mono.ttf", 16)
local font_ttf_b = love.graphics.newFont("demo_fonts/ttf/DejaVu_Mono/dejavu_mono.ttf", 24)


-- ImageFont metadata
local i_font_glyphs = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"

local font_img_a = love.graphics.newImageFont("demo_fonts/imagefont/term_thick_var.png", i_font_glyphs)
local font_img_b = love.graphics.newImageFont("demo_fonts/imagefont/microtonal_mono.png", i_font_glyphs)
font_img_a:setFilter("nearest", "nearest")
font_img_b:setFilter("nearest", "nearest")

-- Set up auxiliary data for ImageFonts.
do
	local aux
	aux = quickPrint.registerFont(font_img_a)
	aux.ascent = 8
	aux.descent = 2
	aux.baseline = 8
	aux.sx = 2
	aux.sy = 2

	aux = quickPrint.registerFont(font_img_b)
	aux.ascent = 6
	aux.descent = 0
	aux.baseline = 6
	aux.sx = 2
	aux.sy = 2
end


function love.keypressed(kc, sc)
	-- Quit the demo
	if sc == "escape" then
		love.event.quit()
		return
	end
end


function love.update(dt)
	
end


local function drawCursorXLine(qp)
	love.graphics.push("all")

	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle("rough")

	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.line(0.5, qp.y + qp.origin_y, love.graphics.getWidth() - 1 + 0.5, qp.y + qp.origin_y)

	love.graphics.pop()
end


function love.draw()
	love.graphics.push("all")

	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setFont(font_ttf_a)

	qp:setOrigin(32, 64)
	qp:reset()
	qp:setScale(1, 1)

	--qp:setScale()

	drawCursorXLine(qp)
	qp:write("Top, middle, true-middle, baseline, bottom alignment: ")

	qp:setVAlign("top")
	qp:write("M")
	qp:write("M")
	qp:write("M")

	qp:setVAlign("middle")
	qp:write("M")
	qp:write("M")
	qp:write("M")

	qp:setVAlign("true-middle")
	qp:write("M")
	qp:write("M")
	qp:write("M")

	qp:setVAlign("baseline")
	qp:write("M")
	qp:write("M")
	qp:write("M")

	qp:setVAlign("bottom")
	qp:write("M")
	qp:write("M")
	qp:write("M")

	qp:down(3)

	qp:setVAlign("baseline")
	drawCursorXLine(qp)

	qp:write("Mixed fonts with baseline alignment: ")

	love.graphics.setFont(font_ttf_a)
	qp:write("M")
	qp:write("M")
	qp:write("M")

	love.graphics.setFont(font_ttf_b)
	qp:write("M")
	qp:write("M")
	qp:write("M")

	love.graphics.setFont(font_ttf_a)
	qp:write("M")
	qp:write("M")
	qp:write("M")

	qp:down(3)
	drawCursorXLine(qp)

	love.graphics.setFont(font_ttf_a)
	qp:write("ImageFont top, middle, true-middle, baseline, bottom: ")
	love.graphics.setFont(font_img_a)

	qp:setVAlign("top")
	qp:write("M")

	qp:setVAlign("middle")
	qp:write("M")

	qp:setVAlign("true-middle")
	qp:write("M")

	qp:setVAlign("baseline")
	qp:write("M")

	qp:setVAlign("bottom")
	qp:write("M")

	qp:down(3*3)
	drawCursorXLine(qp)

	love.graphics.setFont(font_ttf_a)
	qp:write("ImageFont + aux_db integration: ")

	qp:setVAlign("baseline")
	love.graphics.setFont(font_ttf_a)
	qp:write("M")
	qp:write("M")
	qp:write("M ")
	
	love.graphics.setFont(font_img_a)
	qp:setVAlign("top")
	qp:write("M")
	qp:setVAlign("middle")
	qp:write("M")
	qp:setVAlign("true-middle")
	qp:write("M")
	qp:setVAlign("baseline")
	qp:write("M")
	qp:setVAlign("bottom")
	qp:write("M")

	love.graphics.setFont(font_img_b)
	qp:setVAlign("top")
	qp:write("M")
	qp:setVAlign("middle")
	qp:write("M")
	qp:setVAlign("true-middle")
	qp:write("M")
	qp:setVAlign("baseline")
	qp:write("M")
	qp:setVAlign("bottom")
	qp:write("M")

	love.graphics.setFont(font_ttf_a)
	qp:write(" M")
	qp:write("M")
	qp:write("M")

	qp:down(3)
	qp:setVAlign("top")

	love.graphics.setFont(_default_font)
	local v_sep = love.graphics.getHeight() - math.ceil(_default_font:getHeight() * qp.sy) - 64

	local rr, gg, bb, aa = love.graphics.getColor()
	love.graphics.setColor(0, 0, 0, 4/5)
	love.graphics.rectangle("fill", 0, v_sep, love.graphics.getWidth(), love.graphics.getHeight() - v_sep)
	love.graphics.setColor(rr, gg, bb, aa)

	qp:setOrigin(16, v_sep + 32)
	qp:setTabs()

	qp:print("Press escape to quit!")

	love.graphics.pop()
end

