extends Node2D

signal start_turn
signal start_walk(walking: Actor)
#HEX_DIRECTIONS is used for the six directions cells should be relative to a given cell. N for North, NW for Northwest and so on...
#HEX_DIRECTIONS assumes a Hexagon or Half-Offset Square grid with the "Stairs Down" Tile Layout and Vertical Offset.
#I haven't found a use for HEX_DIRECTIONS yet, haha
const HEX_DIRECTIONS = {
	"N":  Vector2(0,-1),
	"NW": Vector2(-1, 0),
	"NE": Vector2(1, -1),
	"S":  Vector2(0, 1),
	"SW": Vector2(-1, 1),
	"SE": Vector2(1, 0),
}
#grid_points is a dictionary used to reference Navigator's points by their respective coordinates on BattleMap
#Once grid_points is populated, use it as reference for navigation code.
var game_busy = false
var grid_points = {}
@onready var Navigator = AStar2D
@onready var Actors = []
@onready var BattleMap = $BattleGrid




# Called when the node enters the scene tree for the first time.
#Navigator setup is here for now, move over to navigator_setup later. Navigator is fussy with AStar2D.new() anywhere else.
func _ready():
	Navigator = AStar2D.new()
	navigator_setup()
	print(Navigator.get_point_count())


	queue_redraw()
	#At some point I'll need to find a way to add Actors from outside. For now I'm just calling these two directly.
	Actors.append($Actor)
	#Actors.append($Pyraptor)
	Actors[0].map_location = Vector2i(5, 9)
	Actors[0].position = Navigator.get_point_position(grid_points[Actors[0].map_location])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	pass


func _input(event):

	if Input.is_action_just_pressed("mouse_click") and game_busy == false:
		
		print(BattleMap.get_cell_tile_data(0, BattleMap.local_to_map(get_local_mouse_position()), false))
		if BattleMap.get_cell_tile_data(0, BattleMap.local_to_map(get_local_mouse_position()), false) != null:
			walk_actor(Actors[0], BattleMap.local_to_map(get_local_mouse_position()))
			#instant_walk_actor(Actors[0], BattleMap.local_to_map(get_local_mouse_position()))



		pass

#Grabs an array of the BattleMap's cells and adds those cells' centered positions to the Navigator as points.
func navigator_setup():
	#cell_index is only used to give the AStar2D points an ID number.
	var cell_index = 0
	for cell in BattleMap.get_used_cells(0):
		Navigator.add_point(cell_index, BattleMap.map_to_local(cell), 1.0)
		grid_points[cell] = cell_index
		cell_index += 1

	#get_surrounding_cells gets cells even if they have no tile, hence why we check for tile data
	for point in Navigator.get_point_ids():
		var neighbors = []
		for surrounding in BattleMap.get_surrounding_cells(grid_points.find_key(point)):
			if BattleMap.get_cell_tile_data(0, surrounding, false) != null:
				neighbors.append(surrounding)
			else:
				continue
		for neighbor in neighbors:
			Navigator.connect_points(point, grid_points.get(neighbor), true)

#Remember that Path2D points are relative to their node's original position, not global space. The path array might be handy later on, I dunno
func walk_actor(actor: Actor, destination: Vector2i):
	if actor.map_location == destination:
		pass
	else:
		game_busy = true
		#var path = []
		var length_in_tiles = 0
		for step in Navigator.get_id_path(grid_points[actor.map_location], grid_points[destination]):
			actor.curve.add_point(Navigator.get_point_position(step) - actor.position)
			#path.append(step)
			length_in_tiles += 1
		#walk_actor relies on the _process() function in the Actor class to do its thing before any logic is handled
		start_walk.emit(actor)
		await actor.end_walk
		actor.map_location = destination
		print(actor.curve.get_baked_length())
		actor.PathFollow.progress_ratio = 0.0
		actor.curve.clear_points()
		actor.position = Navigator.get_point_position(grid_points[actor.map_location])
		game_busy = false
	
#Probably won't use this method much except as reference, or maybe debugging
func instant_walk_actor(actor: Actor, destination: Vector2i):
	var path = []
	for step in Navigator.get_id_path(grid_points[actor.map_location], grid_points[destination]):
		path.append(step)
	path.pop_front()
	for step in path:
		actor.map_location = grid_points.find_key(step)
		actor.position = Navigator.get_point_position(grid_points[actor.map_location])
		print("Greenhood walked to " + str(actor.map_location))


func _draw():
	for point in Navigator.get_point_ids():
		draw_circle(Navigator.get_point_position(point), 4, Color.RED)
		for connection in Navigator.get_point_connections(point):
			draw_line(Navigator.get_point_position(point), Navigator.get_point_position(connection), Color.RED, 2.0, false)

#This down here is just for holding print functions for testing things
func print_debugs():
		#print("Mouse Click at: ", BattleMap.local_to_map(get_local_mouse_position()))
		
		#print(str(BattleMap.get_cell_tile_data(0, BattleMap.local_to_map(get_local_mouse_position()), false)))
		
		#for cell in BattleMap.get_surrounding_cells(BattleMap.local_to_map(get_local_mouse_position())):
		#	print("Its surrounding cells are: " + str(cell))
		
		#for step in Navigator.get_id_path(grid_points[Vector2i(5, 9)], grid_points[BattleMap.local_to_map(get_local_mouse_position())]):
		#print("Greenhood steps to... " + str(grid_points.find_key(step)))
		
		#for point in grid_points:
			#print("The AStar2D point's ID at tile " + str(point) + " is " + str(grid_points.get(point)))
	pass


