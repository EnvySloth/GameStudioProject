extends Node3D
class_name Identifier

var speed : float = 4

@onready var identifierMesh: MeshInstance3D = $IdentifierMesh
@onready var identifierLight: OmniLight3D = $IdentifierLight

func updateColor(color : Color) -> void:
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	identifierLight.light_color = color
	identifierMesh.set_surface_override_material(0, material)

func _process(delta: float) -> void:
	rotate_object_local(Vector3(0,1,0),speed * delta)
