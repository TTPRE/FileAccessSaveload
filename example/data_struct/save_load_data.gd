class_name SaveLoadData

var i_data : int = 1
var f_data : float = 1.1
var v2_data : Vector2 = Vector2(1.0, 3.5)
var s_data : String = "This is data"
var arr_data : Array[int] = [1, 2, 3, 5, 6]
var dict_data_test : Dictionary = {
	"aa" : 111,
	"bb" : 222,
}
var arr_all_player_data : Array[PlayerData]

var player_data : PlayerData = PlayerData.new()


func serialize_to_dict() -> Dictionary:
	return {
		"i_data" : i_data,
		"f_data" : f_data,
		"v2_data" : v2_data,
		"s_data" : s_data,
		"arr_data" : arr_data,
		"dict_data_test" : dict_data_test,
		"arr_all_player_data" : (func() -> Array[Dictionary]:
			var res : Array[Dictionary]
			for temp : PlayerData in arr_all_player_data:
				res.append(temp.serialize_to_dict())
			return res).call(),
		"player_data" : player_data.serialize_to_dict(),
	}
	@warning_ignore("unreachable_code")
	pass



static func deserialize_from_dict(dict_data: Dictionary) -> SaveLoadData:
	var res_data : SaveLoadData = SaveLoadData.new()
	
	if dict_data.has("i_data"):
		res_data.i_data = dict_data["i_data"]
	if dict_data.has("f_data"):
		res_data.f_data = dict_data["f_data"]
	if dict_data.has("v2_data"):
		res_data.v2_data = dict_data["v2_data"]
	if dict_data.has("s_data"):
		res_data.s_data = dict_data["s_data"]
	if dict_data.has("arr_data"):
		res_data.arr_data = dict_data["arr_data"]
	if dict_data.has("dict_data_test"):
		res_data.dict_data_test = dict_data["dict_data_test"]
	if dict_data.has("arr_all_player_data"):
		res_data.arr_all_player_data = (func() -> Array[PlayerData]:
			var res : Array[PlayerData]
			for temp : Dictionary in dict_data["arr_all_player_data"]:
				res.append(PlayerData.deserialize_from_dict(temp))
			return res).call()
	if dict_data.has("player_data"):
		res_data.player_data = PlayerData.deserialize_from_dict(dict_data["player_data"])
	return res_data
	@warning_ignore("unreachable_code")
	pass
