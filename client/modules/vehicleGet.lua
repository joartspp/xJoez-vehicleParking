local vehicleGetModules = {};
local cb_await = require 'data.shared.callback'.cb_await;
local helper = require 'data.shared.helper';

local FunctionClient = require 'data.client.function';

local menuGetVehicle<const> = 'get_vehicle_menu';

-- Function to take damage on vehicle
local function takeDamageVehicle(currentVehicle, vehicle, data)
    local engine = data.engine + 0.0
    local body = data.body + 0.0

    if (not data.vtowing_repaired) then
        for k, v in pairs(vehicle.doors) do
            if v then
                SetVehicleDoorBroken(currentVehicle, k, true)
            end
        end
        for k, v in pairs(vehicle.tyres) do
            if v then
                local random = math.random(1, 1000)
                SetVehicleTyreBurst(currentVehicle, tonumber(k), true, random)
            end
        end
        for k, v in pairs(vehicle.windows) do
            if not v then
                SmashVehicleWindow(currentVehicle, k)
            end
        end
    else
        SetVehicleFixed(currentVehicle)
        SetVehicleDeformationFixed(currentVehicle)
    end

    SetVehicleEngineHealth(currentVehicle, engine)
    SetVehicleBodyHealth(currentVehicle, body)
end

-- Function to get vehicle on parking
local function getVehicleOnParking(plate, location, props, model, dataVehicle)
    local checkSpawnOnServer = cb_await('xJoez-vehicleParking:cb:checkSpawnedVehicleOnServer', false, {
        plate = plate
    });

    if (checkSpawnOnServer) then
        return lib.notify({
            title = 'Vehicle Parking System',
            description = 'Your vehicle is already spawned on the server.',
            type = 'error'
        });
    end

    Framework.Functions.SpawnVehicle(model, function (vehicle)
        Framework.Functions.SetVehicleProperties(vehicle, props)
        local setStateOutParking = cb_await('xJoez-vehicleParking:cb:spawnAndSetStateVehicleGet', false, {
            plate = plate
        })
        takeDamageVehicle(vehicle, props, dataVehicle)
        FunctionClient.SetFuel(vehicle, dataVehicle.fuel)
        FunctionClient.SetOwnerGiveKey(plate)
        if (setStateOutParking) then
            lib.notify({
                title = 'Vehicle Parking System',
                description = 'Your vehicle has been spawned.',
                type = 'success'
            });
        end
    end, location, true);
end

-- Function to get vehicle modules
vehicleGetModules['function'] = function ()
    local getVehicleList = cb_await('xJoez-vehicleParking:cb:getVehicleInParking', false);
    if (not getVehicleList) then
        return lib.notify({
            title = 'Vehicle Parking System',
            description = 'You have no vehicles in the parking.',
            type = 'error'
        });
    end

    local realignData = {};
    local coordPed = GetEntityCoords(cache.ped);
    for _, data in ipairs(getVehicleList) do
        local props = json.decode(data.mods);
        local plate = data.plate;
        local location = json.decode(data.parking_coord);
        local reLocationVec4 = vec4(location.x, location.y, location.z, location.h)

        realignData[#realignData + 1] = {
            title = ("%s - %s"):format(plate, data.vehicle),
            description = "Distance from parking location: ~" .. helper.Round(#(coordPed - reLocationVec4['xyz']) / 1000, 2) .. "km",
            icon = 'car',
            onSelect = function()
                getVehicleOnParking(plate, reLocationVec4, props, data.vehicle, data)
            end
        }
    end

    lib.registerContext({
        id = menuGetVehicle,
        title = 'Vehicle Get',
        options = realignData
    });

    lib.showContext(menuGetVehicle);
end

return vehicleGetModules