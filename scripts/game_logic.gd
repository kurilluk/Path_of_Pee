extends Node2D

@onready var hero = %Hero
@onready var map: Maze = $Map
@onready var move_effort_bar: ProgressBar = %MoveEffortBar
@onready var day_part_bar: ProgressBar = %DayPartBar
@onready var hydration_bar: ProgressBar = %HydrationBar
@onready var blader_bar: ProgressBar = %BladerBar
@onready var start_button: Button = %StartButton

var last_direction = Vector2.ZERO
var effort : int = 0
var day_part: int = 0

const BLADDER_RATIO = 0.3
const HYDRATION_CONSUM = 5

const INITIAL_MAZE_SIZE = 4

# Speed of the Node2D
const  speed: float = 64.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	# Reset the direction
	var direction = Vector2.ZERO
	
	if Input.is_action_just_pressed("ui_accept"):
		_on_Start_button_pressed()
		
	if Input.is_action_just_pressed("ui_page_up"):
		next_level()
	
	if Input.is_action_just_pressed("ui_page_down"):
		drink()

	# Update the direction based on input
	if Input.is_action_just_pressed("m_right"):
		direction.x += 1
	elif Input.is_action_just_pressed("m_left"):
		direction.x -= 1

	if direction == Vector2.ZERO:
		if Input.is_action_just_pressed("m_down"):
			direction.y += 1
		elif Input.is_action_just_pressed("m_up"):
			direction.y -= 1

	# Normalize direction to prevent faster diagonal movement
	if direction != Vector2.ZERO:
		#if last_direction == direction:
		effort += 1
		#print(effort)
		move_effort_bar.set_value_no_signal(effort)
		if effort >= move_effort_bar.max_value:
			effort = 0
			direction = direction.normalized()
			var result = map.move_player(direction)
			update_player(result)
			progress_day()
			#hero.move_hero(hero.position + direction * speed)
	#hero.position += direction * speed

func update_player(result : PlayerMoveResult):
	if result.success:
		hero.move_hero(result.global_position)
		if result.item_tile_id == 15:
			drink()
			map.remove_item(result.new_coords)

#func call_maze_hero(vector :Vector2):
	#map.move_player(vector)
func drink():
	var emount = 100 - hydration_bar.value
	hydration_bar.value = hydration_bar.max_value
	blader_bar.value += emount*BLADDER_RATIO
	# TODO add blader by day progression
#func balance_liquids():

func spend_liquids():
	hydration_bar.value -= HYDRATION_CONSUM

func progress_day():
	day_part += 1
	day_part_bar.set_value_no_signal(day_part)
	spend_liquids()
	if day_part >= day_part_bar.max_value:
		day_part = 0
		map.change_shadow_direction() 

func generate_level_map(level: int = 1) -> Vector2:
	#match level:
		#1: # preset for level 1
			#map.generate_map(11, 11)
			#map.place_moveable_blocks(3)
			#map.place_items(15,5)
		#_: # preset default/invalid level
			#map.generate_map(5, 5)
			#map.place_moveable_blocks(1)
#
	#return map.place_player();
	map.generate_map(INITIAL_MAZE_SIZE+(2*level), INITIAL_MAZE_SIZE+(2*level))
	map.place_items(15,5)
	map.position = Vector2.ZERO
	map.position = - map.place_player()
	return Vector2.ZERO #map.place_player()

var actual_level : int = 1
func next_level():
	var 	tween = get_tree().create_tween()
	tween.tween_property(map,"modulate:a",0.0,1)
	#await tween.finished
	tween.connect("finished", on_map_hide)
	
func on_map_hide():
	hero.move_hero(Vector2.ZERO,0.0)
	var 	tween = get_tree().create_tween()
	generate_level_map(actual_level)
	tween.tween_property(map,"modulate:a",1.0,1)
	actual_level += 1

func _on_Start_button_pressed() -> void:
	actual_level = 1
	var new_position = generate_level_map()
	hero.move_hero(new_position,1)
	start_button.visible = false
