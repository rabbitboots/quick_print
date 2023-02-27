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
local i_glyphs_437 =
 "☺☻♥♦♣♠•◘○◙♂♀♪♫☼►◄↕‼¶§▬↨↑↓→←∟↔▲▼" ..
" !\"#$%&'()*+,-./0123456789:;<=>?" ..
"@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_" ..
"`abcdefghijklmnopqrstuvwxyz{|}~⌂" ..
"ÇüéâäàåçêëèïîìÄÅÉæÆôöòûùÿÖÜ¢£¥₧ƒ" ..
"áíóúñÑªº¿⌐¬½¼¡«»░▒▓│┤╡╢╖╕╣║╗╝╜╛┐" ..
"└┴┬├─┼╞╟╚╔╩╦╠═╬╧╨╤╥╙╘╒╓╫╪┘┌█▄▌▐▀" ..
"αßΓπΣσµτΦΘΩδ∞φε∩≡±≥≤⌠⌡÷≈°∙·√ⁿ²■"

local font_img_a = love.graphics.newImageFont("demo_fonts/imagefont/term_thick_var.png", i_font_glyphs)
local font_img_b = love.graphics.newImageFont("demo_fonts/imagefont/microtonal_mono.png", i_font_glyphs)
font_img_a:setFilter("nearest", "nearest")
font_img_b:setFilter("nearest", "nearest")


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
	local rr, gg, bb, aa = love.graphics.getColor()

	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.line(0.5, qp.y + qp.origin_y, love.graphics.getWidth() - 1 + 0.5, qp.y + qp.origin_y)
	love.graphics.setColor(rr, gg, bb, aa)
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
	qp:write("Top, middle, baseline, bottom alignment: ")

	qp:setVAlign("top")
	qp:write("M")
	qp:write("M")
	qp:write("M")

	qp:setVAlign("middle")
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
	qp:write("ImageFont top, true-middle, bottom: ")
	qp:setVAlign("top")
	love.graphics.setFont(font_img_a)
	qp:write("M")
	qp:write("M")
	qp:write("M")

	qp:setVAlign("true-middle")
	love.graphics.setFont(font_img_a)
	qp:write("M")
	qp:write("M")
	qp:write("M")

	qp:setVAlign("bottom")
	love.graphics.setFont(font_img_a)
	qp:write("M")
	qp:write("M")
	qp:write("M")

	qp:down(3*3)
	drawCursorXLine(qp)

	love.graphics.setFont(font_ttf_a)
	qp:write("ImageFont baseline workaround: ")
	--[[
	ImageFonts only have height as a valid vertical metric. As a workaround, you can temporarily offset
	the cursor Y position (mind the scaling), draw your ImageFont text, then restore the cursor Y.
	This font (term_thick) has a baseline of... let's say 8.
	--]]

	qp:setVAlign("baseline")
	love.graphics.setFont(font_ttf_a)
	qp:write("M")
	qp:write("M")
	qp:write("M")
	
	local img_baseline = 8
	local img_scale = 3
	love.graphics.setFont(font_img_a)
	qp:setScale(img_scale, img_scale)
	qp:moveYPosition(-img_baseline * img_scale)
	qp:setVAlign("top")

	qp:write("M")
	qp:write("M")
	qp:write("M")

	qp:moveYPosition(img_baseline * img_scale)
	qp:setScale(1, 1)
	qp:setVAlign("baseline")
	love.graphics.setFont(font_ttf_a)
	qp:write("M")
	qp:write("M")
	qp:write("M")

	qp:down(3)
	qp:setVAlign("true-middle")


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

