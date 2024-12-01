extends ProgressBar
#@onready var timer: Timer = %Timer

var added_value: float = 0
var drop: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func add_liquid(value):
	added_value += value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	drop = added_value * delta/3
	self.value += drop
	#set_value_no_signal(value + drop)
	#print(added_value)
	added_value -= drop
