##----------------------------------------------------##
##   #######     #######      #######      #######    ##
##  ##     ##  ##       ##  ##       ##  ##       ##  ##
##         ##  ##       ##  ##       ##  ##       ##  ##
##   #######   ##       ##  ##       ##  ##       ##  ##
##  ##         ##       ##  ##       ##  ##       ##  ##
##  ##         ##       ##  ##       ##  ##       ##  ##
##  #########    #######      #######      #######    ##
##----------------------------------------------------##
## @Description: 基于FileAccess的存档系统生成插件
## 
## 1.给数据结构类生成序列化和反序列化函数
## ①支持的大部分基础内置类型(int,float,bool,String,Vector2,Vector2i,Vector3,Vector3i)
## 
## ②支持一层结构的Dictionary
## Dictionary的key和value类型不支持Array和Dictionary和自定义数据类
## 
## ③支持一层结构的Array（不建议多层嵌套，以防理解困难和增加出错概率）
## Array的存储数据值的类型不支持Array和Dictionary
## 支持的数据类型(int,float,bool,String,Vector2,Vector2i,Vector3,Vector3i,自定义数据类)
## 
## 2.根据存档数据类生成存档管理者自动加载（AutoLoad）脚本并添加到自动加载列表
##----------------------------------------------------##
## @Auther: 2000
## @Date: 2024-11-02
## @LastEditTime: 2024-11-04
## @Tags: 存档, 生成
## @Version: 1.0.0
## @License: MIT license
## @ContactInformation:
##----------------------------------------------------##
@tool
extends EditorPlugin


var plugin_create_save_load_manager : PluginCreateSaveLoadManager
var plugin_generate_serialize_function : PluginGenerateSerializeFunction


func _enter_tree() -> void:
	initialize()
	add_config_table_csv_menu()
	print("Enable FileAccessSaveLoad")
	pass


func _exit_tree() -> void:
	remove_config_table_csv_menu()
	destroy()
	print("Disable FileAccessSaveLoad")
	pass


func initialize() -> void:
	plugin_create_save_load_manager = PluginCreateSaveLoadManager.new()
	self.add_child(plugin_create_save_load_manager)
	
	plugin_generate_serialize_function = PluginGenerateSerializeFunction.new()
	self.add_child(plugin_generate_serialize_function)
	pass


func destroy() -> void:
	plugin_create_save_load_manager.free()
	plugin_generate_serialize_function.free()
	pass


func add_config_table_csv_menu() -> void:
	var popup_menu_config_table_csv : PopupMenu = PopupMenu.new()
	
	popup_menu_config_table_csv.add_item("Generate Serialize Function", PluginFASLConfigHelper.ID_GENERATE_SERIALIZE_FUNCTION)
	popup_menu_config_table_csv.id_pressed.connect(plugin_generate_serialize_function.show_editor_file_dialog)
	
	popup_menu_config_table_csv.add_item("Create Save Load Manager", PluginFASLConfigHelper.ID_CREATE_SAVE_LOAD_MANAGER)
	popup_menu_config_table_csv.id_pressed.connect(plugin_create_save_load_manager.show_editor_file_dialog)
	
	add_tool_submenu_item("FileAccess Save Load", popup_menu_config_table_csv)
	pass


func remove_config_table_csv_menu() -> void:
	remove_tool_menu_item("FileAccess Save Load")
	pass
