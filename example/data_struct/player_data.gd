class_name PlayerData extends Node

var player_id : int
var player_name : String
var player_score : float


func serialize_to_dict() -> Dictionary:
	return {
		"player_id" : player_id,
		"player_name" : player_name,
		"player_score" : player_score,
	}
	@warning_ignore("unreachable_code")
	pass



static func deserialize_from_dict(dict_data: Dictionary) -> PlayerData:
	var res_data : PlayerData = PlayerData.new()
	
	if dict_data.has("player_id"):
		res_data.player_id = dict_data["player_id"]
	if dict_data.has("player_name"):
		res_data.player_name = dict_data["player_name"]
	if dict_data.has("player_score"):
		res_data.player_score = dict_data["player_score"]
	return res_data
	@warning_ignore("unreachable_code")
	pass
