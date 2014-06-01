-- SETTINGS
BLINKY_PLANT_INTERVAL = 3
NEW_STYLE_WIRES  = true  	-- true = new nodebox wires, false = old raillike wires
PRESSURE_PLATE_INTERVAL = 0.1
OBJECT_DETECTOR_RADIUS = 6
PISTON_MAXIMUM_PUSH = 15
MOVESTONE_MAXIMUM_PUSH = 100
MESECONS_RESUMETIME = 4		-- time to wait when starting the server before
				-- processing the ActionQueue, don't set this too low
OVERHEAT_MAX = 20		-- maximum heat of any component that directly sends an output
				-- signal when the input changes (e.g. luacontroller, gates)
				-- Unit: actions per second, checks are every 1 second
STACK_SIZE = 3000		-- Recursive functions will abort when this is reached. Therefore,
				-- this is also limits the maximum circuit size.
