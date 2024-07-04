return {
    SetFuel = function (vehicle, fuel)
        Entity(vehicle).state.fuel = fuel
    end,
    SetOwnerGiveKey = function (plate)
        TriggerEvent("vehiclekeys:client:SetOwner", plate)
    end
}