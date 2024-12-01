class_name PickupAnimations

extends Node2D

var drop_sprite: Sprite2D;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	drop_sprite = Sprite2D.new()
	drop_sprite.texture = preload("res://assets/textures/game-icons_net/drop.svg")  # Replace with your texture
	drop_sprite.scale = Vector2(0.1, 0.1);
	drop_sprite.position = Vector2(0, -32.0)
	drop_sprite.centered = true
	drop_sprite.modulate = Color("4192c9")

func show_drop_sprite():
	spawn_pickup_sprite(drop_sprite.duplicate())

func spawn_pickup_sprite(sprite: Sprite2D):
	add_child(sprite)

	# Create a Tween to handle the animation
	var tween = create_tween().parallel()

	# Animate position to move upward
	tween.tween_property(sprite, "position:y", sprite.position.y + 32, 0.3)  # Move up 200px in 1 second
	tween.tween_property(sprite,"scale",Vector2.ZERO,0.3)
	# Animate opacity to fade out
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)  # Fade out over 1 second

	# Connect completion signal to free the sprite
	tween.connect("finished", sprite.queue_free)	
