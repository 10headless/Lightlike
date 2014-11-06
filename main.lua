require "state_play"

Gamestate = require "lib/gamestate"
require "lib/tablefunc"


function love.load()
	love.math.setRandomSeed( os.time() ); love.math.random(); love.math.random(); love.math.random(); love.math.random();

	Gamestate.registerEvents()
	Gamestate.switch(state_play)
end