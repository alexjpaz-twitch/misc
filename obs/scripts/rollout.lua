--[[
      OBS Studio Lua script : rotate an object with hotkeys
      Author: John Craig
      Version: 0.2 (added reset)
      Released: 2018-09-23
--]]


local obs = obslua
local source, increment, interval, reset, debug
local sceneItems
local direction = 1
local hk = {}


-- if you are extending the script, you can add more hotkeys here
-- then add actions in the 'onHotKey' function further below
local hotkeys = {
	ROTATE_cw = "Rotate object clockwise",
	ROTATE_ccw = "Rotate object counter clockwise",
	ROTATE_stop = "Stop rotation",
	ROTATE_reset = "Reset rotation",
}


local function currentSceneName()
	local src = obs.obs_frontend_get_current_scene()
	local name = obs.obs_source_get_name(src)
	obs.obs_source_release(src)
	return name
end


local function findSceneItems(itemName)
    sceneItems = {}
	local src = obs.obs_get_source_by_name(currentSceneName())
	if src then
		local scene = obs.obs_scene_from_source(src)
		obs.obs_source_release(src)
		if scene then

            local item_list = obs.obs_scene_enum_items(scene)

            for k, item in pairs(item_list) do
                local item_source = obs.obs_sceneitem_get_source(item)
                local item_name = obs.obs_source_get_name(item_source)

                local matches = string.match(item_name, source)

                if matches then
                    table.insert(sceneItems, item)
                end
            end

            obs.sceneitem_list_release(item_list);
        end
	end
end


local function rotate()
    for k, sceneItem in pairs(sceneItems) do
        if sceneItem then
            local current_rot = obs.obs_sceneitem_get_rot(sceneItem)
            local r = current_rot + increment * direction

            r = r % 360

            obs.obs_sceneitem_set_rot(sceneItem, r)
        else
            obs.remove_current_callback()
        end
    end
end


-- add any custom actions here
local function onHotKey(action)
	obs.timer_remove(rotate)

	if debug then obs.script_log(obs.LOG_INFO, string.format("Hotkey : %s", action)) end
	if action == "ROTATE_cw" then
		direction = 1
		obs.timer_add(rotate, interval)
	elseif action == "ROTATE_ccw" then
		direction = -1
		obs.timer_add(rotate, interval)
	elseif action == "ROTATE_reset" and sceneItem then
        for k, sceneItem in pairs(sceneItems) do
            obs.obs_sceneitem_set_rot(sceneItem, reset)
        end
	end
end

function handle_scene_change()
    findSceneItems()
    onHotKey("ROTATE_cw")
end

function handle_event(event)
	if event == obs.OBS_FRONTEND_EVENT_SCENE_CHANGED then
		handle_scene_change()
	end
end

-- called on startup
function script_load(settings)
    obs.obs_frontend_add_event_callback(handle_event)
    script_update(settings)
end


-- called on unload
function script_unload()
end


-- called when settings changed
function script_update(settings)
	source = obs.obs_data_get_string(settings, "source")
	increment = obs.obs_data_get_int(settings, "increment")
	interval = obs.obs_data_get_int(settings, "interval")
	reset = obs.obs_data_get_int(settings, "reset")
	debug = obs.obs_data_get_bool(settings, "debug")
    handle_scene_change()
end


-- return description shown to user
function script_description()
	return "Rotate an object with hotkeys"
end


-- define properties that user can change
function script_properties()
	local props = obs.obs_properties_create()
	obs.obs_properties_add_text(props, "source", "Object to rotate", obs.OBS_TEXT_DEFAULT)
	obs.obs_properties_add_int(props, "increment", "Increment", 0, 90, 1)
	obs.obs_properties_add_int(props, "interval", "Interval (ms)", 2, 500, 1)
	obs.obs_properties_add_bool(props, "debug", "Debug")
	return props
end


-- set default values
function script_defaults(settings)
	obs.obs_data_set_default_string(settings, "source", "ROLLOUT")
	obs.obs_data_set_default_int(settings, "increment", 2)
	obs.obs_data_set_default_int(settings, "interval", 5)
	obs.obs_data_set_default_int(settings, "reset", 0)
	obs.obs_data_set_default_bool(settings, "debug", false)
end


-- save additional data not set by user
function script_save(settings)
end
