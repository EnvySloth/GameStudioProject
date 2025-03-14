extends StaticBody3D
class_name FloorButton

@onready var active_collider: CollisionShape3D = $ActiveCollider
@onready var deactive_collider: CollisionShape3D = $DeactiveCollider

@onready var button_deactive_mesh: MeshInstance3D = $ButtonDeactive
@onready var button_active_mesh: MeshInstance3D = $ButtonActive
@onready var button_glued_mesh: MeshInstance3D = $ButtonGlued

@onready var on_activartion_streamer: AudioStreamPlayer3D = $OnActivartionStreamer
const activation_sound = preload("res://assets/button-click-289742.mp3")
const deactivation_sound = preload("res://assets/button-click-289742 (mp3cut.net).mp3")
const squish_sound = preload("res://assets/gooey-squish-14820.mp3")

@onready var identfier : Identifier = $Identifier

var linkColor : Color

var currentActivators : Array = []
var activated: bool = false

var glued: bool = false
var currentGumBall: GumBall


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setDeactivated()

func setLinkColor(color : Color) -> void:
	linkColor = color
	identfier.updateColor(linkColor)

func setGlued(gumBall : GumBall) -> bool:
	if(not activated or glued):
		return false
			
	on_activartion_streamer.stream = squish_sound
	on_activartion_streamer.play()
	
	glued = true
	activated = true
	currentGumBall = gumBall
	
	active_collider.set_deferred("disable", false)
	button_glued_mesh.visible = true
	
	deactive_collider.set_deferred("disable", true) 
	button_deactive_mesh.visible = false
	
	button_active_mesh.visible = false
	
	return true

func setUnglued() -> void:
	if glued:
		glued = false
		currentGumBall.reset()
		currentGumBall = null
		on_activartion_streamer.stream = squish_sound
		on_activartion_streamer.play()
		updateState()

func setActivated() -> void:
	on_activartion_streamer.stream = activation_sound 
	on_activartion_streamer.play()
	
	glued = false
	activated = true

	active_collider.set_deferred("disable", false) 
	button_active_mesh.visible = true
	
	deactive_collider.set_deferred("disable", true) 
	button_deactive_mesh.visible = false
	
	button_glued_mesh.visible = false

func setDeactivated() -> void:
	on_activartion_streamer.stream = deactivation_sound
	on_activartion_streamer.play()
	
	glued = false
	activated = false
		
	deactive_collider.set_deferred("disable", false)
	button_deactive_mesh.visible = true
	
	active_collider.set_deferred("disable", true)
	button_active_mesh.visible = false
	
	button_glued_mesh.visible = false

func updateState():
	activated = not currentActivators.is_empty() or glued
	if not glued:
		if activated:
			setActivated()
		else:
			setDeactivated()
			
func interact():
	setUnglued()

func _on_activation_area_body_entered(body: Node3D) -> void:
	if(body.is_in_group("presser")):
		currentActivators.append(body)
	updateState()

func _on_activation_area_body_exited(body: Node3D) -> void:
	if(body.is_in_group("presser")):
		currentActivators.erase(body)
	updateState()
