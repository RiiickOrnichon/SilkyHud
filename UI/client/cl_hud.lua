ESX = nil
local hunger, thirst = 0, 0
local nbPlayerTotal = 0

CreateThread(function()
    while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

CreateThread(function()
    while true do
        TriggerEvent('esx_status:getStatus', 'hunger', function(status)
            hunger = status.getPercent()
        end)
        TriggerEvent('esx_status:getStatus', 'thirst', function(status)
            thirst = status.getPercent()
        end)
        Wait(10000)
    end
end)

local FuelUsage = {
	[1.0] = 1.0,
	[0.9] = 0.9,
	[0.8] = 0.8,
	[0.7] = 0.7,
	[0.6] = 0.6,
	[0.5] = 0.5,
	[0.4] = 0.4,
	[0.3] = 0.3,
	[0.2] = 0.2,
	[0.1] = 0.1,
	[0.0] = 0.0,
}

local Classes = {
	[0] = 0.2, -- Compacts
	[1] = 0.2, -- Sedans
	[2] = 0.2, -- SUVs
	[3] = 0.3, -- Coupes
	[4] = 0.3, -- Muscle
	[5] = 0.3, -- Sports Classics
	[6] = 0.3, -- Sports
	[7] = 0.3, -- Super
	[8] = 0.2, -- Motorcycles
	[9] = 0.3, -- Off-road
	[10] = 0.3, -- Industrial
	[11] = 0.3, -- Utility
	[12] = 0.3, -- Vans
	[13] = 0.0, -- Cycles
	[14] = 0.0, -- Boats
	[15] = 0.0, -- Helicopters
	[16] = 0.0, -- Planes
	[17] = 0.2, -- Service
	[18] = 0.2, -- Emergency
	[19] = 0.2, -- Military
	[20] = 0.3, -- Commercial
	[21] = 0.0, -- Trains
}

function SetFuel(vehicle, fuel)
	if type(fuel) == 'number' and fuel >= 0 and fuel <= 100 then
		SetVehicleFuelLevel(vehicle, fuel + 0.0)
	end
end

function ManageFuelUsage(vehicle)
	if not DecorExistOn(vehicle, FuelDecor) then
    Citizen.Wait(300)
		SetFuel(vehicle, math.random(200, 800) / 1)
	elseif not fuelSynced then
		SetFuel(vehicle, GetFuel(vehicle))

		fuelSynced = true
	end

	if IsVehicleEngineOn(vehicle) then
		SetFuel(vehicle, GetVehicleFuelLevel(vehicle) - FuelUsage[Round(GetVehicleCurrentRpm(vehicle), 1)] * (Classes[GetVehicleClass(vehicle)] or 1.0) / 100)
	end
end

CreateThread(function()
    Wait(2500)
    local iddd = GetPlayerServerId(PlayerId())
    Wait(1200)
    SendNUIMessage({actionhud = "setValue", key = "id", value = "ID : "..iddd})
    local sleep = 1500
    local enabledSpeedo = false
    local IsPaused = false
    TriggerServerEvent("rHud:getInfo")
    while true do
        if not GetIsWidescreen() then 
            SendNUIMessage({actionhud = "setResolution"})
        else
            SendNUIMessage({actionhud = "resetResolution"})
        end
        local heur = GetClockHours()
        local minute = GetClockMinutes()
        if minute < 10 then 
            minute = "0"..minute 
        end
        if heur < 10 then 
            heur = "0"..heur 
        end
        local ped = PlayerPedId()
        local getVeh = GetVehiclePedIsIn(ped, false)
        local isInVehicle = IsPedInAnyVehicle(ped, false)
        local classe = GetVehicleClass((getVeh)) 
        SendNUIMessage({actionhud = "setValue", key = "clock", value = heur.." : "..minute})
        SendNUIMessage({actionhud = "setValue", key = "eat", value = hunger})
        SendNUIMessage({actionhud = "setValue", key = "drink", value = thirst})
        if IsPauseMenuActive() and not IsPaused then
			IsPaused = true
			SendNUIMessage({actionhud = "showhud", showhud = false})
            if isInVehicle and not (classe == 13)  then 
                SendNUIMessage({
                    actionspeedo = "showspeedo",
                    showspeedo = false
                })
            end
		elseif not IsPauseMenuActive() and IsPaused then
			IsPaused = false
			SendNUIMessage({actionhud = "showhud", showhud = true})
            if isInVehicle and not (classe == 13)  then 
                SendNUIMessage({
                    actionspeedo = "showspeedo",
                    showspeedo = true
                })
            end
		end
        if isInVehicle and not (classe == 13) then
            if not enabledSpeedo then
                if not (classe == 13) then 
                    SendNUIMessage({
                        actionspeedo = "showspeedo",
                        showspeedo = true
                    })
                    enabledSpeedo = true
                    sleep = 0
                end
            end
            local vehicle = GetVehiclePedIsIn(ped, false)
            local fuel = GetVehicleFuelLevel(vehicle)
            local speed = math.ceil(GetEntitySpeed(vehicle) * 3.6)
            SendNUIMessage({actionspeedo = "setValue", key = "speed", value = speed})
            SendNUIMessage({actionspeedo = "setValue", key = "fuel", value = fuel})
            if speed > 0.1 then
                ManageFuelUsage(vehicle)
            end
        else
            SendNUIMessage({
                actionspeedo = "showspeedo",
                showspeedo = false
            })
            enabledSpeedo = false
            sleep = 1000
        end
        Wait(sleep)
    end
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer) 
	local data = xPlayer
	local accounts = data.accounts
	for _,v in pairs(accounts) do
		local account = v
		if account.name == "cash" then
			local moneymoney = ESX.Math.GroupDigits(account.money)
			SendNUIMessage({actionhud = "setValue", key = "money", value = moneymoney.." $"})
		end
        if account.name == "dirtycash" then
			local moneymoney = ESX.Math.GroupDigits(account.money)
			SendNUIMessage({actionhud = "setValue", key = "sale", value = moneymoney.." $"})
		end
	end
end)

RegisterNetEvent('esx:setAccountMoney', function(account)
	if account.name == "cash" then
		local moneymoney = ESX.Math.GroupDigits(account.money)
		SendNUIMessage({actionhud = "setValue", key = "money", value = moneymoney.." $"})
	end
    if account.name == "dirtycash" then
        local moneymoney = ESX.Math.GroupDigits(account.money)
        SendNUIMessage({actionhud = "setValue", key = "sale", value = moneymoney.." $"})
    end
end)

RegisterNetEvent("Hud:hide", function(show) 
	SendNUIMessage({actionhud = "showhud", showhud = show}) 
end)

RegisterNetEvent("rHud:setInfo", function(cash, dirty) 
    SendNUIMessage({actionhud = "setValue", key = "money", value = ESX.Math.GroupDigits(cash).." $"})
    SendNUIMessage({actionhud = "setValue", key = "sale", value = ESX.Math.GroupDigits(dirty).." $"})
end)

RegisterNetEvent("ui:update")
AddEventHandler("ui:update", function(nbPlayerTotal)
    SendNUIMessage({actionhud = "setValue", key = "player", value = nbPlayerTotal})
end)