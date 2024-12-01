class_name PickupAnimations

extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_pickup_sprite(sprite: Sprite2D):
	add_child(sprite)

	# Create a Tween to handle the animation
	var tween = create_tween()

	# Animate position to move upward
	tween.tween_property(sprite, "position:y", sprite.position.y - 64, 0.5)  # Move up 200px in 1 second

	# Animate opacity to fade out
	tween.tween_property(sprite, "modulate:a", 0.0, 1.0)  # Fade out over 1 second

	# Connect completion signal to free the sprite
	tween.connect("finished", sprite.queue_free)
