class_name PlayerMoveResult

extends Object

var success: bool
var new_coords: Vector2i
var global_position: Vector2
var item_tile_id: int

# Constructor
func _init(success: bool, new_coords: Vector2i):
	self.success = success
	self.new_coords = new_coords;
