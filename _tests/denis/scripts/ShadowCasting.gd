class_name ShadowCasting

extends Object

# Tilemap constants
const SHADOW_FILL_TILE_ID = 5
const SHADOW_NE_TILE_ID = 6
const SHADOW_NW_TILE_ID = 7
const SHADOW_SE_TILE_ID = 8
const SHADOW_SW_TILE_ID = 9

const PATTERNS: Array = [
	# N
	[[Vector2i(0, -1), SHADOW_FILL_TILE_ID]],
	# NE
	[
		[Vector2i(1, -1), SHADOW_FILL_TILE_ID], 
		[Vector2i(1, 0), SHADOW_NW_TILE_ID],
		[Vector2i(0, -1), SHADOW_SE_TILE_ID],
	],
	[[Vector2i(1, 0), SHADOW_FILL_TILE_ID]], # E
	[ # SE
		[Vector2i(1, 1), SHADOW_FILL_TILE_ID],
		[Vector2i(1, 0), SHADOW_SW_TILE_ID],
		[Vector2i(0, 1), SHADOW_NE_TILE_ID],
	],
	[[Vector2i(0, 1), SHADOW_FILL_TILE_ID]], # S
	[  # SW
		[Vector2i(-1, 1), SHADOW_FILL_TILE_ID],
		[Vector2i(-1, 0), SHADOW_SE_TILE_ID],
		[Vector2i(0, 1), SHADOW_NW_TILE_ID],
	],
	[[Vector2i(-1, 0), SHADOW_FILL_TILE_ID]], # W
	[ # NW
		[Vector2i(-1, -1), SHADOW_FILL_TILE_ID],
		[Vector2i(0, -1), SHADOW_SW_TILE_ID],
		[Vector2i(-1, 0), SHADOW_NE_TILE_ID],
	],
]
