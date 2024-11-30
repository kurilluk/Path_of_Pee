#@tool
class_name Maze
extends Node2D

# Node references
@onready var groundTiles: TileMapLayer = $GroundTiles
@onready var obstacleTiles: TileMapLayer = $ObstacleTiles
@onready var itemsTiles: TileMapLayer = $ItemTiles
@onready var shadowsTiles: TileMapLayer = $ShadowTiles
@onready var playerTiles: TileMapLayer = $PlayerTiles


# Randomizer & Dimension values ( make sure width & height is uneven)
@export var initial_width = 11 
	#set(value):
		#initial_width = value
		#_generate_map()
		#change_shadow_direction()
		#_place_player()
		
@export var initial_height = 11
	#set(value):
		#initial_height = value
		#_generate_map()
		#change_shadow_direction()
		#_place_player()
		
var map_width = initial_width
var map_height = initial_height 
var map_offset = 0 #Shifts map four rows down for UI
var rng = RandomNumberGenerator.new()
var player_coords: Vector2i;

# Tilemap constants
const BACKGROUND_TILE_ID = 0
const BREAKABLE_TILE_ID = 1
const UNREAKABLE_TILE_ID = 2

const PLAYER_TILE_ID = 14

var shadow_orientation = 0

# Shadow direction, N - North/Up, E - East/Right etc
enum Direction { N, NE, E, SE, S, SW, W, NW }

func _ready():
	_generate_map()
	change_shadow_direction()
	_place_player()
	place_items(15, 10)
	
func change_shadow_direction():
	var directions: Array = [Direction.N, Direction.NE, Direction.E, Direction.SE, Direction.S, Direction.SW, Direction.W, Direction.NW]

	var old_shadow_orientation = self.shadow_orientation
	shadow_orientation = (shadow_orientation + 1) % len(directions)
	
	#_carry_items_in_shadows(directions[old_shadow_orientation])
	_carry_blocks_in_shadows(directions[old_shadow_orientation])
	_cast_shadows(directions[shadow_orientation])

func place_items(item_tile_id: int, count, only_in_shades: bool = false):
	var offset_x = randi_range(0, map_width)
	var offset_y = randi_range(0, map_height)
	for x in range(map_width):
		for y in range(map_height):
			var coords = Vector2i((x + offset_x) % map_width, (y + offset_y) % map_height)
			
			if (is_obstacle(coords) || is_player(coords) || is_item(coords)):
				continue;
				
			if only_in_shades && !in_shade(coords):
				continue
				
			if count <= 0:
				return;
	
			count -= 1
			
			itemsTiles.set_cell(coords, item_tile_id, Vector2i(0, 0), 0)
			
			# randomize next item placement
			offset_x = randi_range(0, map_width)
			offset_y = randi_range(0, map_height)

func remove_items(count, only_in_shades: bool):
	var offset_x = randi_range(0, map_width)
	var offset_y = randi_range(0, map_height)
	for x in range(map_width):
		for y in range(map_height):
			var coords = Vector2i((x + offset_x) % map_width, (y + offset_y) % map_height)
			if is_item(coords):
				itemsTiles.erase_cell(coords)

			if count <= 0:
				return;
	
			count -= 1

			# randomize next item placement
			offset_x = randi_range(0, map_width)
			offset_y = randi_range(0, map_height)
			
func remove_item(coords: Vector2i):
	itemsTiles.erase_cell(coords)
			
# ---------------- Map Generation -------------------------------------
func _generate_map():
	_generate_unbreakables()
	_generate_breakables()
	_generate_background()

func move_player(relative_coords: Vector2i) -> PlayerMoveResult:
	var new_player_coords = player_coords + relative_coords;
	if (!no_obstacles(new_player_coords)):
		return PlayerMoveResult.new(false, player_coords);
	
	playerTiles.clear();
	playerTiles.set_cell(new_player_coords, PLAYER_TILE_ID, Vector2i(0, 0), 0)
	player_coords = new_player_coords;
	
	var result = PlayerMoveResult.new(true, new_player_coords);
	result.item_tile_id = itemsTiles.get_cell_source_id(new_player_coords)
	return result;

func _place_player():
	var coords = Vector2i()
	while (true):
		coords = Vector2i(randi_range(0, map_width - 1), randi_range(0, map_height - 1))
		if no_obstacles(coords):
			break
	
	playerTiles.clear();
	playerTiles.set_cell(coords, PLAYER_TILE_ID, Vector2i(0, 0), 0)
	player_coords = coords;

func in_shade(coords: Vector2i): 
	var cell_tile_id = shadowsTiles.get_cell_source_id(coords)
	return cell_tile_id == ShadowCasting.SHADOW_FILL_TILE_ID
	
# Checks if tiles are empty or not
func no_obstacles(coords: Vector2i):
	return !is_obstacle(coords)
	
