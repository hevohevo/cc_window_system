-- #################################################
-- PockeComputer Windows System in ComputerCraft
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

local function makeEventArray(width,height, initial_value)
  initial_value = initial_value or false
  local tmp = {}
  for h=1,height do
    tmp[h]={}
    for w=1,width do
      tmp[h][w]=initial_value
    end
  end
  return tmp
end

local function ppEventTable(event_table)
  for i,v in ipairs(event_table) do
    for j,v2 in ipairs(v) do
      if v2==false then
        write("f")
      else
        write(1)
      end
    end
    if #event_table ~= i then write("\n") end
  end
end

local function setArray(array, win)
  local xPos, yPos = win.getPosition()
  local width, height = win.getSize()
  for h=yPos,(yPos+height-1) do
    for w=xPos,(xPos+width-1) do
      --write(w)
      array[h][w]=win
    end
    --write("\n")
  end

  return array
end

local function within(arg, array)
  for i,v in ipairs(array) do
    if v==arg then return true end
  end
  return false
end

local function rotateColor(init_color)
  local init_color = init_color or colors.white -- 1
  local next_color = bit.blshift(init_color,1)
  if next_color > colors.black then
    return colors.white
  else
    return next_color
  end
end

-- str2tbl("abc\nd\ne") => ["abc","d","e]
local function str2tbl(str)
  local tmp={}
  for w in string.gmatch(str, "%a+") do
    table.insert(tmp, w)
  end
  return tmp
end

local function rewriteFunctions(window)
  if not window.addText then
    window.addText = function(self, x)
      self.setTextColor(self.textColor)
      self.setBackgroundColor(self.backgroundColor)
      self.setCursorPos(unpack(self.cursorPos))
      self.write(x)
      self.cursorPos = {self.getCursorPos()}
    end
  end
  if not window.setCursorPos_org then
    window.setCursorPos_org = window.setCursorPos
    window.setCursorPos = function(...)
      window.cusorPos = {window.getCursorPos()}
      window.setCursorPos_org(...)
    end
  end
  return window
end

local CcWindowSystem={
}
CcWindowSystem.new = function(_term)
  local obj = {}
  obj.term = _term or term.current()
  obj.windows = {}
  obj.width, obj.height =term.getSize() -- デフォで26x20
  -- EventMapは PCの画素数と同じサイズの配列。対応する座標にwindowクラスがマッピング
  obj.EventMap =makeEventArray(obj.width, obj.height, false)
  -- Windowsを追加。
  obj.createWindow = function(self, term, xPos, yPox, width, height, visible_flag, options)
    options = options or {}
    local win = window.create(term,xPos, yPox, width, height, visible_flag)
    win.backgroundColor = (options.bgc or colors.cyan)
    win.textColor = (options.tc or colors.white)
    win.cursorPos = {win.getCursorPos()}
    win.name= options.name or string.gsub(tostring(win), "table: ", "win")
    win.setBackgroundColor(win.backgroundColor)
    win.setTextColor(win.textColor)
    win = rewriteFunctions(win)
    win.clear()
    obj.windows[win.name]= win
    obj.EventMap = setArray(self.EventMap, win)
    return win
  end
  obj.createButton = function(self, name, xPos, yPox, width, height, fgcolor, bgcolor)
    local btn = window.create(obj.term,xPos, yPox, width, height, true)
    btn.name=name
    btn.setBackgroundColor(bgcolor or colors.blue)
    btn.setTextColor(fgcolor or colors.white)
    btn.init = function(self) self.clear(); self.write(self.name) end
    btn:init()
    self.windows[name]= btn
    self.EventMap = setArray(self.EventMap, btn)
    return btn
  end
  return setmetatable(obj, {__index=PcWindowSystem})
end

term.setCursorPos(1,1)
term.clear()
ccws = CcWindowSystem.new()
local term_width, term_height = term.getSize()
wrapper = ccws:createWindow(term.current(),1,1,term_width, term_height, true, {})
main_win = ccws:createWindow(wrapper, 2,2,16, 16, true, {tc=colors.white, bgc=colors.black})
ctrl_win = ccws:createWindow(wrapper, 19,2,7, 16, true, {tc=colors.white, bgc=colors.black})
msg_win = ccws:createWindow(ctrl_win, 2,2,5, 1, true, {tc=colors.white, bgc=colors.gray})

main_win.setCursorPos(1,1)
wrapper:addText('wrapper1')
main_win:addText('main1')

wrapper.setCursorPos(1,1)
wrapper:addText('wrapper2')
main_win:addText('main2')

wrapper:addText('wrapper3')
main_win:addText('main3')

wrapper:addText('wrapper4')
main_win:addText('main4')

main_win.setCursorPos(1,2)
wrapper:addText(wrapper:setCursorPos())
main_win:addText('main5')

term.setCursorPos(1,18)

--[[
-- define global function
function new(...)
  return PcWindow.new(...)
end

-- 標準の Window APIを拡張。

-- options={textColor=colors.white, backgroundColor=colors.cyan, text="abc"}
exwindow = {}
exwindow.create = function(term, xPos, yPos, width, height, visibility, options)
  options = options or {textColor=colors.white, backgroundColor=colors.cyan, text=""}
  local window = window.create(term, xPos, yPos, width, height, false)
  local backgroundColor = options.backgroundColor or colors.black
  local textColor = options.textColor or colors.white
  local term = term
  local text = options.text
  local setColors = function(tc, bgc)
    window.setTextColor(tc or colors.white)
    window.setBackgroundColor(bgc or colors.black)
  end
  local obj={}
  obj.write = function(self, text)
    setColors(textColor, backgroundColor)
    window.write(text)
    setColors()
  end
  obj.clear = function()
    setColors(textColor, backgroundColor)
    window.clear()
    setColors()
  end
  obj.draw = function()
    setColors(textColor, backgroundColor)
    window.clear()
    window.write(text)
    setColors()
  end
  obj.clearLine = function()
    setColors(textColor, backgroundColor)
    window.clearLine()
    setColors()
  end
  obj.setCursorPos = function(x,y)
    window.setCursorPos(x,y)
  end
  obj.term = term
  obj.window = window

  if visibility then
    window.setVisible(true)
    obj.draw()
  end
  return obj
end


-- button class
exbutton = {}
setmetatable(exbutton, {__index=exwindow})


-- main
term.clear()
term.setCursorPos(1,1)

winopts={textColor=colors.white, backgroundColor=colors.cyan, text="wrapper" }
wrapper = exwindow.create(term.current(), 1, 1, 26,20, true, winopts)

winopts2={textColor=colors.red, backgroundColor=colors.black, text="win1"}
gwin = exwindow.create(wrapper, 2, 2, 16,16, true, winopts2)
--]]
--[[
local disptxt = " 0123456789abcdef"
for y=1,17 do
  wrapper.setCursorPos(1,y)
  wrapper.write(string.sub(disptxt,y, y+1))
end
--]]

--winopts2={textColor=colors.red, backgroundColor=colors.black, text="win1"}
--gwin = exwindow.create(wrapper, 2, 2, 16,16, true, winopts2)

--[[
cwin_opts={textColor=colors.red, backgroundColor=colors.blue, text="ctrl"}
cwin = exwindow.create(wrapper, 18, 2, 8,16, true, cwin_opts)

mwin_opts={textColor=colors.white, backgroundColor=colors.gray, text="msg"}
mwin = exwindow.create(wrapper, 2, 18, 24,3, true, mwin_opts)

quit_btn_opts = {textColor=colors.red, backgroundColor=colors.yellow, text="quit" }
quit_btn = exwindow.create(cwin, 2, 2, 2,1, true, quit_btn_opts)
--]]

