PLAYER_CL_EQ = {}
print("asdasdas")

--[[
    BACKPACK = {
        model = "backpack.mdl"
    }

]]
function PLAYER_CL_EQ:SetupEquip()
    if self.Player.Loaded then
        return
    end
    print("SETUP EQUIPMENT FOR "..tostring(ply))
    
    self.Player.EqModelDraw = {
        BELT      = {},
		GLOVES    = {},
		KEYCARD   = {},
		PDA       = {},
		BACKPACK  = {},
		VEST      = {},
		HEAD      = {},
		MASK      = {},
		EAR       = {},
    }

    self.Player.Loaded = true
end

function PLAYER_CL_EQ:CreateEqModel(eq_model, id_eq)
    local offseta = cl_equip_config[eq_model]["ang"]
    local offsetv = cl_equip_config[eq_model]["vec"]
    local bone    = cl_equip_config[eq_model]["bone"]

    local ent = ClientsideModel( eq_model )
    ent:SetModel(eq_model)
    ent:SetPos(self.Player:GetPos())
    ent:SetParent(self.Player)
    ent:SetNoDraw(true)

    self.Player.EqModelDraw[id_eq] = {
        model = ent,
        vec = offsetv,
        ang = offseta,
        bone = bone
    }
end

function PLAYER_CL_EQ:DeleteEqModel(id_eq)
    self.Player.EqModelDraw[id_eq]["model"]:Remove()
    self.Player.EqModelDraw[id_eq] = {}
end

function PLAYER_CL_EQ:EquipSync(tbl) -- syncing ALL equip
    if self.Player.EqModelDraw == nil then
        self:SetupEquip()
    end
    for k,v in pairs(self.Player.EqModelDraw) do
        if tbl[k] then
            if !table.IsEmpty(self.Player.EqModelDraw[k]) then
                self:DeleteEqModel(k)
                self:CreateEqModel(tbl[k], k)
            else
                self:CreateEqModel(tbl[k], k)
            end
        else
            if !table.IsEmpty(self.Player.EqModelDraw[k]) then
                self:DeleteEqModel(k)
            end
        end
    end
end

function PLAYER_CL_EQ:DrawEquip()
    if self.Player.EqModelDraw == nil then
        self:SetupEquip()
    end

    for k, eq in pairs(self.Player.EqModelDraw) do
        if !table.IsEmpty(eq) then
            local boneid = self.Player:LookupBone( eq.bone )
                
            if not boneid then
                return
            end
            
            local matrix = self.Player:GetBoneMatrix( boneid )
            
            if not matrix then 
                return 
            end
            
            local newpos, newang = LocalToWorld(cl_equip_config[eq.model:GetModel()]["vec"], cl_equip_config[eq.model:GetModel()]["ang"], matrix:GetTranslation(), matrix:GetAngles() )
            
            eq.model:SetRenderOrigin(newpos)
            eq.model:SetRenderAngles(newang)
            eq.model:SetupBones()
            eq.model:DrawModel()
        end
    end
end


hook.Add( "PostPlayerDraw" , "gs_draw_equip_model", function( ply )
    if ply:IsValid() then
        player_manager.RunClass(ply, "DrawEquip")
    end
end)

net.Receive("gs_ply_equip_draw_sync", function()
    local ply = net.ReadEntity()
    local tbl = net.ReadTable()

    PrintTable(tbl)
    player_manager.RunClass(ply, "EquipSync", tbl)
end)
 
net.Receive("gs_ply_equip_setup", function()
    local ply = net.ReadEntity()
    
    print("SETYIP", ply, ply:GetClassID())
    player_manager.RunClass(ply, "SetupEquip")
end)