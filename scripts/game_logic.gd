extends Node2D

@onready var hero: Node2D = %Hero
@onready var map: Maze = $Map

# Speed of the Node2D
const  speed: float = 64.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	# Reset the direction
	var direction = Vector2.ZERO

	# Update the direction based on input
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	elif Input.is_action_pressed("ui_left"):
		direction.x -= 1

	if direction == Vector2.ZERO:
		if Input.is_action_pressed("ui_down"):
			direction.y += 1
		elif Input.is_action_pressed("ui_up"):
			direction.y -= 1

	# Normalize direction to prevent faster diagonal movement
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		call_maze_hero(direction)
		hero.position += direction * speed

func call_maze_hero(vector :Vector2):
	map.move_player(vector)
