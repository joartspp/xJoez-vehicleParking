local Command = require 'data/client/config'['Command'];

local vehicleModules = require 'client.modules.vehicle'

if (Command['vehicleGet']['active']) then
    RegisterCommand(Command['vehicleGet']['command'], function ()
        vehicleModules.get['function']()
    end, false)
end

if (Command['vehiclePark']['active']) then
    RegisterCommand(Command['vehiclePark']['command'], function ()
        vehicleModules.park['function']()
    end, false)
end

if (Command['vehicleTow']['active']) then
    RegisterCommand(Command['vehicleTow']['command'], function ()
        vehicleModules.tow['function']()
    end, false)
end

if (Command['vehicleGps']['active']) then
    RegisterCommand(Command['vehicleGps']['command'], function ()
        vehicleModules.gps['function']()
    end, false)
end