#class_name Hero
extends Node2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

#var tween : Tween

func _ready() -> void:
	animated_sprite.frame = 0
	pass
	#tween = get_tree().create_tween()

func reset():
	animated_sprite.stop()
	animated_sprite.frame = 0

func play_game_over():
	animated_sprite.play("game_over")

func move_hero(new_position : Vector2, time : float = 0.2):
	#print(new_position)
	var 	tween = get_tree().create_tween()
	#animated_sprite.play("game_over")
	tween.tween_property(self,"position",new_position,time)
	#animated_sprite.stop()
