return {
    ['Command'] = {
        ['vehicleGet'] = {
            ['active'] = true,
            ['command'] = 'vget'
        },
        ['vehiclePark'] = {
            ['active'] = true,
            ['command'] = 'vpark'
        },
        ['vehicleTow'] = {
            ['active'] = true,
            ['command'] = 'vtow'
        },
        ['vehicleGps'] = {
            ['active'] = true,
            ['command'] = 'vgps'
        },
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