local Command = require 'data/client/config'['Command'];

local vehicleModules = require 'client.modules.vehicle'

RegisterCommand(Command['vehicleGet'], function ()
    vehicleModules.get['function']()
end, false)

RegisterCommand(Command['vehiclePark'], function ()
    vehicleModules.park['function']()
end, false)

RegisterCommand(Command['vehicleTow'], function ()
    vehicleModules.tow['function']()
end, false)

RegisterCommand(Command['vehicleGps'], function ()
    vehicleModules.gps['function']()
end, false)