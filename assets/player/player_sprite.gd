tool
extends Sprite

onready var _stand = preload("res://assets/player/textures/stand.png")
onready var _jump = preload("res://assets/player/textures/jump.png")
onready var _run = preload("res://assets/player/textures/run.png")

const FRAMERATE = 15

var _direction := 0
var _progress := 0.0
var _parent_node25d: Node25D
var _parent_math: PlayerMath25D

func _ready():
	_parent_node25d = get_parent()
	_parent_math = _parent_node25d.get_child(0)

func _process(delta):
	if Engine.is_editor_hint():
		return # Don't run this in the editor.

	var movement = _check_movement() # Always run to get direction, but don't always use return bool.

	# Test-only move and collide, check if the player is on the ground.
	var k = _parent_math.move_and_collide(Vector3.DOWN * 10 * delta, true, true, true)
	if k != null:
		if movement:
			hframes = 6
			texture = _run
			if (Input.is_action_pressed("movement_modifier")):
				delta /= 2
			_progress = fmod((_progress + FRAMERATE * delta), 6)
			frame = _direction * 6 + int(_progress)
		else:
			hframes = 1
			texture = _stand
			_progress = 0
			frame = _direction
	else:
		hframes = 2
		texture = _jump
		_progress = 0
		var jumping = 1 if _parent_math.vertical_speed < 0 else 0
		frame = _direction * 2 + jumping

# This method returns a bool but if true it also outputs to the direction variable.
func _check_movement() -> bool:
	# Gather player input and store movement to these int variables. Note: These indeed have to be integers.
	var x := 0
	var z := 0

	if Input.is_action_pressed("move_right"):
		x += 1
	if Input.is_action_pressed("move_left"):
		x -= 1
	if Input.is_action_pressed("move_forward"):
		z -= 1
	if Input.is_action_pressed("move_back"):
		z += 1

	# Set the direction based on which inputs were pressed.
	if x == 0:
		if z == 0:
			return false # No movement.
		elif z > 0:
			_direction = 0
		else:
			_direction = 4
	elif x > 0:
		if z == 0:
			_direction = 2
			flip_h = true
		elif z > 0:
			_direction = 1
			flip_h = true
		else:
			_direction = 3
			flip_h = true
	else:
		if z == 0:
			_direction = 2
			flip_h = false
		elif z > 0:
			_direction = 1
			flip_h = false
		else:
			_direction = 3
			flip_h = false
	return true # There is movement.
