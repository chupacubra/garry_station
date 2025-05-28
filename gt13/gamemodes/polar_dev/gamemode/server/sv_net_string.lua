-- player info
util.AddNetworkString("gs_health_update")
util.AddNetworkString("gs_inventary_update")
util.AddNetworkString("gs_equipment_update")
util.AddNetworkString("gs_cl_init_stat")
util.AddNetworkString("gs_cl_inventary_request_backpack")
util.AddNetworkString("gs_cl_inventary_use_weapon")
util.AddNetworkString("gs_cl_inventary_drop_ent")
util.AddNetworkString("gs_cl_inventary_update")
util.AddNetworkString("gs_cl_inventary_examine_item")
util.AddNetworkString("gs_cl_inventary_examine_return")
util.AddNetworkString("gs_cl_inventaty_comp_ent_ent")
util.AddNetworkString("gs_cl_weapon_drop")
util.AddNetworkString("gs_cl_weapon_move_inventary")
util.AddNetworkString("gs_ply_pickup_weapon")
util.AddNetworkString("gs_ply_equip_item")
util.AddNetworkString("gs_cl_context_item_action")
util.AddNetworkString("gs_cl_chatprint")
util.AddNetworkString("gs_cl_actions_human")
util.AddNetworkString("gs_ply_hunger")
util.AddNetworkString("gs_ply_equip_draw_sync")
util.AddNetworkString("gs_ply_equip_setup")

util.AddNetworkString("gs_ply_sync_load")
-- ent update info
util.AddNetworkString("gs_ent_client_init")
util.AddNetworkString("gs_ent_client_init_item")
util.AddNetworkString("gs_ent_update_info")
util.AddNetworkString("gs_ent_update_info_item")
util.AddNetworkString("gs_ent_request_examine")
util.AddNetworkString("gs_ent_get_private_info")
util.AddNetworkString("gs_ent_grab")

util.AddNetworkString("gs_ent_container_open")
util.AddNetworkString("gs_ent_container_close")

util.AddNetworkString("gs_wire_action")
util.AddNetworkString("gs_ent_comp_client_send_command")
util.AddNetworkString("gs_ent_comp_client_get_data")
util.AddNetworkString("gs_comp_show_derma")
util.AddNetworkString("gs_fabricator_update")

util.AddNetworkString("gs_connect_ent")

--hands
util.AddNetworkString("gs_hand_draw_model")
util.AddNetworkString("gs_hand_vm")
util.AddNetworkString("gs_hand_item_make_action")

util.AddNetworkString("gs_hands_model_update")


--some equip
util.AddNetworkString("gs_equip_functions")
util.AddNetworkString("gs_eq_med_glasses_sensors")

--weapon
--[[
util.AddNetworkString("gs_weapon_base_comp_dataent")
util.AddNetworkString("gs_weapon_base_effect")
util.AddNetworkString("gs_weapon_base_strip_magazine")
util.AddNetworkString("gs_weapon_base_set_magazine_model")
util.AddNetworkString("gs_weapon_base_weapon_dropped")
--util.AddNetworkString("gs_hands_punch_anim")
--]]

//util.AddNetworkString("gs_swep_update_wm")

--subsystems
util.AddNetworkString("gs_sys_chem_list")

util.AddNetworkString("gs_sys_corpse_create")
util.AddNetworkString("gs_sys_corpse_action")

util.AddNetworkString("gs_sys_task_send")
util.AddNetworkString("gs_sys_task_end")

util.AddNetworkString("gs_sys_char_send") -- 2x

--special netstring for spec entity
--[[
    rethink this, need simple makefunc(id)
]]
util.AddNetworkString("gs_ent_mc_exam_parts")

--round system
util.AddNetworkString("gs_round_status")

-- derma menu handler
util.AddNetworkString("gs_cl_f_button")
util.AddNetworkString("gs_cl_derma_handler")
util.AddNetworkString("gs_cl_derma_open")

util.AddNetworkString("gs_cl_show_notify")



// new strings
util.AddNetworkString("gs_ent_run_callback")




