#class_name Hero
extends Node2D

#var tween : Tween

func _ready() -> void:
	pass
	#tween = get_tree().create_tween()

func move_hero(new_position : Vector2):
	#print(new_position)
	var 	tween = get_tree().create_tween()
	tween.tween_property(self,"position",new_position,0.2)
