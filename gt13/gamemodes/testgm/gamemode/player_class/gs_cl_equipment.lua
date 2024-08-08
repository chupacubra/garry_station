PLAYER_CL_EQ = {}

EQ_IGNORE = {
    KEYCARD = true
}

function PLAYER_CL_EQ:Spawn()
    self:SetupEquip()
end

function PLAYER_CL_EQ:SetupEquip()
    if self.Player.Loaded then
        return
    end

    self.Player.EqModelDraw = {
        BELT      = {},
		EYES      = {},
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

function PLAYER_CL_EQ:GetEquipModel(key)
//    print(key, 56)
    if table.IsEmpty(self.Player.EqModelDraw[key]) then return false end
    return self.Player.EqModelDraw[key]["model"]:GetModel()
end

function PLAYER_CL_EQ:GetEquipData(key)
    if table.IsEmpty(self.Player.EqModelDraw[key]) then return false end
    return self.Player.EqModelDraw[key]["model"]
end

function PLAYER_CL_EQ:CreateEqModel(eq_model, id_eq)
    if EQ_IGNORE[id_eq] then return end
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

function PLAYER_CL_EQ:EquipSync() -- syncing ALL equip
    if self.Player.EqModelDraw == nil then
        self:SetupEquip()
    end

    for k, v in pairs(self.Player.EqModelDraw) do
        local m = self.Player:GetNWString("EQ_"..k)
        if m != "" then
            if !table.IsEmpty(self.Player.EqModelDraw[k]) then
                self:DeleteEqModel(k)
                self:CreateEqModel(m, k)
            else
                self:CreateEqModel(m, k)
            end
        else
            if !table.IsEmpty(self.Player.EqModelDraw[k]) then
                self:DeleteEqModel(k)
            end
        end
    end

end

function PLAYER_CL_EQ:DrawEquip()
    self:EquipSync()

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
