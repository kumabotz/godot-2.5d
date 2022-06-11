# This node converts a 3D position to 2D using a 2.5D transformation matrix.
# The transformation of its 2D form is controlled by its 3D child.
tool
extends Node2D
class_name Node25D, "res://addons/node25d/icons/node_25d_icon.png"

# SCALE is the number of 2D units in one 3D unit. Ideally, but not necessarily, an integer.
const SCALE = 32

# Exported spatial position for editor usage.
export(Vector3) var spatial_position setget set_spatial_position, get_spatial_position

# GDScript throws errors when Basis25D is its own structure.
# There is a broken implementation in a hidden folder.
# https://github.com/godotengine/godot/issues/21461
# https://github.com/godotengine/godot-proposals/issues/279
var _basisX: Vector2
var _basisY: Vector2
var _basisZ: Vector2

# Cache the spatial stuff for internal use.
var _spatial_position: Vector3
var _spatial_node: Spatial

# These are separated in case anyone wishes to easily extend Node25D.
func _ready():
	Node25D_ready()

func _process(_delta):
	Node25D_process()

# Call this method in _ready, or before Node25D_process is first ran.
func Node25D_ready():
	_spatial_node = get_child(0)
	# Changing the values here will change the default for all Node25D instances.
	_basisX = SCALE * Vector2(0.86602540378, 0.5)
	_basisY = SCALE * Vector2(0, -1)
	_basisZ = SCALE * Vector2(-0.86602540378, 0.5)

# Call this method in _process, or whenever the position of this object changes.
func Node25D_process():
	if _spatial_node == null:
		return
	_spatial_position = _spatial_node.translation

	var flat_pos = _spatial_position.x * _basisX
	flat_pos += _spatial_position.y * _basisY
	flat_pos += _spatial_position.z * _basisZ

	global_position = flat_pos

func get_basis():
	return [_basisX, _basisY, _basisZ]

func get_spatial_position():
	if not _spatial_node:
		_spatial_node = get_child(0)
	return _spatial_node.translation

func set_spatial_position(value):
	_spatial_position = value
	if _spatial_node:
		_spatial_node.translation = value
	elif get_child_count() > 0:
		_spatial_node = get_child(0)

# Used by YSort25D
static func y_sort(a: Node25D, b: Node25D):
	return a._spatial_position.y < b._spatial_position.y

static func y_sort_slight_xz(a: Node25D, b: Node25D):
	var a_index = a._spatial_position.y + 0.001 * (a._spatial_position.x + a._spatial_position.z)
	var b_index = b._spatial_position.y + 0.001 * (b._spatial_position.x + b._spatial_position.z)
	return a_index < b_index
