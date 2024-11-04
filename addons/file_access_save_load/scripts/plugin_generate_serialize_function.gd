@tool
class_name PluginGenerateSerializeFunction extends Node

var editor_file_dialog : EditorFileDialog


func _enter_tree() -> void:
	editor_file_dialog = EditorFileDialog.new()
	self.add_child(editor_file_dialog)
	
	editor_file_dialog.get_line_edit().editable = false
	editor_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	editor_file_dialog.title = "Generate Serialize Function"
	editor_file_dialog.filters = PackedStringArray(["*.gd"]) 
	editor_file_dialog.confirmed.connect(generate_serialize_function)
	pass


func show_editor_file_dialog(id: int) -> void:
	if id != PluginFASLConfigHelper.ID_GENERATE_SERIALIZE_FUNCTION:
		return
	
	editor_file_dialog.popup_file_dialog()
	pass


func generate_serialize_function() -> void:
	var arr_file_data_line : Array[String]
	var file_data_str : String
	var custom_data_class_path : String = editor_file_dialog.current_path
	var file_r : FileAccess = FileAccess.open(custom_data_class_path, FileAccess.READ)
	while file_r.get_position() < file_r.get_length():
		arr_file_data_line.append(file_r.get_line())
	file_data_str = file_r.get_as_text()
	file_r.close()
	
	# remove serialize func and deserialize func
	var func_regex = RegEx.new()
	func_regex.compile("func serialize_to_dict[\\s\\S]*?\n\tpass")
	var serialize_reg_ex_match : RegExMatch = func_regex.search(file_data_str)
	if serialize_reg_ex_match:
		file_data_str = file_data_str.replace(serialize_reg_ex_match.get_string(), "")
	func_regex.compile("static func deserialize_from_dict[\\s\\S]*?\n\tpass")
	var deserialize_reg_ex_match : RegExMatch = func_regex.search(file_data_str)
	if deserialize_reg_ex_match:
		file_data_str = file_data_str.replace(deserialize_reg_ex_match.get_string(), "")
	
	file_data_str = file_data_str.rstrip("\n")
	
	# add serialize func
	var serialize_line : String = ""
	for data_line : String in arr_file_data_line:
		if not data_line.begins_with("var "):
			continue
		var new_line : String = ""
		data_line = data_line.trim_prefix("var ")
		var variable_name : String = data_line.substr(0, data_line.find(":")).replace(" ","")
		var type_index_end : int = data_line.find("=") - data_line.find(":") - 1 if data_line.contains("=") else -1
		var variable_type : String = data_line.substr(data_line.find(":") + 1, type_index_end).replace(" ","")
		
		if (variable_type == "int" or
				variable_type == "float" or
				variable_type == "bool" or
				variable_type == "String" or
				variable_type == "Vector2" or
				variable_type == "Vector2i" or
				variable_type == "Vector3" or
				variable_type == "Vector3i" or
				variable_type == "Dictionary"):
			new_line = "\n\t\t\"{var_name}\" : {var_name},".format({"var_name":variable_name})
		elif variable_type.begins_with("Array") and not variable_type == "Array":
			variable_type = variable_type.trim_prefix("Array[")
			variable_type = variable_type.trim_suffix("]")
			if (variable_type == "int" or
					variable_type == "float" or
					variable_type == "bool" or
					variable_type == "String" or
					variable_type == "Vector2" or
					variable_type == "Vector2i" or
					variable_type == "Vector3" or
					variable_type == "Vector3i"):
				new_line = "\n\t\t\"{var_name}\" : {var_name},".format({"var_name":variable_name})
			else:
				new_line = PluginFASLConfigHelper.SERIALIZE_ARRAY_LINE.format({"var_name":variable_name, "var_type":variable_type})
		else:
			new_line = "\n\t\t\"{var_name}\" : {var_name}.serialize_to_dict(),".format({"var_name":variable_name})
		
		serialize_line += new_line
	
	file_data_str += "\n\n"
	file_data_str += PluginFASLConfigHelper.FUNCTION_SERIALIZE_TEMPLATE.format({"serialize_line":serialize_line})
	
	# add deserialize func
	var deserialize_line : String = ""
	for data_line : String in arr_file_data_line:
		if not data_line.begins_with("var "):
			continue
		var new_line : String = ""
		data_line = data_line.trim_prefix("var ")
		var variable_name : String = data_line.substr(0, data_line.find(":")).replace(" ","")
		var type_index_end : int = data_line.find("=") - data_line.find(":") - 1 if data_line.contains("=") else -1
		var variable_type : String = data_line.substr(data_line.find(":") + 1, type_index_end).replace(" ","")
		if (variable_type == "int" or
					variable_type == "float" or
					variable_type == "bool" or
					variable_type == "String" or
					variable_type == "Vector2" or
					variable_type == "Vector2i" or
					variable_type == "Vector3" or
					variable_type == "Vector3i" or
					variable_type == "Dictionary"):
			new_line += "\n\tif dict_data.has(\"{var_name}\"):\n\t\tres_data.{var_name} = dict_data[\"{var_name}\"]".format({"var_name":variable_name})
		elif variable_type.begins_with("Array") and not variable_type == "Array":
			variable_type = variable_type.trim_prefix("Array[")
			variable_type = variable_type.trim_suffix("]")
			if (variable_type == "int" or
					variable_type == "float" or
					variable_type == "bool" or
					variable_type == "String" or
					variable_type == "Vector2" or
					variable_type == "Vector2i" or
					variable_type == "Vector3" or
					variable_type == "Vector3i"):
				new_line += "\n\tif dict_data.has(\"{var_name}\"):\n\t\tres_data.{var_name} = dict_data[\"{var_name}\"]".format({"var_name":variable_name})
			else:
				new_line = PluginFASLConfigHelper.DESERIALIZE_ARRAY_LINE.format({"var_name":variable_name, "var_type":variable_type})
		else:
			new_line += "\n\tif dict_data.has(\"{var_name}\"):\n\t\tres_data.{var_name} = {var_type}.deserialize_from_dict(dict_data[\"{var_name}\"])".format({"var_name":variable_name, "var_type":variable_type})
		
		deserialize_line += new_line
	
	var self_class_name : String = ""
	for data_line : String in arr_file_data_line:
		if data_line.begins_with("class_name "):
			self_class_name = data_line.replace("class_name ", "")
			self_class_name = self_class_name.substr(0, self_class_name.find(" extends"))
			self_class_name = self_class_name.replace(" ", "")
			break
	
	file_data_str += "\n\n"
	file_data_str += PluginFASLConfigHelper.FUNCTION_DESERIALIZE_TEMPLATE.format({"self_class_name":self_class_name, "deserialize_line":deserialize_line})
	
	var file_w : FileAccess = FileAccess.open(custom_data_class_path, FileAccess.WRITE)
	file_w.store_line(file_data_str)
	file_w.close()
	
	EditorInterface.get_resource_filesystem().scan()
	pass
