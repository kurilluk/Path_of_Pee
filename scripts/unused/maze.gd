class_name Maze_old

extends Object
\
var width: int
var height: int
var grid: Array = [] # 2D array to hold MazeNodes

# Constructor
func _init(width: int, height: int):
	self.width = width
	self.height = height
	_initialize_grid()
	
# Private method to initialize the grid
func _initialize_grid():
	for y in range(height):
		var row: Array = []
		for x in range(width):
			var node = MazeNode.new(x, y)
			row.append(node)
		grid.append(row)

func _buildMaze():
	var visitedNodes: Array = []    
	var stack: Array = []
	var initialNode = grid[randi() % len(grid)]
	visitedNodes.push_back(initialNode);
	stack.push_back(initialNode);
	while len(stack) > 0:
		var currentNode: MazeNode = stack.pop_back();
		var neighbourNode: MazeNode = _chooseUnvisitedNeighbours(currentNode, visitedNodes)
		if (neighbourNode == null):
			continue;
		stack.push_back(currentNode);
		currentNode.set_connection(neighbourNode)
		visitedNodes.push_back(neighbourNode);
		stack.push_back(neighbourNode);

func _chooseUnvisitedNeighbours(node: MazeNode, visitedNodes: Array) -> MazeNode:
	var left = get_node(node.position.x - 1, node.position.y)
	if (randf() < 0.25 && left != null && !visitedNodes.has(left)):
		return left;
	
	var right = get_node(node.position.x + 1, node.position.y)
	if (randf() < 0.25 && right != null && !visitedNodes.has(right)):
		return right;
	
	var top = get_node(node.position.x, node.position.y + 1)
	if (randf() < 0.25 && top != null && !visitedNodes.has(top)):
		return top;
		
	var down = get_node(node.position.x, node.position.y - 1)
	if (down != null && !visitedNodes.has(down)):
		return down;
	return null;
	

# Get node at specific position
func get_node(x: int, y: int) -> MazeNode:
	if x >= 0 and x < width and y >= 0 and y < height:
		return grid[y][x]
	return null
