class_name MazeNode

extends Object

# Enum for directions
# Maze's indexes are is growing in UP and RIGHT directions
enum Direction { UP, RIGHT, DOWN, LEFT }

var position: Vector2
var connections: Array = [null, null, null, null] # [UP, RIGHT, DOWN, LEFT]

# Constructor
func _init(x: int, y: int):
	position = Vector2(x, y)
	
# Helper methods
func set_connection(node: MazeNode):
	assert(self != node, "Can't connect to itself")
	
	var direction = _getRelativeDirection(node)
	if direction in Direction.values():
		connections[direction] = node

func _getRelativeDirection(toNode: MazeNode) -> MazeNode.Direction:
	assert(position.x == toNode.position.x || position.y == toNode.position.y, "This and other node should be on same X or Y axies.")
	assert(self != toNode, "Can't get relative direction to itself")
		
	if (position.x > toNode.position.x):
		return Direction.LEFT
	elif (position.x < toNode.position.x):
		return Direction.RIGHT
	elif (position.y > toNode.position.y):
		return Direction.DOWN
	else:
		return Direction.UP
	

func get_connection(direction: Direction) -> MazeNode:
	if direction in Direction.values():
		return connections[direction]
	return null
