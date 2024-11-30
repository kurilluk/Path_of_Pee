extends Node2D

# Node references
@onready var groundTiles: TileMapLayer = $GroundTiles
@onready var obstacleTiles: TileMapLayer = $ObstacleTiles
@onready var itemsTiles: TileMapLayer = $ItemTiles
@onready var shadowsTiles: TileMapLayer = $ShadowTiles
@onready var playerTiles: TileMapLayer = $PlayerTiles


# Randomizer & Dimension values ( make sure width & height is uneven)
const initial_width = 31 
const initial_height = 31
var map_width = initial_width
var map_height = initial_height 
var map_offset = 4 #Shifts map four rows down for UI
var rng = RandomNumberGenerator.new()

# Tilemap constants
const BACKGROUND_TILE_ID = 0
const BREAKABLE_TILE_ID = 1
const UNREAKABLE_TILE_ID = 2

const PLAYER_TILE_ID = 14

# Shadow direction, N - North/Up, E - East/Right etc
enum Direction { N, NE, E, SE, S, SW, W, NW }

func _ready():
	generate_map()
	#execute_every_second()
	
func execute_every_second():
	var directions: Array = [Direction.N, Direction.NE, Direction.E, Direction.SE, Direction.S, Direction.SW, Direction.W, Direction.NW]
	var index = 0;
	while true:
		cast_shadows(directions[index])
		index = (index + 1) % len(directions)
		await get_tree().create_timer(1.0).timeout
	
# ---------------- Map Generation -------------------------------------
func generate_map():
	generate_unbreakables()
	generate_breakables()
	generate_background()
	cast_shadows(Direction.SE)

# Checks if tiles are empty or not
func no_obstacles(coords: Vector2i):
	var obstacleCell = obstacleTiles.get_cell_tile_data(coords)
	return obstacleCell == null;
	
func generate_unbreakables():
	#--------------------------------- UBREAKABLES ------------------------------
	# Generate unbreakable walls at the borders on Layer 2
	for x in range(map_width):
		for y in range(map_height):
			if x == 0 or x == map_width - 1 or y == 0 or y == map_height - 1:
				obstacleTiles.set_cell(Vector2i(x, y + map_offset), UNREAKABLE_TILE_ID, Vector2i(0, 0), 0)
	# Generate solid walls in a grid on Layer 2, starting from (1, 1)
	for x in range(1, map_width - 2):  # Stop before the last column
		for y in range(1, map_height - 2):  # Stop before the last row
			if x % 2 == 0 and y % 2 == 0: # Check if row and column are even
				obstacleTiles.set_cell(Vector2i(x, y + map_offset), UNREAKABLE_TILE_ID, Vector2i(0, 0), 0)
	
func generate_breakables():
	#--------------------------------- BREAKABLES ------------------------------
	# Define an array for the corners and their safe zones
	var spawn_zones = [
		# Near top-left corner
		[Vector2i(1, 1 + map_offset), Vector2i(1, 2 + map_offset), Vector2i(1, 3 + map_offset)],
		# Near top-right corner
		[Vector2i(map_width - 2, 1 + map_offset), Vector2i(map_width - 2, 2 + map_offset), Vector2i(map_width - 2, 3 + map_offset)],
		# Near bottom-left corner
		[Vector2i(1, map_height - 2 + map_offset), Vector2i(1, map_height - 3 + map_offset), Vector2i(1, map_height - 4 + map_offset)],
		# Near bottom-right corner
		[Vector2i(map_width - 2, map_height - 2 + map_offset), Vector2i(map_width - 2, map_height - 3 + map_offset), Vector2i(map_width - 2, map_height - 4 + map_offset)]
	]

	# Randomly place breakable walls on Layer 1
	rng.randomize()
	for x in range(1, map_width - 1):
		for y in range(1, map_height - 1):
			var base_breakable_chance = 0.2  # default 20% chance
			var level_chance_multiplier = 0.01  # increase by 1% per level
			var breakable_spawn_chance = base_breakable_chance + (Global.current_level - 1) * level_chance_multiplier
			breakable_spawn_chance = min(breakable_spawn_chance, 0.5) #max chance of 50%
			var current_cell = Vector2i(x, y  + map_offset)
			var skip_current_cell = false
			# Skip cells where solid tiles are placed
			if x % 2 == 0 and y % 2 == 0:
				skip_current_cell = true
			# Skip cells in the spawn_zones
			for corner in spawn_zones:
				if current_cell in corner:
					skip_current_cell = true
					break
			if skip_current_cell:
				continue
			# Place breakables
			if no_obstacles(current_cell):
				if rng.randf() < breakable_spawn_chance: 
					obstacleTiles.set_cell(current_cell, BREAKABLE_TILE_ID, Vector2i(0, 0), 0)

func generate_background():
	#--------------------------------- BACKGROUND ------------------------------
	for x in range(map_width):
		for y in range(map_height):
			var cell_coords = Vector2i(x, y + map_offset)
			if no_obstacles( cell_coords) and no_obstacles(cell_coords):
				groundTiles.set_cell( cell_coords, BACKGROUND_TILE_ID, Vector2i(0, 0), 0)

func cast_shadows(shadow_direction: Direction):
	shadowsTiles.clear();
	
	var yRange = range(map_height - 1, -1, -1) if (shadow_direction == Direction.S || shadow_direction == Direction.SE  || shadow_direction == Direction.SW) else range(map_height)
	var xRange = range(map_width - 1, -1, -1) if (shadow_direction == Direction.W || shadow_direction == Direction.SW || shadow_direction == Direction.NW) else range(map_width);
	for y in yRange:
		for x in xRange:
			if no_obstacles(Vector2i(x, y)):
				continue
			for cell_pattern in ShadowCasting.PATTERNS[shadow_direction]:
				var cast_cell = Vector2i(x, y) + cell_pattern[0]
				var cast_cell_tile = cell_pattern[1]
				if !no_obstacles(cast_cell):
					continue;
				var cell_tile_id = shadowsTiles.get_cell_source_id(cast_cell)
				
				# fill tile if it is intersection of two diagonal shadows
				if (cell_tile_id != -1 && cast_cell_tile != cell_tile_id):
					cast_cell_tile = ShadowCasting.SHADOW_FILL_TILE_ID
					
				shadowsTiles.set_cell(cast_cell, cast_cell_tile, Vector2i(0, 0), 0)
			

func get_shadow_cast_cell(shadow_direction: Direction) -> Vector2i:
	match shadow_direction:
		Direction.N:
			return Vector2i(0, -1)
		Direction.NE:
			return Vector2i(1, -1)
		Direction.E:
			return Vector2i(1, 0)
		Direction.SE:
			return Vector2i(1, 1)
		Direction.S:
			return Vector2i(0, 1)
		Direction.SW:
			return Vector2i(-1, 1)
		Direction.W:
			return Vector2i(-1, 0)
		Direction.NW:
			return Vector2i(-1, -1)
		_: 
			return Vector2i(0, 0)
