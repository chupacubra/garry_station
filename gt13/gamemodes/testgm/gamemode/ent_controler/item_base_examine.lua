BaseExamine = {}

BaseExamine.chem_container = {
    {
        examine_string = "in %s %s units",
        arguments = {{"Entity_Data", "Name"}, {"Private_Data", "Unit"}}
    }
}

BaseExamine.gun_magazine = {
    {
        examine_string = "in magazine %s bullets",
        arguments = {{"Private_Data", "Bullets"}}
    }
}

BaseExamine.ammobox = {
    {
        examine_string = "in box %s bullets",
        arguments = {{"Private_Data", "AmmoInBox"}}
    }
}

BaseExamine.pile_stack = {
    {
        examine_string = "it's %s %s",
        arguments = {{"Private_Data", "Stack"},{"Entity_Data", "Name"}}
    }
}

