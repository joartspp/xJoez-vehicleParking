return {
    VersionChecking = true,
    towOption = {
        repairedVehicle = true,
        refillFuelVehicle = true,
        towAndDeleteSpawnedVehicle = true
    },
    towLocation = {
        [1] = {
            ['label'] = 'Legion Square',
            ['coords'] = vec4(228.09, -783.61, 30.72, 244.87),
            ['price'] = 500,
            ['payment'] = {
                [1] = {
                    ['label'] = "Money, Cash",
                    ['type'] = "cash",
                    ['icon'] = 'wallet'
                },
                [2] = {
                    ['label'] = "Bank",
                    ['type'] = "bank",
                    ['icon'] = 'money-check'
                }
            }
        }
    }
}