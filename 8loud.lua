-- energy =  0 stay, not to move
-- energy =  1 work, move + 1; energy - 1; if energy = 0 then high -1;
-- energy >= 2 jump, move + 1; high + 1(if possible), energy - 1;


require 'kb'

local write=io.write

GROUND="[]"
SPACE=". "
JUMPER="@@"


function ARRAY2D(w,h)
  local t = {w=w,h=h}
  for y=1,h do
    t[y] = {}
    for x=1,w do
      t[y][x]=0
    end
  end
  return t
end

_CELLS = {}

function _CELLS:move_on(next)
--  for y=1,self.h do
--    table.remove(self[y], 1)
--    table.insert(self[y], #self[y] + 1, next)
--  end

  if self.jumper.e == 0 and self.jumper.y >= 4 then return end
  local ground_line = self.h  -- #self
  table.remove(self[ground_line], 1)
  if self.hole > 0 then
    table.insert(self[ground_line], #self[ground_line] + 1, 0)
    self.hole = self.hole - 1
  else
    table.insert(self[ground_line], #self[ground_line] + 1, 1)
    -- not to place hole as 'hole == 0', then check if it should be placed
    local ground_completeness = 0
    for x=self.w,1,-1 do
      if self[ground_line][x] == 0 then
        break
      end
      ground_completeness = ground_completeness + self[ground_line][x];
    end
    if ground_completeness > 15 then
      self.hole = math.random(1,10)
    end
  end
  if self.jumper.e > 0 then
    self.jumper.e = self.jumper.e - 1
    if self.jumper.y > 1 then
      self.jumper.y = self.jumper.y - 1
    end
  else
    if self.jumper.y < 4 then
      self.jumper.y = self.jumper.y + 1
    end
  end
end

-- output the array to screen
function _CELLS:draw()
  local out="" -- accumulate to reduce flicker
  for y=1,self.h do
    for x=1,self.w do
      if x == self.jumper.x and y == self.jumper.y then
        out=out..JUMPER
      else
        out=out..(((self[y][x]>0) and GROUND) or SPACE)
      end
    end
    out=out.."\n"
  end
  write(out)
end

function _CELLS:energy(en)
  self.jumper.e = en
end

-- constructor
function CELLS(w,h)
  local c = ARRAY2D(w,h)
  c.move_on = _CELLS.move_on
  c.draw = _CELLS.draw
  c.energy = _CELLS.energy
  c.hole = 0
  c.add_hole = _CELLS.add_hole
  c.jumper = {x=2, y=2, e=0}
  return c
end


-- the main routine
function RUN(w,h)
  -- create two arrays
  local screen = CELLS(w,h)

  -- run until break
  write("\027[2J")      -- ANSI clear screen
  while 1 do
    write("\027[2J")      -- ANSI clear screen
    write("\027[H")     -- ANSI home cursor
    screen:draw()
    write("mem ", string.format("%3.1f",collectgarbage('count')), " kB\n")
    write("ARRAY", #screen[1], "\n")
    key = kb.getch()
    if key == 49 then
      break
    elseif key == 50 then
      screen:move_on(1)
    else
      screen:move_on(0)
    end
  end
end

-- RUN(24,5)

game = {}
function game:init(w,h)
  self.playground = CELLS(w,h)
  write("\027[2J")      -- ANSI clear screen
end

function game:step(key)
--  write("\027[2J")      -- ANSI clear screen
  write("\027[H")     -- ANSI home cursor
  self.playground:draw()
  -- write("mem ", string.format("%3.1f",collectgarbage('count')), " kB\n")
  -- write("ARRAY", #self.playground[1], "\n")
  self.playground:move_on(0)
  if not key then return end
  -- if key == 49 then
    self.playground:energy(key - '0')
  -- end
end

-- function sleep(n)
--   if n > 0 then os.execute("ls /dev -1 > /dev/null") end
-- end

function game:run()
  local K = require 'readkey'
  local P = require 'posix'
  local MS = require 'msleep'
--  local socket = require("socket")        -- for sleep(0.1)
  local tty = io.open(P.ctermid(), 'a+')  -- the controlling terminal
  K.ReadMode( 4, tty )                    -- turn off controls keys
  local key
  while true do
    key = K.ReadKey( -1, tty )
    if key == '\027' then break end
    self:step(key)
    -- socket.sleep(0.1)
    -- sleep(1)
    msleep(20)
    -- write("key=", key or 'nil', "\n")
  end
  K.ReadMode( 0, tty )                    -- reset tty mode before exiting
end

game:init(24,5)
game:run()
