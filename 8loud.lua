-- energy =  0 stay, not to move
-- energy =  1 work, move + 1; energy - 1; if energy = 0 then high -1;
-- energy >= 2 jump, move + 1; high + 1(if possible), energy - 1;


require 'kb'

local write=io.write

GROUND="[]"
SPACE="--"
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
  local ground_line = self.h  -- #self
  table.remove(self[ground_line], 1)
  if self.hole > 0 then
    table.insert(self[ground_line], #self[ground_line] + 1, 0)
    self.hole = self.hole - 1
  else
    table.insert(self[ground_line], #self[ground_line] + 1, 1)
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

-- constructor
function CELLS(w,h)
  local c = ARRAY2D(w,h)
  c.move_on = _CELLS.move_on
  c.draw = _CELLS.draw
  c.hole = 0
  c.add_hole = _CELLS.add_hole
  c.jumper = {x=2, y=2}
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


