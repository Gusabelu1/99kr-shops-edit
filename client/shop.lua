--[[ Marker loop ]]--
Citizen.CreateThread(function()
    while true do
        local wait = 750
        local coords = GetEntityCoords(PlayerPedId())
        for i=1, #Config.Locations do
            for j=1, #Config.Locations[i]["shelfs"] do
                local pos = Config.Locations[i]["shelfs"][j]
                local dist = GetDistanceBetweenCoords(coords, pos["x"], pos["y"], pos["z"], true)
                if dist <= 5.0 then
                    if dist <= 1.5 then
                        local text = Config.Locales[pos["value"]]
                        if dist <= 1.0 then
                            text = "[E] " .. text
                            if IsControlJustPressed(0, Keys["E"]) then
                                OpenAction(pos, Config.Items[pos["value"]], Config.Locales[pos["value"]])
                        	end
                        end
                        DrawText3D(pos["x"], pos["y"], pos["z"], text)
                    end
                    wait = 5
                    Marker(pos)
                end
            end
        end
        Citizen.Wait(wait)
    end
end)

--[[ Loop for checking if player is too far away, then empty basket ]] --
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if payAmount > 0 then
            for shop = 1, #Config.Locations do
                local blip = Config.Locations[shop]["blip"]
                local dist = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), blip["x"], blip["y"], blip["z"], true)
				if dist <= 20.0 then
					ESX.ShowHelpNotification('Presione la ~r~H~w~ para ver el carrito')
				end
                if dist <= 20.0 then
                    if dist >= 12.0 then
                        exports['mythic_notify']:DoHudText('inform', 'Te fuiste de la tienda! Se te vacio tu carrito.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
                        payAmount = 0
                        Basket = {}
                    end
                end
            end
        end
    end
end)

