@tool
class_name PluginCreateSaveLoadManager extends Node


var instance_scene_plugin_create_save_load_manager_window : Window


func _enter_tree() -> void:
	instance_scene_plugin_create_save_load_manager_window = load("res://addons/file_access_save_load/scenes/plugin_create_save_load_manager_window/plugin_create_save_load_manager_window.tscn").instantiate()
	self.add_child(instance_scene_plugin_create_save_load_manager_window)
	instance_scene_plugin_create_save_load_manager_window.visible = false
	pass


func show_editor_file_dialog(id: int) -> void:
	if id != PluginFASLConfigHelper.ID_CREATE_SAVE_LOAD_MANAGER:
		return
	
	instance_scene_plugin_create_save_load_manager_window.popup_centered()
	pass
