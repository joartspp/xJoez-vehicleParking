local cfg = require 'data.client.config';
local cb_await = require 'data.shared.callback'.cb_await;

local cfgStopEngine = cfg['stopEngineBeforeParking'];
local cfgUseLoading = cfg['usingLoadingAfterParking'];
local cfgLoading = cfg['loadingAfterParking'];
local cfgGetLimitParking = cfg['LimitVehicleParking'];

local helper = require 'data.shared.helper';

local vehicleParkModules = {};

-- Function to park/unpark vehicle
vehicleParkModules['function'] = function()
    if (not cache.vehicle) then
        return lib.notify({
            title = 'Vehicle Parking System',
            description = 'You must be in a vehicle to park/unpark it.',
            type = 'error'
        });
    end

    if (stateController.vehicleOnParkingNow) then
        return lib.notify({
            title = 'Vehicle Parking System',
            description = 'You are already parking/unparking a vehicle.',
            type = 'error'
        });
    end

    local onEngineStarting = GetIsVehicleEngineRunning(cache.vehicle);

    if (cfgStopEngine and onEngineStarting) then
        return lib.notify({
            title = 'Vehicle Parking System',
            description = 'You must turn off the engine before parking the vehicle.',
            type = 'error'
        });
    end

    local getPlate = lib.getVehicleProperties(cache.vehicle).plate;

    local getOwner = cb_await('xJoez-vehicleParking:cb:getOwnerOfVehicle', false, getPlate);

    if (not getOwner) then
        return lib.notify({
            title = 'Vehicle Parking System',
            description = 'You are not the owner of this vehicle.',
            type = 'error'
        });
    end

    if (cfgGetLimitParking > 0) then
        local getCount = cb_await('xJoez-vehicleParking:cb:getNowVehicleParking', false);
        if (getCount > cfgGetLimitParking) then
            return lib.notify({
                title = 'Vehicle Parking System',
                description = ('You have reached the limit of parking vehicles. (%s)'):format(tostring(cfgGetLimitParking)),
                type = 'error'
            });
        end
    end

    local getParkingState = getOwner['state'] and getOwner['vparking'];

    if (getParkingState) then
        FreezeEntityPosition(cache.vehicle, false);

        local repsonseUnparking = cb_await('xJoez-vehicleParking:cb:spawnAndSetStateVehicleGet', false, {
            plate = getPlate
        });

        if (repsonseUnparking) then
            lib.notify({
                title = 'Vehicle Parking System',
                description = 'You are unparking the vehicle.',
                type = 'success'
            });
        end
    else
        local coordVeh, heading = GetEntityCoords(cache.vehicle), GetEntityHeading(cache.vehicle);

        FreezeEntityPosition(cache.vehicle, true);

        stateController.vehicleOnParkingNow = true;

        if (cfgUseLoading) then
            stateController.loadingParking = true;

            local progessLoading = lib.progressCircle({
                label = cfgLoading['text'],
                duration = cfgLoading['time'],
                position = 'bottom',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                },
                allowFalling = true,
                allowRagdoll = true,
            });

            if (not progessLoading) then
                stateController.loadingParking = false;
                stateController.vehicleOnParkingNow = false;

                FreezeEntityPosition(cache.vehicle, false);
                return lib.notify({
                    title = 'Vehicle Parking System',
                    description = 'You have canceled the parking process.',
                    type = 'error'
                });
            end
        end

        local vehicleLocation = {
            ['x'] = helper.Round(coordVeh['x'], 2),
            ['y'] = helper.Round(coordVeh['y'], 2),
            ['z'] = helper.Round(coordVeh['z'], 2),
            ['h'] = helper.Round(heading, 2)
        }

        local parkingResponse = cb_await('xJoez-vehicleParking:cb:vehicleParking', false, {
            plate = getPlate,
            location = vehicleLocation,
            props = Framework.Functions.GetVehicleProperties(cache.vehicle)
        });

        if (not parkingResponse) then
            FreezeEntityPosition(cache.vehicle, false);
            return lib.notify({
                title = 'Vehicle Parking System',
                description = 'Failed to park the vehicle.',
                type = 'error'
            });
        end

        lib.notify({
            title = 'Vehicle Parking System',
            description = 'You are parking the vehicle.',
            type = 'success'
        });

        stateController.vehicleOnParkingNow = false;
    end

end

return vehicleParkModules