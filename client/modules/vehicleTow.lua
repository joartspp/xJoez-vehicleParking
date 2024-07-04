local vehicleTowModules = {};
local cb_await = require 'data.shared.callback'.cb_await;

local helper = require 'data.shared.helper';
local shConfig = require 'data.shared.config';

local menuTowVehicle<const> = 'tow_vehicle_menu';
local menuTowLocation<const> = 'tow_location_menu';
local menuTowPayment<const> = 'tow_payment_menu';

-- Function to tow vehicle
local function towSelectedVehicle(locationId, plate, methodPayment)
    local responseTowing = cb_await('xJoez-vehicleParking:cb:towingVehicleToTowLocation', false, plate, locationId, methodPayment);
    if (not responseTowing.status) then
        return lib.notify({
            title = 'Vehicle Parking System',
            description = responseTowing.message,
            type = 'error'
        });
    end

    lib.notify({
        title = 'Vehicle Parking System',
        description = responseTowing.message,
        type = 'success'
    });
end

-- Function to select payment method
local function towSelectPayment(locationId, plate)
    local getLocationTowOption = shConfig.towLocation[locationId]['payment'];
    local realignData = {};
    for locationId, value in pairs(getLocationTowOption) do
        realignData[#realignData + 1] = {
            title = value['label'],
            description = "Select this payment method.",
            icon = value['icon'] or 'wallet',
            onSelect = function()
                towSelectedVehicle(locationId, plate, value['type']);
            end
        }
    end

    lib.registerContext({
        id = menuTowPayment,
        title = 'Vehicle Tow (Payment)',
        options = realignData
    });

    lib.showContext(menuTowPayment);
end

-- Function to select location
local function towSelectLocation(plate)
    local getLocationTow = shConfig.towLocation;
    local realignData = {};
    local coordsPed = GetEntityCoords(cache.ped);

    for locationId, value in pairs(getLocationTow) do
        realignData[#realignData + 1] = {
            title = ("%s - Price : %s"):format(value['label'], tostring(value['price']) .. ' $'),
            description = ('Distance: ~%s'):format(helper.Round(#(coordsPed - value['coords']['xyz']) / 1000, 2) .. 'km'),
            icon = 'map',
            onSelect = function()
                if (value['price'] > 0) then
                    towSelectPayment(locationId, plate);
                else
                    towSelectedVehicle(locationId, plate, 'free');
                end
            end
        }
    end

    lib.registerContext({
        id = menuTowLocation,
        title = 'Vehicle Tow (Location)',
        options = realignData
    });

    lib.showContext(menuTowLocation);
end

-- Function to get vehicle modules
vehicleTowModules['function'] = function()
    local getTowVehicle = cb_await('xJoez-vehicleParking:cb:getTowVehicleNotParking', false);

    if (not getTowVehicle) or (not next(getTowVehicle)) then
        return lib.notify({
            title = 'Vehicle Parking System',
            description = 'You do not have a vehicle to tow.',
            type = 'error'
        });
    end

    local realignData = {};
    for _, value in pairs(getTowVehicle) do
        realignData[#realignData + 1] = {
            title = value['plate'],
            description = ('Vehicle: %s'):format(value['vehicle']),
            icon = 'car',
            onSelect = function()
                towSelectLocation(value['plate'])
            end
        }
    end

    lib.registerContext({
        id = menuTowVehicle,
        title = 'Vehicle Tow',
        options = realignData
    });

    lib.showContext(menuTowVehicle);
end

return vehicleTowModules
