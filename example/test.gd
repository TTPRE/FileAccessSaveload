extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var save_id : int = 0
	if SaveLoadManager.is_existent_save_id(save_id):
		SaveLoadManager.switch_save(save_id)
	else :
		SaveLoadManager.new_save(save_id)
	
	print(SaveLoadManager.current_save.i_data)
	print(SaveLoadManager.current_save.f_data)
	print(SaveLoadManager.current_save.v2_data)
	print(SaveLoadManager.current_save.s_data)
	print(SaveLoadManager.current_save.arr_data)
	print(SaveLoadManager.current_save.dict_data_test)
	print(SaveLoadManager.current_save.arr_all_player_data)
	print(SaveLoadManager.current_save.player_data)
	print(SaveLoadManager.current_save.player_data.player_id)
	print(SaveLoadManager.current_save.player_data.player_name)
	print(SaveLoadManager.current_save.player_data.player_score)
	
	SaveLoadManager.current_save.i_data = 10000
	SaveLoadManager.current_save.f_data = 0.2222
	SaveLoadManager.current_save.v2_data = Vector2(100, 100)
	SaveLoadManager.current_save.s_data = "New Data"
	SaveLoadManager.current_save.arr_data = [11, 22]
	SaveLoadManager.current_save.dict_data_test = {"aa": 11111, "bb": 22222}
	SaveLoadManager.current_save.arr_all_player_data.append(PlayerData.new())
	SaveLoadManager.current_save.player_data.player_id = 10086
	SaveLoadManager.current_save.player_data.player_name = "xiaoming"
	SaveLoadManager.current_save.player_data.player_score = 12132312313
	
	SaveLoadManager.save_data()
	pass # Replace with function body.
