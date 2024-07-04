Framework = require 'data/shared/framework'

local cb_reg = require 'data.shared.callback'.cb_reg;
local sql = require 'data.server.mysql';

local helper = require 'data.shared.helper';
local shConfig = require 'data.shared.config';

function GetVehicleOnServerByPlate(plate)
    local allVehicles = GetAllVehicles()
    for _, vehicle in ipairs(allVehicles) do
        local targetPlate = string.gsub(plate, "%s+", "");
        local globalVehiclePlate = string.gsub(GetVehicleNumberPlateText(vehicle), "%s+", "")
        if (globalVehiclePlate == targetPlate) then
            return vehicle;
        end
    end

    return false;
end

cb_reg('xJoez-vehicleParking:cb:getOwnerOfVehicle', function (source, plate)
    local _source = source;
    local player = Framework.Functions.GetPlayer(_source);
    if (not player) then
        return false;
    end

    local citizenId = player.PlayerData.citizenid;
    local getOwnerByPlate = sql.single('SELECT vparking, state FROM player_vehicles WHERE plate = ? AND citizenid = ?', {
        plate,
        citizenId
    });

    if (not getOwnerByPlate) then return false; end
    return getOwnerByPlate;
end)

cb_reg('xJoez-vehicleParking:cb:getNowVehicleParking', function (source)
    local _source = source;
    local player = Framework.Functions.GetPlayer(_source);
    if (not player) then
        return false;
    end

    local citizenId = player.PlayerData.citizenid;
    local getCountVparking = sql.query('SELECT SUM(vparking) as VparkingCount FROM player_vehicles WHERE citizenid = ?', {
        citizenId
    });

    return tonumber(getCountVparking[1].VparkingCount);
end)

cb_reg('xJoez-vehicleParking:cb:getTowVehicleNotParking', function (source)
    local _source = source;
    local player = Framework.Functions.GetPlayer(_source);
    if (not player) then
        return false;
    end

    local citizenId = player.PlayerData.citizenid;
    local getVehicleNotInParking = sql.query('SELECT plate, vehicle FROM player_vehicles WHERE citizenid = ? AND vparking = ? AND state = ?', {
        citizenId,
        0,
        0
    });

    return getVehicleNotInParking;
end)

cb_reg('xJoez-vehicleParking:cb:getAllVehiclesOwner', function (source)
    local _source = source;
    local player = Framework.Functions.GetPlayer(_source);
    if (not player) then
        return false;
    end

    local citizenId = player.PlayerData.citizenid;
    local getVehicleInParking = sql.query('SELECT * FROM player_vehicles WHERE citizenid = ?', {
        citizenId,
    });

    return getVehicleInParking;
end)

cb_reg('xJoez-vehicleParking:cb:getVehicleInParking', function (source)
    local _source = source;
    local player = Framework.Functions.GetPlayer(_source);
    if (not player) then
        return false;
    end

    local citizenId = player.PlayerData.citizenid;
    local getVehicleInParking = sql.query('SELECT * FROM player_vehicles WHERE citizenid = ? AND vparking = ? AND state = ?', {
        citizenId,
        1,
        1
    });

    return getVehicleInParking;
end)

cb_reg('xJoez-vehicleParking:cb:vehicleParking', function (source, data)
    local _source = source;
    local player = Framework.Functions.GetPlayer(_source);
    if (not player) then
        return false;
    end

    local citizenId = player.PlayerData.citizenid;
    local plate = data.plate;
    local location = json.encode(data.location);
    local propsVehicle = json.encode(data.props);
    local savedVehicle = sql.update("UPDATE player_vehicles SET state = ?, vparking = ?, parking_coord = ?, mods = ? WHERE plate = ? AND citizenid = ?", {
        1,
        1,
        location,
        propsVehicle,
        plate,
        citizenId
    });

    return savedVehicle
end)

cb_reg('xJoez-vehicleParking:cb:checkSpawnedVehicleOnServer', function (source, data)
    local _source = source;
    local player = Framework.Functions.GetPlayer(_source);
    if (not player) then
        return false;
    end

    local getVehicleOnServer = GetVehicleOnServerByPlate(data.plate);

    return getVehicleOnServer;
end)

cb_reg('xJoez-vehicleParking:cb:spawnAndSetStateVehicleGet', function (source, data)
    local _source = source;
    local player = Framework.Functions.GetPlayer(_source);
    if (not player) then
        return false;
    end

    local citizenId = player.PlayerData.citizenid;

    local savedVehicle = sql.update("UPDATE player_vehicles SET state = ?, vparking = ?, parking_coord = ?, vtowing_repaired = 0 WHERE plate = ? AND citizenid = ?", {
        0,
        0,
        json.encode({}),
        data.plate,
        citizenId
    });

    return savedVehicle
end)

cb_reg('xJoez-vehicleParking:cb:towingVehicleToTowLocation', function (source, plate, locationId, methodPay)
    local _source = source;
    local player = Framework.Functions.GetPlayer(_source);
    if (not player) then
        return false;
    end

    local citizenId = player.PlayerData.citizenid;

    if (shConfig.towLocation[locationId]['price'] > 0) then
        local checkMoney = player.Functions.GetMoney(methodPay);
        if (checkMoney < shConfig.towLocation[locationId]['price']) then
            return {
                status = false,
                message = 'You do not have enough money to tow the vehicle.'
            }
        end

        player.Functions.RemoveMoney(methodPay, shConfig.towLocation[locationId]['price'], 'tow-vehicle');
    end

    local locationTow = {
        x = helper.Round(shConfig.towLocation[locationId]['coords'].x, 2),
        y = helper.Round(shConfig.towLocation[locationId]['coords'].y, 2),
        z = helper.Round(shConfig.towLocation[locationId]['coords'].z, 2),
        h = helper.Round(shConfig.towLocation[locationId]['coords'].w, 2)
    };

    local additionalQuery = "";

    if (shConfig.towOption.refillFuelVehicle) then
        additionalQuery = additionalQuery..", fuel = 100, "
    end

    if (shConfig.towOption.repairedVehicle) then
        additionalQuery = additionalQuery.."engine = 1000, body = 1000, vtowing_repaired = 1"
    end

    local query, params = "UPDATE player_vehicles SET vparking = ?, state = ?, parking_coord = ? "..additionalQuery.." WHERE plate = ? AND citizenid = ?", {
        1,
        1,
        json.encode(locationTow),
        plate,
        citizenId
    };

    local savedVehicle = sql.update(query, params);

    if (not savedVehicle) then
        return {
            status = false,
            message = 'Failed to tow the vehicle.'
        }
    end

    if (shConfig.towOption.towAndDeleteSpawnedVehicle) then
        local getVehicleOnServer = GetVehicleOnServerByPlate(plate);
        if (getVehicleOnServer) then
            DeleteEntity(getVehicleOnServer);
        end
    end

    return {
        status = true,
        message = 'You have successfully towed the vehicle.'
    }
end)