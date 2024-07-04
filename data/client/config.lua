return {
    ['Command'] = {
        ['vehicleGet'] = 'vget',
        ['vehiclePark'] = 'vpark',
        ['vehicleTow'] = 'vtow',
        ['vehicleGps'] = 'vgps',
    },
    ['LimitVehicleParking'] = 3, -- -1 = unlimit
    ['stopEngineBeforeParking'] = false, -- if true, engine will be stopped before parking
    ['usingLoadingAfterParking'] = false, -- if true, loading will be shown after parking
    ['ifStartEngineWhileLoadingParkingToCancel'] = false, -- if true, engine will be stopped if started while parking
    ['loadingAfterParking'] = {
        ['time'] = 10000,
        ['text'] = 'Parking the vehicle...'
    }
}