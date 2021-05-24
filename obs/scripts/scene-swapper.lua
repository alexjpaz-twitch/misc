--[[
      OBS Studio Lua script : simple scene swapper on a timer
      Author: Alexander Paz
      Version: 0.1
      Released: 2020-05-24
--]]

local obs = obslua
local source, sceneItems, interval
local sceneItemIndex = 0

function swap()
    for k, sceneItem in pairs(sceneItems) do
        if sceneItem then
            if sceneItemIndex ~= (k-1) then
                obs.obs_sceneitem_set_visible(sceneItem, false)
            else
                obs.obs_sceneitem_set_visible(sceneItem, true)

            end
        else
            obs.remove_current_callback()
        end
    end

    sceneItemIndex = (sceneItemIndex + 1) % #sceneItems
end

function handle_scene_change()
    obs.timer_remove(swap)

    local src = obs.obs_get_source_by_name(source)

    sceneItems = {}

    if src then
        local scene = obs.obs_scene_from_source(src)
        obs.obs_source_release(src)
        if scene then

            local item_list = obs.obs_scene_enum_items(scene)

            for k, item in pairs(item_list) do
                local item_source = obs.obs_sceneitem_get_source(item)
                local item_name = obs.obs_source_get_name(item_source)

                table.insert(sceneItems, item)
            end

            obs.sceneitem_list_release(item_list);
        end
    end

    obs.timer_add(swap, interval)
end

function handle_event(event)
	if event == obs.OBS_FRONTEND_EVENT_SCENE_CHANGED then
		handle_scene_change()
	end
end

function script_load(settings)
    obs.obs_frontend_add_event_callback(handle_event)
    script_update(settings)
end
-- called on unload
function script_unload()
end


-- called when settings changed
function script_update(settings)
	source = obs.obs_data_get_string(settings, "scene")
    interval = obs.obs_data_get_int(settings, "interval")
    handle_scene_change()
end


-- return description shown to user
function script_description()
	return "Swap Scene"
end


-- define properties that user can change
function script_properties()
	local props = obs.obs_properties_create()
	obs.obs_properties_add_text(props, "scene", "Scene", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_int(props, "interval", "Interval (ms)", 100, 1000000, 10)
	return props
end


-- set default values
function script_defaults(settings)
	obs.obs_data_set_default_string(settings, "source", "SwapScene")
    obs.obs_data_set_default_int(settings, "interval", 5000)
end


-- save additional data not set by user
function script_save(settings)
end
