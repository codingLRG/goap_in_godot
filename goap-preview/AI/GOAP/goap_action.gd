class_name GoapAction extends Node

@export var precondition_resource : GoapWorldState = GoapWorldState.new()
@export var postcondition_resource : GoapWorldState

var _body : CharacterBody3D

func set_character_body(input_body : CharacterBody3D) -> void:
	_body = input_body

func get_cost() -> int:
	return -1
	
func get_precondition() -> Dictionary:
	return precondition_resource.world_state.duplicate()
	
func get_future_state() -> Dictionary:
	return postcondition_resource.world_state.duplicate()
	
func procedural_viability() -> bool:
	return true
	
func commit_action() -> bool:
	return true
