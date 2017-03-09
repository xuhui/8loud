local K = require 'readkey'
local P = require 'posix'
local socket = require("socket")        -- for sleep(0.1)
local tty = io.open(P.ctermid(), 'a+')  -- the controlling terminal
K.ReadMode( 4, tty )                    -- turn off controls keys
local key
while true do
     key = K.ReadKey( -1, tty )
     if key == '1' or key == '\027' then break end
     print "gaming"                     -- game loop here
     socket.sleep(0.1)
end
print("You pressed key: "..key)
K.ReadMode( 0, tty )                    -- reset tty mode before exiting