func is_obstacle(coords: Vector2i):
	#if not obstacleCell:
		#return
	var obstacleCell = obstacleTiles.get_cell_tile_data(coords)
	return obstacleCell != null;



func is_item(coords: Vector2i):
	var itemCell = itemsTiles.get_cell_tile_data(coords)
	return itemCell != null;

func is_player(coords: Vector2i):
	return player_coords == coords;

func _generate_unbreakables():
	#--------------------------------- UBREAKABLES ------------------------------
	# Generate unbreakable walls at the borders on Layer 2
	if not obstacleTiles:
		return
	for x in range(map_width):
		for y in range(map_height):
			if x == 0 or x == map_width - 1 or y == 0 or y == map_height - 1:
				obstacleTiles.set_cell(Vector2i(x, y + map_offset), UNREAKABLE_TILE_ID, Vector2i(0, 0), 0)
	# Generate solid walls in a grid on Layer 2, starting from (1, 1)
	for x in range(1, map_width - 2):  # Stop before the last column
		for y in range(1, map_height - 2):  # Stop before the last row
			if x % 2 == 0 and y % 2 == 0: # Check if row and column are even
				obstacleTiles.set_cell(Vector2i(x, y + map_offset), UNREAKABLE_TILE_ID, Vector2i(0, 0), 0)
	
func _generate_breakables():
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
			if no_obstacles(current_cell):
				if rng.randf() < breakable_spawn_chance: 
					obstacleTiles.set_cell(current_cell, BREAKABLE_TILE_ID, Vector2i(0, 0), 0)
					return

func _generate_background():
	#--------------------------------- BACKGROUND ------------------------------
	for x in range(map_width):
		for y in range(map_height):
			var cell_coords = Vector2i(x, y + map_offset)
			if no_obstacles( cell_coords) and no_obstacles(cell_coords):
				groundTiles.set_cell( cell_coords, BACKGROUND_TILE_ID, Vector2i(0, 0), 0)

func _cast_shadows(shadow_direction: Direction):
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
				#if !no_obstacles(cast_cell):
				#	continue;
				var cell_tile_id = shadowsTiles.get_cell_source_id(cast_cell)
				
				# fill tile if it is intersection of two diagonal shadows
				if (cell_tile_id != -1 && cast_cell_tile != cell_tile_id):
					cast_cell_tile = ShadowCasting.SHADOW_FILL_TILE_ID
					
				shadowsTiles.set_cell(cast_cell, cast_cell_tile, Vector2i(0, 0), 0)
			
func _get_shadow_cast_cell(shadow_direction: Direction) -> Vector2i:
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

func _carry_items_in_shadows(from_shadow_direction: Direction):
	const carried_coords = [];
	for x in range(map_width):
		for y in range(map_height):
			var cell_coord = Vector2i(x, y);
			if !is_item(cell_coord) || !in_shade(cell_coord):
				continue
				
			if (carried_coords.has(cell_coord)):
				continue
			
			var target_coord = cell_coord + _get_shadow_move_target_cell(from_shadow_direction)
			if is_item(target_coord) || is_obstacle(target_coord) || is_player(target_coord):
				continue
			
			var item_tile_id = itemsTiles.get_cell_source_id(cell_coord)
			itemsTiles.erase_cell(cell_coord)
			itemsTiles.set_cell(target_coord, item_tile_id, Vector2i(0, 0), 0)
			carried_coords.push_back(target_coord)
			
func _carry_blocks_in_shadows(from_shadow_direction: Direction):
	const carried_coords = [];
	for x in range(map_width):
		for y in range(map_height):
			var cell_coord = Vector2i(x, y);
			var obstacle_tile_id = obstacleTiles.get_cell_source_id(cell_coord)
			if obstacle_tile_id != BREAKABLE_TILE_ID:
				continue
				
			if (carried_coords.has(cell_coord)):
				continue
			
			var target_coord = cell_coord + _get_shadow_move_target_cell(from_shadow_direction)
			if is_item(target_coord) || is_obstacle(target_coord) || is_player(target_coord):
				continue
			
			obstacleTiles.erase_cell(cell_coord)
			obstacleTiles.set_cell(target_coord, obstacle_tile_id, Vector2i(0, 0), 0)
			carried_coords.push_back(target_coord)


func _get_shadow_move_target_cell(shadow_direction: Direction) -> Vector2i:
	match shadow_direction:
		Direction.N:
			return Vector2i(1, 0)
		Direction.NE:
			return Vector2i(0, -1)
		Direction.E:
			return Vector2i(0, -1)
		Direction.SE:
			return Vector2i(-1, 0)
		Direction.S:
			return Vector2i(-1, 0)
		Direction.SW:
			return Vector2i(0, 1)
		Direction.W:
			return Vector2i(0, 1)
		Direction.NW:
			return Vector2i(1, 0)
		_: 
			return Vector2i(0, 0)