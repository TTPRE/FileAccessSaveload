@tool
class_name PluginCreateSaveLoadManagerWindow extends Window

@onready var line_edit_max_save_number: LineEdit = $Panel/VBoxContainer/MarginContainer/VBoxContainer/MarginContainer2/LineEditMaxSaveNumber
@onready var line_edit_save_file_name: LineEdit = $Panel/VBoxContainer/MarginContainer4/VBoxContainer/MarginContainer2/HBoxContainer/LineEditSaveFileName
@onready var line_edit_save_file_password: LineEdit = $Panel/VBoxContainer/MarginContainer5/VBoxContainer/MarginContainer2/LineEditSaveFilePassword
@onready var line_edit_save_data_script_path: LineEdit = $Panel/VBoxContainer/MarginContainer2/VBoxContainer/MarginContainer2/HBoxContainer/LineEditSaveDataScriptPath
@onready var line_edit_save_load_manger_script_path: LineEdit = $Panel/VBoxContainer/MarginContainer3/VBoxContainer/MarginContainer2/HBoxContainer/LineEditSaveLoadMangerScriptPath

var editor_file_dialog_choose_save_data_script_path : EditorFileDialog
var editor_file_dialog_set_save_load_manager_script_path : EditorFileDialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	editor_file_dialog_choose_save_data_script_path = EditorFileDialog.new()
	self.add_child(editor_file_dialog_choose_save_data_script_path)
	
	editor_file_dialog_choose_save_data_script_path.get_line_edit().editable = false
	editor_file_dialog_choose_save_data_script_path.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	editor_file_dialog_choose_save_data_script_path.title = "Set SaveData Script Path"
	editor_file_dialog_choose_save_data_script_path.disable_overwrite_warning = true
	editor_file_dialog_choose_save_data_script_path.filters = PackedStringArray(["*.gd"]) 
	editor_file_dialog_choose_save_data_script_path.confirmed.connect(set_save_data_script_path)
	
	editor_file_dialog_set_save_load_manager_script_path = EditorFileDialog.new()
	self.add_child(editor_file_dialog_set_save_load_manager_script_path)
	
	editor_file_dialog_set_save_load_manager_script_path.get_line_edit().editable = false
	editor_file_dialog_set_save_load_manager_script_path.get_line_edit().text = PluginFASLConfigHelper.SAVE_LOAD_MANAGER_SCRIPT_NAME
	editor_file_dialog_set_save_load_manager_script_path.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	editor_file_dialog_set_save_load_manager_script_path.title = "Set SaveLoadManger Script Path"
	editor_file_dialog_set_save_load_manager_script_path.disable_overwrite_warning = true
	editor_file_dialog_set_save_load_manager_script_path.filters = PackedStringArray(["*.gd"]) 
	editor_file_dialog_set_save_load_manager_script_path.confirmed.connect(set_save_load_manager_script_path)
	
	
	self.close_requested.connect(self.hide)
	pass # Replace with function body.


func set_save_data_script_path() -> void:
	line_edit_save_data_script_path.text = editor_file_dialog_choose_save_data_script_path.current_path
	pass


func set_save_load_manager_script_path() -> void:
	editor_file_dialog_set_save_load_manager_script_path.get_line_edit().text = PluginFASLConfigHelper.SAVE_LOAD_MANAGER_SCRIPT_NAME
	line_edit_save_load_manger_script_path.text = editor_file_dialog_set_save_load_manager_script_path.current_path
	pass


func create_save_load_manager_script(max_save_number: int, save_file_name: String, save_file_pass: String, save_data_class_name: String, save_load_manager_path: String) -> void:
	var file_save_load_manager : FileAccess = FileAccess.open(save_load_manager_path, FileAccess.WRITE)
	file_save_load_manager.store_line(PluginFASLConfigHelper.SAVE_LOAD_MANAGER_SCRIPT_DATA.format({
		"save_file_name" : save_file_name,
		"max_save_num" : max_save_number,
		"save_file_pass" : save_file_pass,
		"save_data_class_name" : save_data_class_name,
	}))
	file_save_load_manager.close()
	
	var editor_plugin : EditorPlugin = EditorPlugin.new()
	editor_plugin.add_autoload_singleton(PluginFASLConfigHelper.AUTOLOAD_SAVE_LOAD_MANAGER_NAME, save_load_manager_path)
	EditorInterface.get_resource_filesystem().scan()
	pass

func _on_button_choose_save_data_script_path_pressed() -> void:
	editor_file_dialog_choose_save_data_script_path.popup_file_dialog()
	pass # Replace with function body.


func _on_button_set_manager_script_path_pressed() -> void:
	editor_file_dialog_set_save_load_manager_script_path.popup_file_dialog()
	pass # Replace with function body.


func _on_button_ok_pressed() -> void:
	self.hide()
	if line_edit_max_save_number.text.is_empty():
		return
	
	var max_save_number : int = line_edit_max_save_number.text.to_int()
	if max_save_number <= 0:
		return
	
	var save_file_name : String = PluginFASLConfigHelper.SAVE_FILE_NAME
	if not line_edit_save_file_name.text.is_empty():
		save_file_name = line_edit_save_file_name.text
	
	var save_file_pass : String = PluginFASLConfigHelper.SAVE_FILE_PASSWORD
	if not line_edit_save_file_password.text.is_empty():
		save_file_pass = line_edit_save_file_password.text
	
	var save_data_class_name : String
	if line_edit_save_data_script_path.text.is_empty():
		return
	save_data_class_name = get_class_name_from_save_data_path(line_edit_save_data_script_path.text)
	if save_data_class_name.is_empty():
		return
	
	var save_load_manager_script_path : String
	if line_edit_save_load_manger_script_path.text.is_empty():
		return
	save_load_manager_script_path = line_edit_save_load_manger_script_path.text
	if save_load_manager_script_path.is_empty():
		return
	
	create_save_load_manager_script(max_save_number, save_file_name, save_file_pass, save_data_class_name, save_load_manager_script_path)
	pass # Replace with function body.


func _on_button_cancel_pressed() -> void:
	self.hide()
	pass # Replace with function body.


func get_class_name_from_save_data_path(save_data_path: String) -> String:
	var res_class_name : String = ""
	
	if not FileAccess.file_exists(save_data_path):
		return res_class_name
	
	var arr_save_data_line : Array[String]
	var file_save_data : FileAccess = FileAccess.open(save_data_path, FileAccess.READ)
	while file_save_data.get_position() < file_save_data.get_length():
		arr_save_data_line.append(file_save_data.get_line())
	file_save_data.close()
	
	for data_line : String in arr_save_data_line:
		if data_line.contains("class_name "):
			res_class_name = data_line.replace("class_name ", "")
			res_class_name = res_class_name.substr(0, res_class_name.find(" extends"))
			res_class_name = res_class_name.replace(" ", "")
			break
	
	return res_class_name
