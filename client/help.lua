function ModulesLoad()
	Events:Fire( "HelpAddItem",
        {
            name = "Vehicle Ownership",
            text = 
                "This script allow you to buy car with save.\n\n" ..
                "Vehicle Ownership System, made by TL_GTASA."
        } )
end

function ModuleUnload()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Vehicle Ownership"
        } )
end

Events:Subscribe("ModulesLoad", ModulesLoad)
Events:Subscribe("ModuleUnload", ModuleUnload)