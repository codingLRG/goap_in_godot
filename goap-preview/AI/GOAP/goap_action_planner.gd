extends Node

enum ToDoAdjustment {Add,Flip,Keep}

class StateNodeObject:
	var action : GoapAction
	var to_do : Dictionary
	var state : Dictionary
	var last_node : StateNodeObject
	
	func _init(to_do : Dictionary, state : Dictionary, action : GoapAction = null, last_node : StateNodeObject = null) -> void:
		self.to_do = to_do
		self.state = state
		self.action = action
		self.last_node = last_node
		
	func get_total_cost(cost : float = 0) -> float:
		# If not root
		if not last_node == null:
			return get_total_cost(action.get_cost() + get_heuristic() + cost)
		return cost
		
	func has_action_been_taken(action : GoapAction) -> bool:
		# If not root
		if not last_node == null:
			if self.action == action:
				return true
			else:
				return last_node.has_action_been_taken(action)
		return false
		
	## To implement
	func get_heuristic() -> float:
		return 0
	
	func get_state() -> Dictionary:
		return state.duplicate()
	
## Working backwards from goal to current

# Take in GoapWorldState.world_state, not the GoapWorldState
func planning_stage(goal_state : Dictionary, current_state : Dictionary, action_list : Array[GoapAction]):
	var reference_point : Dictionary = get_to_do_dictionary(goal_state,current_state)
	var to_do_list : Dictionary = reference_point.duplicate()
	
	# Explored = lowest possible cost for state
	# Key = State, Value = StateNodeObject
	var explored_options : Dictionary = {}
	# Discovered = next step to finding lowest costed state
	var discovered_options : Dictionary = {}
	
	var root_state_node : StateNodeObject = StateNodeObject.new(to_do_list,goal_state)
	
	while still_need_to_do(to_do_list):
		var dup_list : Array[GoapAction] = action_list.duplicate()
		# Filter out if action can be taken and if the action has already been taken
		dup_list.filter(func(action : GoapAction):
			return compatible_state(root_state_node.get_state(),action.get_future_state()) and not root_state_node.has_action_been_taken(action))
			
		# Check to see if there are no new potential actions and if there's no new options to explore
		if discovered_options.size() == 0 and dup_list.size() == 0:
			push_warning("No Plan Made")
			return []
		for action : GoapAction in dup_list:
			var new_state = action.get_precondition()
			new_state.merge(root_state_node.get_state())
			# No way a explored option has a higher cost or else we wouldn't have explored it
			if explored_options[new_state]:
				continue
			if discovered_options.has(new_state):
				var discovered_node : StateNodeObject = discovered_options[new_state]
				if discovered_node.get_total_cost() <= action.get_cost() + root_state_node.get_total_cost():
					continue
			discovered_options[new_state] = StateNodeObject.new(get_to_do_dictionary(new_state,current_state),new_state,action,root_state_node)
		
		
		var lowest_cost : int = -1
		var lowest_key : Dictionary = {}
		for key in discovered_options.keys():
			if lowest_cost == -1 or lowest_cost > discovered_options[key].get_total_cost():
				lowest_cost = discovered_options[key].get_total_cost()
				lowest_key.assign(key)
		explored_options[root_state_node.get_state()] = true
		root_state_node = discovered_options[lowest_cost]
		discovered_options.erase(lowest_key)
			#discovered_options.append(new_state_object)
		#discovered_options.sort_custom(func(a : StateNodeObject, b : StateNodeObject):
			#return a.get_total_cost() < b.get_total_cost()
			#)

	var plan_of_action : Array[GoapAction] = []
	while root_state_node.last_node != null:
		plan_of_action.append(root_state_node.action)
		root_state_node = root_state_node.last_node
	return plan_of_action

func get_to_do_dictionary(point_from : Dictionary, point_to : Dictionary) -> Dictionary:
	var from_keys : Array = point_from.keys()
	var to_do : Dictionary = {}
	
	for key in from_keys:
		if point_to[key] == null:
			to_do[key] = ToDoAdjustment.Add
		else:
			if point_to[key] != point_from[key]:
				to_do[key] = ToDoAdjustment.Flip
			else:
				to_do[key] = ToDoAdjustment.Keep
	return to_do

func compatible_state(point_from : Dictionary, point_to : Dictionary) -> bool:
	var from_keys : Array = point_from.keys()
	
	for key in from_keys:
		if point_to[key] == null:
			return false
		else:
			if point_to[key] != point_from[key]:
				return false
	return true

func still_need_to_do(to_do_list : Dictionary) -> bool:
	for key in to_do_list.keys():
		if to_do_list[key] == ToDoAdjustment.Keep:
			continue
		return true
	return false
