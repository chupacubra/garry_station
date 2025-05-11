Ply_Models = {
    "models/Humans/Group01/Male_01.mdl",
    "models/Humans/Group01/Male_02.mdl",
    "models/Humans/Group01/Male_03.mdl",
    "models/Humans/Group01/Male_04.mdl",
    "models/Humans/Group01/Male_05.mdl",
    "models/Humans/Group01/Male_06.mdl",
    "models/Humans/Group01/Male_07.mdl",
    "models/Humans/Group01/Male_08.mdl",
    "models/Humans/Group01/Male_09.mdl",
}

function PlayerModel()
    return Ply_Models[math.random(#Ply_Models)]
end