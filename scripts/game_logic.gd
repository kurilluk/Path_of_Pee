extends Node2D

@onready var hero = %Hero
@onready var map: Maze = $Map
@onready var move_effort_bar: ProgressBar = %MoveEffortBar
@onready var day_part_bar: ProgressBar = %DayPartBar
@onready var hydration_bar: ProgressBar = %HydrationBar
@onready var blader_bar: ProgressBar = %BladerBar
@onready var start_button: Button = %StartButton
@onready var pickup_animations: PickupAnimations = $Hero/PickupAnimations
@onready var SFX: AudioStreamPlayer = $SFX
@onready var Music: AudioStreamPlayer = $Music
@onready var Overvoise: AudioStreamPlayer = $Overvoice
@onready var score_value: Label = %ScoreValue
@onready var flush: AudioStreamPlayer = $Flush
@onready var ui_game: MarginContainer = %UI_game
@onready var level_value: Label = %LevelValue

var actual_level : int = 1
var last_direction = Vector2.ZERO
var effort : int = 0
var day_part: int = 0
var score: int = 0
var no_inputs = true

const BLADDER_RATIO = 0.3
const HYDRATION_CONSUM = 5

const INITIAL_MAZE_SIZE = 4

# Speed of the Node2D
const  speed: float = 64.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ui_game.modulate.a = 0.0
	get_tree().paused = true
	score = 0;
	score_value.text = "0"
	no_inputs = true
	pass

func _input(event: InputEvent) -> void:
	# Reset the direction
	if no_inputs:
		return
		
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
			SoundManager.play_step_sound(SFX)
			if result.success:
				hero.move_hero(result.global_position)
				check_for_items(result.item_tile_id, result.new_coords)
			progress_day()			
			#hero.move_hero(hero.position + direction * speed)
	#hero.position += direction * speed

	
func check_for_items(item_tile_id: int, item_coords: Vector2i):
	match item_tile_id:
		15: # bottle/water
			drink()
			score += 1;
			score_value.text = str(score)
			map.remove_item(item_coords)
		20: # teleport/toilet
			blader_bar.set_value_no_signal(0.0)
			#SoundManager.set_ambient_to_phase1();
			SoundManager.play_sound(flush, SoundManager.FLUSH_SOUND)
			next_level()
		22: # fountain
			blader_bar.add_liquid(10)
			SoundManager.play_sound(SFX, SoundManager.SFX_FONTAIN)

#func call_maze_hero(vector :Vector2):
	#map.move_player(vector)
func drink():
	var emount = 100 - hydration_bar.value
	hydration_bar.value = hydration_bar.max_value
	blader_bar.add_liquid(emount*BLADDER_RATIO)
	SoundManager.play_sound(SFX, SoundManager.SFX_DRINKING_BOTTLE_1)
	# TODO add blader by day progression
	
	pickup_animations.show_drop_sprite()
	
#func balance_liquids():

func spend_liquids():
	hydration_bar.value -= HYDRATION_CONSUM

func progress_day():
	day_part += 1
	day_part_bar.set_value_no_signal(day_part)
	spend_liquids()
	var walls_are_moving = false;
	if day_part >= day_part_bar.max_value:
		day_part = 0
		walls_are_moving = map.change_shadow_direction()
	
	if walls_are_moving:
		SoundManager.play_sound(SFX, SoundManager.SFX_WALL_CHANGE_1)

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
	map.place_moveable_blocks(level*level) #moveable blocks
	map.place_items(15,2 * level) # Bottles
	map.place_items(20,1) # Toilette
	map.place_items(22, 2 * (level-1)) # Fountains
	map.position = Vector2.ZERO
	map.position = - map.place_player()
	return Vector2.ZERO #map.place_player()

func next_level():
	var tween = get_tree().create_tween()
	#get_tree().paused = true
	no_inputs = true
	tween.tween_property(map,"modulate:a",0.0,1)
	#await tween.finished
	tween.connect("finished", on_map_hide)



	
func on_map_hide():
	hero.move_hero(Vector2.ZERO,0.0)
	var 	tween = get_tree().create_tween()
	generate_level_map(actual_level)
	tween.tween_property(map,"modulate:a",1.0,1)
	actual_level += 1
	level_value.text = str(actual_level)
	#get_tree().paused = false
	no_inputs = false


func _on_Start_button_pressed() -> void:
	hero.reset()
	ui_game.modulate.a = 0.0
	blader_bar.set_value_no_signal(0.0)
	hydration_bar.set_value_no_signal(50.0)
	score = 0
	score_value.text = "0"
	var tween = create_tween()
	tween.tween_property(ui_game,"modulate:a",1.0,2)
	get_tree().paused = false
	actual_level = 1
	level_value.text = str(actual_level)
	var new_position = generate_level_map()
	hero.move_hero(new_position,1)
	start_button.visible = false
	SoundManager.play_button_click_sound(SFX)
	no_inputs = false
	SoundManager.start_ambient_loop(Music)

func play_music(value: float):
	if value > 80:
		SoundManager.transit_ambient_to_phase3(Overvoise);
	elif value > 40:
		SoundManager.transit_ambient_to_phase2(Overvoise);

func _on_bladder_bar_value_changed(value: float) -> void:
	play_music(value)
	if value >= 100:
		game_over()
	#TODO game over when value is 100 or more
	
	#var bladder_fill_rate = (blader_bar.value + 0.0) / blader_bar.max_value;
	#if bladder_fill_rate > 0.80: # 90%
		#SoundManager.transit_ambient_to_phase3();
	#elif bladder_fill_rate > 0.40: # 60%
		#SoundManager.transit_ambient_to_phase2();
func game_over():
	Music.stop()
	SoundManager.play_game_over(SFX)
	hero.play_game_over()
	get_tree().paused = true
	start_button.text = "Try again?"
	start_button.visible = true
	# TODO end screen
	
	pass

func _on_hydration_bar_value_changed(value: float) -> void:
	if value <= 0:
		game_over() 	#TODO 
