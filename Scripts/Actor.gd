class_name Actor
extends Path2D

signal end_turn
signal attack_target(target: Actor)
signal end_walk(target: Actor)

@export var character_name: String = "Character"
@export var move_speed = 5
@export var strength = 5
@export var finesse = 5
@export var intellect = 5
@export var attunement = 5

@onready var PathFollow = $PathFollow2D
@onready var Appearance = $PathFollow2D/AnimatedSprite2D
@onready var Size = $PathFollow2D/Area2D
@onready var HitBox = $PathFollow2D/Area2D/CollisionShape2D


const PATH_FOLLOW_SPEED = 160.0
#Should actors really be reporting their own map location? Don't know yet
var map_location: Vector2i = Vector2i(0, 0)
var actions_left := 1
var facing := Vector2(0, 1)
# initiative is just here for later work. It will be randomized and used by other classes later
var initiative := 0
var is_walking = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#The else part isn't firing apparently...
func _process(delta):
	if is_walking:
		if PathFollow.progress_ratio < 1.0:
			PathFollow.progress += PATH_FOLLOW_SPEED * delta
		elif PathFollow.progress_ratio >= 1.0:
			is_walking = false
			end_walk.emit()
			#I started making changes here
			#PathFollow.progress_ratio = 0.0
			print("Done walking!")
	pass


func _on_combat_mode_start_walk(walking):
	is_walking = true
	pass # Replace with function body.