--[[ Check what to do ]]--
OpenAction = function(action, shelf, text)
    if action["value"] == "checkout" then
        if payAmount > 0 and #Basket then
            CashRegister(text)
        else
            exports['mythic_notify']:DoHudText('inform', 'No tenes nada en tu carrito!', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
        end
    else
        ShelfMenu(text, shelf)
    end
end

--[[ Cash register menu ]]--
CashRegister = function(titel)
        local elements = {
            {label = '<span style="color:lightgreen; border-bottom: 1px solid lightgreen;">Confirmar</span>', value = "yes"},
            {label = 'Cantidad a pagar: <span style="color:green">$' .. payAmount ..'</span>'},
        }

        for i=1, #Basket do
            local item = Basket[i]
            table.insert(elements, {
                label = '<span style="color:red">*</span> ' .. item["label"] .. ': ' .. item["amount"] .. ' piezas',
                value = item["value"],
            })
        end

        ESX.UI.Menu.CloseAll()
        ESX.UI.Menu.Open(
            'default', GetCurrentResourceName(), 'penis',
            {
                title    = "Tienda - " .. titel,
                align    = 'center',
                elements = elements
            },
            function(data, menu)
            
                if data.current.value == "yes" then
                    menu.close()
                    ESX.UI.Menu.Open(
                        'default', GetCurrentResourceName(), 'penis2',
                        {
                            title    = "Tienda - Pago",
                            align    = 'center',
                            elements = {
                                {label = "Pagar con Efectivo", value = "cash"},
                                {label = "Pagar con Tarjeta de Credito", value = "bank"},
                            },
                        },
                        function(data2, menu2)
                            ESX.TriggerServerCallback('99kr-shops:CheckMoney', function(hasMoney)
                                if hasMoney then
                                    TriggerServerEvent('99kr-shops:Cashier', payAmount, Basket, data2.current["value"])
                                    payAmount = 0
                                    Basket = {}
                                    menu2.close()
                                else
                                    exports['mythic_notify']:DoHudText('inform', 'No tenes suficiente dinero!', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
                                end
                            end, payAmount, data2.current["value"])
                        end,
                    function(data2, menu2)
                        menu2.close()
                    end)
                end
            end,
        function(data, menu)
            menu.close()
    end) 
end

--[[ Open shelf menu ]]--
ShelfMenu = function(titel, shelf)
    local elements = {}

    for i=1, #shelf do
        local shelf = shelf[i]
        table.insert(elements, {
            realLabel = shelf["label"],
            label = shelf["label"] .. ' (<span style="color:green">$' .. shelf["price"] .. '</span>)',
            item = shelf["item"],
            price = shelf["price"],
            value = 1, type = 'slider', min = 1, max = shelf["maximo"],
        })
		if shelf["maximo"] == Config.Max10 then
			maximoItems = 10
		elseif shelf["maximo"] == Config.Max5 then
			maximoItems = 5
		elseif shelf["maximo"] == Config.Max3 then
			maximoItems = 3
		elseif shelf["maximo"] == Config.Max2 then
			maximoItems = 2
		elseif shelf["maximo"] == Config.Max1 then
			maximoItems = 1
		end
    end
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'penis',
        {
            title    = "Tienda - " .. titel,
            align    = 'center',
            elements = elements
        },
        function(data, menu)
        
            local alreadyHave, basketItem = CheckBasketItem(data.current.item)
			local NomItem = data.current["realLabel"]
			local Agregado = data.current.value
            if alreadyHave then
                if maximoItems == 1 then
					if (basketItem.amount and basketItem["amount"] == 1) and (data.current.value == 1) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max1 .. '. No puede llevar mas.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					else 
						basketItem.amount = basketItem["amount"] + data.current.value
						exports['mythic_notify']:DoHudText('inform', 'Pusiste ' .. data.current.value .. ' ' .. data.current["realLabel"] .. ' en tu carrito.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					end
				elseif maximoItems == 2 then
					if (basketItem.amount and basketItem["amount"] == 2) and (data.current.value == 1 or data.current.value == 2) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max2 .. '. No puede llevar mas.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					elseif (basketItem.amount and basketItem["amount"] == 1) and (data.current.value == 2) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max2 .. '.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					else 
						basketItem.amount = basketItem["amount"] + data.current.value
						exports['mythic_notify']:DoHudText('inform', 'Pusiste ' .. data.current.value .. ' ' .. data.current["realLabel"] .. ' en tu carrito.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					end
				elseif maximoItems == 3 then
					if (basketItem.amount and basketItem["amount"] == 3) and (data.current.value == 1 or data.current.value == 2 or data.current.value == 3) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max3 .. '. No puede llevar mas.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					elseif (basketItem.amount and basketItem["amount"] == 2) and (data.current.value == 2 or data.current.value == 3) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max3 .. '.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					elseif (basketItem.amount and basketItem["amount"] == 1) and (data.current.value == 3) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max3 .. '.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					else 
						basketItem.amount = basketItem["amount"] + data.current.value
						exports['mythic_notify']:DoHudText('inform', 'Pusiste ' .. data.current.value .. ' ' .. data.current["realLabel"] .. ' en tu carrito.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					end
				elseif maximoItems == 5 then
					if (basketItem.amount and basketItem["amount"] == 5) and (data.current.value == 1 or data.current.value == 2 or data.current.value == 3 or data.current.value == 4 or data.current.value == 5) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max5 .. '. No puede llevar mas.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					elseif (basketItem.amount and basketItem["amount"] == 4) and (data.current.value == 2 or data.current.value == 3 or data.current.value == 4 or data.current.value == 5) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max5 .. '.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					elseif (basketItem.amount and basketItem["amount"] == 3) and (data.current.value == 3 or data.current.value == 4 or data.current.value == 5) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max5 .. '.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					elseif (basketItem.amount and basketItem["amount"] == 2) and (data.current.value == 4 or data.current.value == 5) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max5 .. '.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					elseif (basketItem.amount and basketItem["amount"] == 1) and (data.current.value == 5) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max5 .. '.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					else 
						basketItem.amount = basketItem["amount"] + data.current.value
						exports['mythic_notify']:DoHudText('inform', 'Pusiste ' .. data.current.value .. ' ' .. data.current["realLabel"] .. ' en tu carrito.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					end
				elseif maximoItems == 10 then 
					if (basketItem.amount and basketItem["amount"] == 10) and (data.current.value == 1 or data.current.value == 2 or data.current.value == 3 or data.current.value == 4 or data.current.value == 5 or data.current.value == 6 or data.current.value == 7 or data.current.value == 8 or data.current.value == 9 or data.current.value == 10) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max10 .. '. No puede llevar mas.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					elseif (basketItem.amount and basketItem["amount"] == 9) and (data.current.value == 2 or data.current.value == 3 or data.current.value == 4 or data.current.value == 5 or data.current.value == 6 or data.current.value == 7 or data.current.value == 8 or data.current.value == 9 or data.current.value == 10) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max10 .. '.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					elseif (basketItem.amount and basketItem["amount"] == 8) and (data.current.value == 3 or data.current.value == 4 or data.current.value == 5 or data.current.value == 6 or data.current.value == 7 or data.current.value == 8 or data.current.value == 9 or data.current.value == 10) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max10 .. '.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					elseif (basketItem.amount and basketItem["amount"] == 7) and (data.current.value == 4 or data.current.value == 5 or data.current.value == 6 or data.current.value == 7 or data.current.value == 8 or data.current.value == 9 or data.current.value == 10) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max10 .. '.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					elseif (basketItem.amount and basketItem["amount"] == 6) and (data.current.value == 5 or data.current.value == 6 or data.current.value == 7 or data.current.value == 8 or data.current.value == 9 or data.current.value == 10) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max10 .. '.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					elseif (basketItem.amount and basketItem["amount"] == 5) and (data.current.value == 6 or data.current.value == 7 or data.current.value == 8 or data.current.value == 9 or data.current.value == 10) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max10 .. '.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					elseif (basketItem.amount and basketItem["amount"] == 4) and (data.current.value == 7 or data.current.value == 8 or data.current.value == 9 or data.current.value == 10) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max10 .. '.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					elseif (basketItem.amount and basketItem["amount"] == 3) and (data.current.value == 8 or data.current.value == 9 or data.current.value == 10) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max10 .. '.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					elseif (basketItem.amount and basketItem["amount"] == 2) and (data.current.value == 9 or data.current.value == 10) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max10 .. '.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					elseif (basketItem.amount and basketItem["amount"] == 1) and (data.current.value == 10) then
						exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. Config.Max10 .. '.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
					else 
						basketItem.amount = basketItem["amount"] + data.current.value
						exports['mythic_notify']:DoHudText('inform', 'Pusiste ' .. data.current.value .. ' ' .. data.current["realLabel"] .. ' en tu carrito.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
						payAmount = payAmount + data.current["price"] * data.current.value  
					end
				end
            else
                table.insert(Basket, {
                    label = data.current["realLabel"],
                    value = data.current["item"],
                    amount = data.current.value,
                    price = data.current["price"]
                })
				exports['mythic_notify']:DoHudText('inform', 'Pusiste ' .. data.current.value .. ' ' .. data.current["realLabel"] .. ' en tu carrito.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
				payAmount = payAmount + data.current["price"] * data.current.value   
            end    
        end,
    function(data, menu)
        menu.close()
    end)
end

function ExportsMythic(NomItem, LimItem, Maximo, Agregado)
	exports['mythic_notify']:DoHudText('inform', 'El limite de ' .. NomItem .. ' es de ' .. LimItem .. '. Puede probar agregando ' .. Maximo - Agregado .. ' menos.', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
end

--[[ Check if item already in basket ]]--
CheckBasketItem = function(item)
    for i=1, #Basket do
        if item == Basket[i]["value"] then
            return true, Basket[i]
        end
    end
    return false, nil
end

--[[ Checks if key "L" is pressed ]]--
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3)
        if IsControlJustPressed(0, 74) then
            OpenBasket()
        end
    end
end)

-- [[ Opens basket menu ]]--
OpenBasket = function()
    if payAmount > 0 and #Basket then
        local elements = {
            {label = 'Cantidad a pagar: <span style="color:green">$' .. payAmount},
        }
        for i=1, #Basket do
            local item = Basket[i]
            table.insert(elements, {
                label = '<span style="color:red">*</span> ' .. item["label"] .. ': ' .. item["amount"] .. ' piezas (<span style="color:green">$' .. item["price"] * item["amount"] .. '</span>)',
                value = "item_menu",
                index = i
            })
        end
        table.insert(elements, {label = '<span style="color:red">Vaciar Carrito', value = "empty"})

        ESX.UI.Menu.CloseAll()
        ESX.UI.Menu.Open(
            'default', GetCurrentResourceName(), 'basket',
            {
                title    = "Carrito",
                align    = 'center',
                elements = elements
            },
            function(data, menu)
                if data.current.value == 'empty' then
                    Basket = {}
                    payAmount = 0
                    menu.close()
                    exports['mythic_notify']:DoHudText('inform', 'Se removio todo de tu carrito!', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
                end
                if data.current.value == "item_menu" then
                    menu.close()
                    local index = data.current.index
                    local shopItem = Basket[index]

                    -- [[ Opens detailed (kinda) menu about item ]] --
                    ESX.UI.Menu.Open(
                        'default', GetCurrentResourceName(), 'basket_detailedmenu',
                        {
                            title    = "Carrito - " .. shopItem["label"] .. " - " .. shopItem["amount"] .. " piezas",
                            align    = 'center',
                            elements = {
                                {label = shopItem["label"] .. " - $" .. shopItem["price"] * shopItem["amount"]},
                                {label = '<span style="color:red">Borrar Item</span>', value = "deleteItem"},
                            },
                        },
                        function(data2, menu2)
                            if data2.current["value"] == "deleteItem" then
                                exports['mythic_notify']:DoHudText('inform', 'Se removio ' .. Basket[index]["amount"] .. ' ' .. Basket[index]["label"] .. ' de tu carrito', { ['background-color'] = '#000000', ['color'] = '#ffffff' })
                                payAmount = payAmount - (Basket[index]["amount"] * Basket[index]["price"])
                                table.remove(Basket, index)
                                OpenBasket()
                            end
                        end,
                        function(data2, menu2)
                            menu2.close()
                            OpenBasket()
                        end
                    )
                    
                    -- [[ Back to normal basket menu ]] --
                end
            end,
            function(data, menu)
                menu.close()
            end
        )
    else
        ESX.UI.Menu.CloseAll()
    end
end
