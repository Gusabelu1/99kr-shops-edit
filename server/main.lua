--[[ Gets the ESX library ]]--
ESX = nil 
TriggerEvent("esx:getSharedObject", function(obj)
    ESX = obj
end)

RegisterNetEvent('99kr-shops:Cashier')
AddEventHandler('99kr-shops:Cashier', function(price, basket, account)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	
    
    for i=1, #basket do
		if xPlayer.getInventoryItem(basket[i]["value"]).count < ESX.GetItemLimit(basket[i]["value"])then
			xPlayer.addInventoryItem(basket[i]["value"], basket[i]["amount"])
			TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'Compraste productos por un total de AR$<span style="color: green">' .. price .. '</span>', style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
			if account == "cash" then
				xPlayer.removeMoney(price)
			else
				xPlayer.removeAccountMoney(account, price)
			end
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'Ya tienes el <span style="color: red">maximo</span> de <span style="color: green">' .. basket[i]["value"] .. 's</span> en tu inventario, se te vacio tu carrito por motivos de seguridad.', style = { ['background-color'] = '#000000', ['color'] = '#ffffff' } })
		end
    end
    
    

end)

ESX.RegisterServerCallback('99kr-shops:CheckMoney', function(source, cb, price, account)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local money
    if account == "cash" then
        money = xPlayer.getMoney()
    else
        money = xPlayer.getAccount(account)["money"]
    end

    if money >= price then
        cb(true)
    end
    cb(false)
end)

pNotify = function(message, messageType, messageTimeout)
	TriggerClientEvent("pNotify:SendNotification", source, {
		text = message,
		type = messageType,
		queue = "shop_sv",
		timeout = messageTimeout,
		layout = "topRight"
	})
end