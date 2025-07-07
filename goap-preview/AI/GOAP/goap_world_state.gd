class_name GoapWorldState extends Resource

@export var list_of_states : Array[GoapState] = []

var world_state : Dictionary

func _init() -> void:
	for state in list_of_states:
		world_state[state.flag] = state.condition
