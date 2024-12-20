### Level.gd

extends Node2D

# Node references
@onready var tilemap = $TileMap

# Randomizer & Dimension values ( make sure width & height is uneven)
const initial_width = 15 
const initial_height = 15 
var map_width = initial_width
var map_height = initial_height 
var map_offset = 4 #Shifts map four rows down for UI
var rng = RandomNumberGenerator.new()

# Tilemap constants
const BACKGROUND_TILE_ID = 0
const BREAKABLE_TILE_ID = 1
const UNREAKABLE_TILE_ID = 2
const BACKGROUND_TILE_LAYER = 0
const BREAKABLE_TILE_LAYER = 1
const UNREAKABLE_TILE_LAYER = 2

func _ready():
	generate_map()
	
# ---------------- Map Generation -------------------------------------
func generate_map():
	generate_unbreakables()
	generate_breakables()
	generate_background()

# Checks if tiles are empty or not
func is_cell_empty(layer, coords):
	var data = tilemap.get_cell_tile_data(layer, coords)
	return data == null
	
func generate_unbreakables():
	#--------------------------------- UBREAKABLES ------------------------------
	# Generate unbreakable walls at the borders on Layer 2
	for x in range(map_width):
		for y in range(map_height):
			if x == 0 or x == map_width - 1 or y == 0 or y == map_height - 1:
				tilemap.set_cell(UNREAKABLE_TILE_LAYER, Vector2i(x, y + map_offset), UNREAKABLE_TILE_ID, Vector2i(0, 0), 0)
	# Generate solid walls in a grid on Layer 2, starting from (1, 1)
	for x in range(1, map_width - 2):  # Stop before the last column
		for y in range(1, map_height - 2):  # Stop before the last row
			if x % 2 == 0 and y % 2 == 0: # Check if row and column are even
				tilemap.set_cell(UNREAKABLE_TILE_LAYER, Vector2i(x, y + map_offset), UNREAKABLE_TILE_ID, Vector2i(0, 0), 0)
	
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
			var breakable_spawn_chance = base_breakable_chance + level_chance_multiplier
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
			if is_cell_empty(BREAKABLE_TILE_LAYER, current_cell):
				if rng.randf() < breakable_spawn_chance: 
					tilemap.set_cell(BREAKABLE_TILE_LAYER, current_cell, BREAKABLE_TILE_ID, Vector2i(0, 0), 0)

func generate_background():
	#--------------------------------- BACKGROUND ------------------------------
	for x in range(map_width):
		for y in range(map_height):
			var cell_coords = Vector2i(x, y + map_offset)
			if is_cell_empty(BREAKABLE_TILE_LAYER, cell_coords) and is_cell_empty(UNREAKABLE_TILE_LAYER, cell_coords):
				tilemap.set_cell(BACKGROUND_TILE_LAYER, cell_coords, BACKGROUND_TILE_ID, Vector2i(0, 0), 0)
