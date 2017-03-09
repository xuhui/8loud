
require 'kb'

local write=io.write

LIGHT_ON="[]"
LIGHT_OFF="--"

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

-- run the CA and produce the next generation
function _CELLS:move_on(next)
  for y=1,self.h do
    table.remove(self[y], 1)
    table.insert(self[y], #self[y] + 1, next)
  end
end

-- output the array to screen
function _CELLS:draw()
  local out="" -- accumulate to reduce flicker
  for y=1,self.h do
   for x=1,self.w do
      out=out..(((self[y][x]>0) and LIGHT_ON) or LIGHT_OFF)
    end
    out=out.."\n"
  end
  write(out)
end

-- constructor
function CELLS(w,h)
  local c = ARRAY2D(w,h)
  c.move_on = _CELLS.move_on
  c.draw = _CELLS.draw
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

RUN(24,5)


