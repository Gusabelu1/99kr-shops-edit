# 99kr-shops

[ NEEDED ]
- For make the shops working you need to put this line of code anywhere into es_extended/server/functions.lua

`
ESX.GetItemLimit = function(item)
	if ESX.Items[item] ~= nil then
		return ESX.Items[item].limit
	end
end
`

[ Info ]

- This is a shop/store script for ESX, this is different from the normal esx_shops as it is more interactive. You walk around in the store to grab stuff from the shelfs to put into your basket on L, then go to the cashier and be prompted with the choice to pay with cash or with your credit card. See video for better explanation

[ Features ]

- Customizable config file.

[ Installation ]

1. Download
2. Put this resource into your resources
3. Run the SQL file
4. Put `start 99kr-shops-edit` into your server.cfg

- And change what you want.

[ Requirements ]

- ESX
- esx_menu_default
- pNotify

[ Video ]

- https://streamable.com/e7z1l

[ Explanation of what I made]

ONLY FOR ES_EXTENDED 1.1.0 (it's easy to adapt to weight)

- I modified the original 99kr-shops for setting a limit of items that a player can buy/purchase. 
This modify is in /client/shop.lua and its a disaster, basically if you have 3 items in the basket and the limit is 5, you can only get 2 more, not 3, 4, etc.
- I also made a communication from the script with the SQL that gets the limit of an item, with this fix the players can't buy/purchase unlimited items if they have the money.
- Now you can change the Blip ID (`bid`), Blip Colour (`bco`), Blip Scale (`bscala`), Blip Name (`nombre`) and the Ped Hash (`hash`). <---- 
These modifications are for each store separately. ;) Enjoy.

- All credits to 99kr, FIX made by saantii#9999.