@tool
class_name PluginFASLConfigHelper


const ID_CREATE_SAVE_LOAD_MANAGER : int = 1
const ID_GENERATE_SERIALIZE_FUNCTION : int = 2


const SAVE_LOAD_MANAGER_SCRIPT_NAME : String = "save_load_manager.gd"

const SAVE_FILE_NAME : String = "save.sav"
const SAVE_FILE_PASSWORD : String = "no password"

const AUTOLOAD_SAVE_LOAD_MANAGER_NAME : String = "SaveLoadManager"


const FUNCTION_SERIALIZE_TEMPLATE : String = """
func serialize_to_dict() -> Dictionary:
	return {{serialize_line}
	}
	pass
"""


const SERIALIZE_ARRAY_LINE : String = """
		"{var_name}" : (func() -> Array[Dictionary]:
			var res : Array[Dictionary]
			for temp : {var_type} in {var_name}:
				res.append(temp.serialize_to_dict())
			return res).call(),"""


const FUNCTION_DESERIALIZE_TEMPLATE : String = """
static func deserialize_from_dict(dict_data: Dictionary) -> {self_class_name}:
	var res_data : {self_class_name} = {self_class_name}.new()
	{deserialize_line}
	return res_data
	pass
"""


const DESERIALIZE_ARRAY_LINE : String = """
	if dict_data.has("{var_name}"):
		res_data.{var_name} = (func() -> Array[{var_type}]:
			var res : Array[{var_type}]
			for temp : Dictionary in dict_data["{var_name}"]:
				res.append({var_type}.deserialize_from_dict(temp))
			return res).call()"""


const SAVE_LOAD_MANAGER_SCRIPT_DATA : String = """extends Node

const SAVE_PATH : String = "user://{save_file_name}"
const SAVE_TOTAL_NUM : int = {max_save_num}
const PASS : String = "{save_file_pass}"

var current_save_id : int = -1
var current_save : {save_data_class_name} = null

var dict_id_to_save : Dictionary


func _enter_tree() -> void:
	load_data()
	pass


func _exit_tree() -> void:
	save_data()
	pass


# 持久化存档到本地文件
func save_data() -> void:
	var file : FileAccess = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.WRITE, PASS)
	if is_effective_save_id(current_save_id) and current_save:
		dict_id_to_save[current_save_id] = current_save.serialize_to_dict()
	file.store_var(dict_id_to_save)
	file.close()
	pass


# 从本地件加载存档到内存
func load_data() -> void:
	var data : Variant
	
	var file : FileAccess = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.READ, PASS)
	if file == null:
		return
	
	if file.get_position() < file.get_length():
		data = file.get_var()
	file.close()
	
	if data and data is Dictionary:
		dict_id_to_save = data as Dictionary
	pass


# 判读指定存档id是否有效
func is_effective_save_id(save_id: int) -> bool:
	if save_id >= 0 and save_id < SAVE_TOTAL_NUM:
		return true
	return false


# 判断指定存档id是否已经存在
func is_existent_save_id(save_id: int) -> bool:
	if not is_effective_save_id(save_id):
		return false
	if dict_id_to_save.has(save_id):
		return true
	return false


# 判断当前存档是否是有效的
func is_effective_current_save() -> bool:
	if not is_effective_save_id(current_save_id):
		return false
	if not current_save:
		return false
	return true


# 新建指定存档id存档 若存档id已存在则将被覆盖
func new_save(save_id: int) -> void:
	if not is_effective_save_id(save_id):
		return
	
	current_save_id = save_id
	current_save = {save_data_class_name}.new()
	dict_id_to_save[current_save_id] = current_save.serialize_to_dict()
	pass


# 将当前存档切换为指定的存档id和存档数据
func switch_save(save_id: int) -> void:
	if not is_existent_save_id(save_id):
		return
	
	if save_id == current_save_id:
		current_save = {save_data_class_name}.deserialize_from_dict(dict_id_to_save[save_id])
		return
	
	if is_effective_current_save():
		dict_id_to_save[current_save_id] = current_save.serialize_to_dict()
	
	current_save_id = save_id
	current_save = {save_data_class_name}.deserialize_from_dict(dict_id_to_save[save_id])
	pass


# 修改当前存档id为指定存档id进行存档覆盖
func cover_save(save_id: int) -> void:
	if not is_effective_save_id(save_id):
		return
	
	if not is_effective_current_save():
		return
	
	current_save_id = save_id
	dict_id_to_save[current_save_id] = current_save.serialize_to_dict()
	pass


# 移除指定存档id的存档
func remove_save(save_id: int) -> void:
	if not is_effective_save_id(save_id):
		return
	
	dict_id_to_save.erase(save_id)
	pass
"""
