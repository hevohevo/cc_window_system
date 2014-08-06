-- #################################################
-- Windows System for Pocket Computer in ComputerCraft
-- version 0.1
-- http://hevohevo.hatenablog.com/


-- 標準 Window APIの仕様をメモ。http://computercraft.info/wiki/Term_(API) 　より
-- window.create(親term, xPos, yPos, width, height, visible_flag)
-- ex.
-- local win = window.create(term.current(), 1, 1, 20, 10, true)
-- win.write(text)
-- win.clear()
-- win.clearLine()
-- win.getCursorPos()
-- win.setCursorPos()
-- win.setCurosorBlink()
-- win.isColor()
-- win.getSize()
-- win.scroll()
-- win.setTextColor()
-- win.setBackgroundColor()
-- win.setVisible( boolean_visivility )
-- win.redraw()
-- win.restoreCursor()
-- win.getPosition()
-- win.reposition(xPox, yPox, optional_with, optional_height)

local ExtWindow = {}
-- class private variables
ExtWindow.Term = term.current()
ExtWindow.TermTextColor = colors.white
ExtWindow.TermBackgroundColor = colors.black
ExtWindow.TermCursorPosX, ExtWindow.TermCursorPosY = term.getCursorPos()

-- class private methods
ExtWindow.new = function(self, parent_term, x, y, width, height, visibility, options)
  local parent = term.current()
  if term.current() ~= parent_term then
    parent = parent_term.window
  end
  options = options or {}
  local window = window.create(parent, x, y, width, height, false, options)
  local cursorPosX, curosrPosY = window.getCursorPos()  -- relative pos by a parent window
  local backgroundColor = options.backgroundColor or colors.cyan
  local textColor = options.textColor or colors.white
  local doBlink = true

  -- public instance (methods|variable)
  local obj = {}
  obj.window=window
  obj.write = function(self, text)
    obj:setCursorPos(cursorPosX, curosrPosY)
    obj:setTextColor(textColor)
    obj:setBackgroundColor(backgroundColor)
    window.write(text)
    cursorPosX, curosrPosY = obj:getCursorPos()
  end
  obj.clear = function()
    obj:setCursorPos(cursorPosX, curosrPosY)
    obj:setTextColor(textColor)
    obj:setBackgroundColor(backgroundColor)
    window.clear()
  end
  obj.clearLine = function() window.clearLine() end
  obj.redraw = function()
    cursorPosX, curosrPosY = 1,1
    obj:setCursorPos(cursorPosX, curosrPosY)
    obj:setTextColor(textColor)
    obj:setBackgroundColor(backgroundColor)
    window.redraw()
  end
  obj.getCursorPos = function() return window.getCursorPos() end
  obj.setCursorPos = function(self, x, y)
    window.setCursorPos(x,y);
    cursorPosX, curosrPosY = x,y end
  obj.setCursorBlink = function(self, b) window.setCursorBlink(b); doBlink=b end
  obj.setTextColor = function(self, color)
    print(color)
    window.setTextColor(color); textColor=color end
  obj.getTextColor = function() return textColor end
  obj.setBackgroundColor = function(self, color)
    window.setBackgroundColor(color); backgroundColor=color end
  obj.getBackgroundColor = function() return backgroundColor end
  obj.setVisible = function(self, v) window.setVisible(v); visibility = v end
  obj.isColor = function() return window.isColor() end
  obj.getSize = function() return window.getSize() end
  obj.getPosition = function() return window.getPosition() end
  obj.scroll = function() window.scroll() end
  obj.restoreCursor = function() window.restoreCursor() end
  obj.reposition= function(self, x, y, width, height) window.reposition(x,y,width,height) end

  if visibility then
    obj:setVisible(true)
    obj:clear()
  end
  return setmetatable(obj, {__index=ExtWindow})
end



-- public
PocketWinSys={}
PocketWinSys.new = function()

end




PocketWinSys.create = function(...)
  return ExtWindow.new(...)
end



-- Sample code
local function ppt(tbl) for k,v in pairs(tbl) do print(k) end end

term.clear()
term.setCursorPos(1,1)

local twidth, theight = term.getSize()
local wrapper_opt = {backgroundColor=colors.cyan, textColor=colors.white, text="aaa"}
local wrapper = PocketWinSys:create(term.current(), 1, 1, twidth, theight, true, wrapper_opt)
local main_opt = {backgroundColor=colors.black, textColor=colors.white, text="aaa"}
local main_win = PocketWinSys:create(wrapper, 2, 2, 16, 16, true, main_opt)
local ctrl_opt = {backgroundColor=colors.blue, textColor=colors.gray, text="aaa" }
local ctrl_win = PocketWinSys:create(wrapper, 19, 2, 7, 16, true, ctrl_opt)
local msg_opt = {backgroundColor=colors.black, textColor=colors.red, text="aaa"}
local msg_win =  PocketWinSys:create(wrapper, 1, 19, 26, 2, true, msg_opt)
wrapper:write(' 0123456789abcdef')
msg_win:write('msg')
ctrl_win:write('ctrl')
main_win:write("main")
ctrl_win:write('ctrl')
msg_win:write('msg')
ctrl_win:write('ctrl')

term.setCursorPos(10,10)
--wrapper:write('1234566789990')
--print(wrapper.getTextColor() == colors.white)
--print(wrapper.getBackgroundColor()==colors.cyan)
--print(wrapper.getCursorPos())
--ppt(pcws)
while true do
  os.sleep(20)
end