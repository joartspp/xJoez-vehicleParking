local vehicleGpsModules = {};

local cb_await = require 'data.shared.callback'.cb_await;
local helper = require 'data.shared.helper';

local menuGpsVehicle<const> = 'gps_location_menu';

vehicleGpsModules['function'] = function ()
    local getAllOwnerOfVehicles = cb_await('xJoez-vehicleParking:cb:getAllVehiclesOwner', false);
    if (not getAllOwnerOfVehicles) then
        return lib.notify({
            title = 'Vehicle Parking System',
            description = 'You do not have any vehicles.',
            type = 'error'
        });
    end

    local coordsPed = GetEntityCoords(cache.ped);

    local realignData = {};
    for _, dataVehicle in pairs(getAllOwnerOfVehicles) do
        local deCodeLocation = nil;
        local vehCoordVec4 = nil;
        if ((dataVehicle['state'] and dataVehicle['vparking'])) then
            deCodeLocation = json.decode(dataVehicle.parking_coord);
            vehCoordVec4 = vec4(deCodeLocation['x'], deCodeLocation['y'], deCodeLocation['z'], deCodeLocation['h']);
        end

        realignData[#realignData+1] = {
            title = ("%s - %s | %s"):format(dataVehicle['plate'], dataVehicle['vehicle'], ((dataVehicle['state'] and dataVehicle['vparking']) and 'In Parking') or 'Not In Parking'),
            description = "Select this vehicle to show and mark in maps.",
            icon = 'map',
            metadata = (dataVehicle['state'] and dataVehicle['vparking']) and {
                {label = 'Distance', value = ('Distance: ~%s'):format(helper.Round(#(coordsPed - vehCoordVec4['xyz']) / 1000, 2) .. 'km')},
            } or nil,
            onSelect = function()
                if (dataVehicle.state and dataVehicle.vparking) then
                    SetNewWaypoint(vehCoordVec4['x'], vehCoordVec4['y']);
                    lib.notify({
                        title = 'Vehicle Parking System',
                        description = 'Vehicle location has been marked in maps.',
                        type = 'success'
                    });
                else
                    lib.notify({
                        title = 'Vehicle Parking System',
                        description = 'Vehicle is not in parking.',
                        type = 'error'
                    });
                end
            end
        }
    end

    lib.registerContext({
        id = menuGpsVehicle,
        title = 'Vehicle GPS',
        options = realignData
    });

    lib.showContext(menuGpsVehicle);
end

return vehicleGpsModules