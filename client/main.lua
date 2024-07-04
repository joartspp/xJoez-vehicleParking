Framework = require 'data/shared/framework'
local cfg = require 'data/client/config'

stateController = {
    vehicleOnParkingNow = nil,
    loadingParking = nil
}

CreateThread(function ()
    while true do
        (function ()
            if (cfg['ifStartEngineWhileLoadingParkingToCancel']) and (stateController.loadingParking) then
                local onVehicle = cache.vehicle;
                if (DoesEntityExist(onVehicle)) then
                    local engineIsStarted = GetIsVehicleEngineRunning(onVehicle);
                    if (engineIsStarted and lib.progressActive()) then
                        lib.cancelProgress();
                    end
                end
            end
        end)();
        Wait(1000)
    end
end)