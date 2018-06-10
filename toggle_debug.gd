# Copyright 2018 GodotSharp.

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

tool
extends EditorPlugin

var item_text = "Wait for debugger"
var wait_setting_path = "mono/debugger_agent/wait_for_debugger"

var popup_menu
var item_id

func _enter_tree():
    popup_menu = find_mono_menu(get_tree().root)
    if popup_menu == null:
        return
    item_id = find_available_id()
    popup_menu.add_separator()
    popup_menu.add_check_item(item_text, item_id)
    popup_menu.connect("about_to_show", self, "on_popup_about_to_show")
    popup_menu.connect("id_pressed", self, "on_popup_id_pressed")
    
func _exit_tree():
    var index = popup_menu.get_item_index(item_id)
    popup_menu.remove_item(index)
    if popup_menu.is_item_separator(index - 1):
        popup_menu.remove_item(index - 1)

func on_popup_about_to_show():
    var index = popup_menu.get_item_index(item_id)
    var wait_checked = get_wait_for_debugger()
    popup_menu.set_item_checked(index, wait_checked)

func on_popup_id_pressed(id):
    if id != item_id:
        return
    var index = popup_menu.get_item_index(item_id)
    var checked = popup_menu.is_item_checked(index)
    set_wait_for_debugger(not checked)

func find_mono_menu(node):
    # return get_node("/root/EditorNode/@@5/@@6/@@14/@@15/MenuButton/PopupMenu")
    if node.has_method("get_text"):
        if node.get_text() == "Mono" and node is MenuButton:
            return node.get_node("PopupMenu")

    if node.has_method("get_children"):        
        for c in node.get_children():
            var val = find_mono_menu(c)
            if val != null:
                return val

func find_available_id():
    var heighest = -1
    for i in range(popup_menu.get_item_count()):
        heighest = max(heighest, popup_menu.get_item_id(i))
    return heighest + 1

func get_wait_for_debugger():
    if ProjectSettings.has_setting(wait_setting_path):
        return ProjectSettings.get_setting(wait_setting_path)
    return false

func set_wait_for_debugger(value):
    ProjectSettings.set_setting(wait_setting_path, value)
