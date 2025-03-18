extends StaticBody3D
class_name FloorButton

@onready var active_collider: CollisionShape3D = $ActiveCollider
@onready var deactive_collider: CollisionShape3D = $DeactiveCollider

@onready var button_deactive_mesh_instance: MeshInstance3D = $ButtonDeactive
@onready var button_active_mesh_instance: MeshInstance3D = $ButtonActive
@onready var button_glued_mesh_instance: MeshInstance3D = $ButtonGlued

@onready var identfier : Identifier = $Identifier

@onready var on_activartion_streamer: AudioStreamPlayer3D = $OnActivartionStreamer
const activation_sound = preload("res://assets/button-click-289742.mp3")
const deactivation_sound = preload("res://assets/button-click-289742 (mp3cut.net).mp3")
const squish_sound = preload("res://assets/gooey-squish-14820.mp3")

var link_color : Color

var activated: bool = false
var current_activators : Array = []

var glued: bool = false
var current_gum_ball: GumBall

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_deactivated()

func set_link_color(color : Color) -> void:
	link_color = color
	identfier.update_color(link_color)

func set_glued(gum_ball : GumBall) -> bool:
	if(not activated or glued):
		return false
			
	on_activartion_streamer.stream = squish_sound
	on_activartion_streamer.play()
	
	glued = true
	activated = true
	current_gum_ball = gum_ball
	
	active_collider.set_deferred("disable", false)
	button_glued_mesh_instance.visible = true
	
	deactive_collider.set_deferred("disable", true) 
	button_deactive_mesh_instance.visible = false
	
	button_active_mesh_instance.visible = false
	
	return true

func set_unglued() -> void:
	if glued:
		glued = false
		current_gum_ball.reset()
		current_gum_ball = null
		on_activartion_streamer.stream = squish_sound
		on_activartion_streamer.play()
		update_state()

func set_activated() -> void:
	on_activartion_streamer.stream = activation_sound 
	on_activartion_streamer.play()
	
	glued = false
	activated = true

	active_collider.set_deferred("disable", false) 
	button_active_mesh_instance.visible = true
	
	deactive_collider.set_deferred("disable", true) 
	button_deactive_mesh_instance.visible = false
	
	button_glued_mesh_instance.visible = false

func set_deactivated() -> void:
	on_activartion_streamer.stream = deactivation_sound
	on_activartion_streamer.play()
	
	glued = false
	activated = false
		
	deactive_collider.set_deferred("disable", false)
	button_deactive_mesh_instance.visible = true
	
	active_collider.set_deferred("disable", true)
	button_active_mesh_instance.visible = false
	
	button_glued_mesh_instance.visible = false

func update_state():
	activated = not current_activators.is_empty() or glued
	if not glued:
		if activated:
			set_activated()
		else:
			set_deactivated()

func interact():
	set_unglued()

func _on_activation_area_body_entered(body: Node3D) -> void:
	if(body.is_in_group("presser")):
		current_activators.append(body)
	update_state()

func _on_activation_area_body_exited(body: Node3D) -> void:
	if(body.is_in_group("presser")):
		current_activators.erase(body)
	update_state()
