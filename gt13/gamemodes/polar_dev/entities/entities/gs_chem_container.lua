-- init chem container if have
AddCSLuaFile()

ENT.Base = "gs_entity"

ENT.IsChemContainer = true
ENT.ChemContainerData = {
    Max = 100,
    Chems = {}
}

ENT.RenderChem = false
ENT.RenderChem_Data = {}


/*
// мы можем не перестраивать постоянно мешь при изменении количества, а просто увеличивать его размер и перемещать через матрицу 
   изначально генерируем
   
    если у нас есть ведро c разными радиусами
    rad_max = 8.153,
    rad_min = 6.534,

    условный размер на дне 0, размер на краях 1
    к примеру у нас сейчас есть 50 юнитов из 100 в ведре    
    
    rad = LerpVector(level / max_level, rad_min, rad_max)

    получаем размер на сколько нада увеличивать
    size = rad_min / rad


    из-за этого нам ещё придется вычислять вертикальное положение поверхности жижы

    h = LerpVector(level / max_level, height_min, height_max)


    ...

    local m = Matrix()
    m:SetTranslation(ent:LocalToWorld(height))
    m:SetScale(size)
    m:Rotate(ent:GetAngles())

    cam.PushModelMatrix( m, true )
        msh:Draw()
    cam.PopModelMatrix()

    тем самым дает возможность динамически менять размер меша без постоянного перестраивания

this data only for initialize, in init this will be ChemContainer object

ENT.ChemContainer = {
    Max = 100,
    -- if we want to make empty bucket, Chems = nil
    Chems = {
        some_chem_id = 20,
    }
}

local containers_data = {
    ["models/props_c17/metalpot001a.mdl"] = {
        height_min = -5.478, 
        height_max = 5.478,
        rad_max = 7.005, // in tests need add some more (~0.1)
        rad_min = 7.005, //6.988
        
        no_recreate_mesh = true,
    },
    ["models/props_junk/metalbucket01a.mdl"] = {
        height_min = -8.033,
        height_max = 8.033,
        rad_max = 8.153,
        rad_min = 6.534,
    },
}

NWVars:

    Chems
    ChemColor
    
    TranserCount 
*/

//local transfer = CreateClientConVar( "gs_chem_trans", string default, boolean shouldsave = true, boolean userinfo = false, string helptext = "", number min = nil, number max = nil )

if SERVER then
    util.AddNetworkString("gs_chem_transfer")
end

function ENT:ChemContainerInit()
    local tbl = self.ChemContainerData.Chems
    self.ChemContainer = CHEMIC_CONTAINER:New_Container(self, self.ChemContainerData.Max)
    self:SetNW2Int("Chems", 0)
end


function ENT:PostInit()
    //self.BaseClass.PostInit(self)
    self:ChemContainerInit()
    print("1123")
    self.RenderChem_Height = Vector(0, 0, h)
    self.RenderChem_Size = Vector(0, 0, 0)
    if CLIENT and self.RenderChem then
        self:InitRenderChem()
        self:SetNWVarProxy("Chems", function(_,_,_, new)
            //self:ChemContainerUpdate()
            if SERVER then return end
            //self:UpdateMesh(self.ChemContainerData.Max / new )
            print("UPDATE CHEMS", new)
            self:InitRenderChemColor() // can also update
            self:UpdateMesh(self:GetNW2Int("Chems") / self.ChemContainerData.Max  )
            print(self.ChemContainerData.Max , self:GetNW2Int("Chems"), self.ChemContainerData.Max / self:GetNW2Int("Chems"))
            //self:ChemContainerUpdate()
            
        end)

        self:SetNWVarProxy("ChemColor", function()
            if SERVER then return end

            //self:ChemContainerUpdate()
            //self:UpdateMesh(self.ChemContainerData.Max / self:GetNW2Int("Chems"))
            self:ChemContainerUpdate()
        end)
    end


    self:SetNW2Int("Transfer", 5)
end

function ENT:SetTransfer(amount)
    if CLIENT then
        net.Start("gs_chem_transfer")
        net.WriteEntity(self)
        net.WriteUInt(amount, 8)
        net.SendToServer()
    else
        self:SetNW2Int("Transfer", amount)
    end
end

local transfer_units = {1,2,5,10,15,20,30,40,50}

function ENT:SetupContextCallbacks()
    self:AddCustomContextCallback("transfer", function(btn, menu)
        local subMenu, opt = menu:AddSubMenu("Transfer amount...")
        subMenu:SetIcon("icon16/arrow_right.png")
        for k, v in ipairs(transfer_units) do
            local btn = subMenu:AddOption( v, function()
                self:SetTransfer(v)
            end)
        end
    end)
end

function ENT:ItemInteraction(item)
    // лить сюда ваду, мы ресивер
    item:TransferChems(self)
    return false
end

function ENT:ChemContainerUpdate()
    // обновление вады
    // её стало больше, смена цвета
    print("123")
    if SERVER then 
        print(self.ChemContainer:GetColor())
        self:SetNW2Int("Chems", self.ChemContainer:GetSum())
        print(self.ChemContainer:GetColor())
        self:SetNWVector("ChemColor", self.ChemContainer:GetColor():ToVector())
    else
        self:InitRenderChemColor() // can also update
        self:UpdateMesh(self:GetNW2Int("Chems")  )

        print(self.ChemContainerData.Max / self:GetNW2Int("Chems"))
    end
end

// льем в другое ведро из нашего, потом смешиваем
function ENT:TransferChems(receiver, amount)
    local rec_chem_cont = receiver.ChemContainer

    local transfer = amount or self:GetNW2Int("Transfer")
    
    if transfer < 1 then return false end

    local rec_amount = rec_chem_cont:GetSum()
    if transfer + rec_amount > rec_chem_cont.limit then
        transfer = transfer + (limit - rec_amount)
    end
    if transfer <= 0 then return false end

    local drop_chems = FormContent(self.ChemContainer)
    
    local pour = PourLiquid(drop_chems, transfer)

    self.ChemContainer.content = drop_chems
    
    for chem, unit in pairs(pour) do
        rec_chem_cont:AddUnit(chem, unit)
    end

    self:ChemContainerUpdate()
    rec_chem_cont:ChemContainerUpdate()

    rec_chem_cont:MixComp()
    return true
end

function ENT:AddChem(chem, unit)
    self.ChemContainer:AddUnit(chem, unit)
    self.ChemContainer:MixComp()
    self:ChemContainerUpdate()
end

local cache_verts = {}

local function FastGenVerts(ent)
    local mdl = ent:GetModel()
    //if ent.RenderChem_Data[mdl] then return end
    if cache_verts[mdl] then return cache_verts[mdl] end

    local data = ent.RenderChem_Data//[mdl]
    local origin = data.origin or vector_origin
    local seg = 20
    local cir = {}
    //local cir2 = {}
    //local radius = data.rad_max
    local radius2 = data.rad_min
    local min, max = data.height_min, data.height_max

    for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
        //table.insert( cir,  origin + Vector(math.sin( a ) * radius, math.cos( a ) * radius, max))
        table.insert( cir, origin + Vector(math.sin( a ) * radius2, math.cos( a ) * radius2, min))
	end

    cache_verts[mdl] = cir

    PrintTable(cache_verts)

    return cache_verts[mdl]
end

function ENT:InitRenderChemColor()
    local mat = self.RenderChem_Mat or Material("models/debug/debugwhite")
    local clr = self:GetNWVector("ChemColor")
    print(clr)
    local nclr = clr
    local a   = 0.5

    mat:SetVector("$color", nclr)
    mat:SetFloat("$alpha", math.Clamp(a, 0.1, 1))

    self.RenderChem_Mat = mat
end

// генерация водной глади
function ENT:InitRenderChem()
    if !self.RenderChem_Data then return end
    local verts = FastGenVerts(self)
    local data = self.RenderChem_Data
    local seg = 20

    local obj = Mesh()
    local v_up = Vector(0,0,1)
    local center = data.origin or Vector()

    mesh.Begin( obj, MATERIAL_TRIANGLES, #verts-1 )
    for i = 3, #verts do
        local pos = verts[1] 
        local dir = pos - center
        local u = dir.x / data.rad_max
        local v = dir.y / data.rad_max
        u = (u + 1) / 2
        v = (v + 1) / 2

        mesh.Position( pos )
        mesh.TexCoord( 0, u, v)
        mesh.Normal( v_up )
        mesh.AdvanceVertex()

        pos = verts[i]
        dir = pos - center
        u = dir.x / data.rad_max
        v = dir.y / data.rad_max
        u = (u + 1) / 2
        v = (v + 1) / 2

        mesh.Position( pos )
        mesh.TexCoord( 0, u, v)
        mesh.Normal(v_up )
        mesh.AdvanceVertex()

        pos = verts[i-1]
        dir = pos - center
        u = dir.x / data.rad_max
        v = dir.y / data.rad_max
        u = (u + 1) / 2
        v = (v + 1) / 2

        mesh.Position( pos )
        mesh.TexCoord( 0, u, v)
        mesh.Normal( v_up )
        mesh.AdvanceVertex()
        print(a, u, v)
    end
    mesh.End()

    self.RenderChem_Mesh = obj
    print(self.RenderChem_Mesh)
end

// обновление воды (не обновляет меш, только настройки для матрицы)
function ENT:UpdateMesh(level) // 0-1
    print("update mesh level", level)
    local data = self.RenderChem_Data

    local rad_max = data.rad_max
    local rad_min = data.rad_min
    local height_min = data.height_min
    local height_max = data.height_max

    //local max_level = self.ChemContainerData.Max
    local l = level /// max_level

    local rad = Lerp(l, rad_min, rad_max)
    local h =  Lerp(l, height_min , height_max) + height_max
    local size = rad / rad_min

    self.RenderChem_Size = Vector(size, size, 1)
    self.RenderChem_Height = Vector(0, 0, h)
    print(self.RenderChem_Size, self.RenderChem_Height )
end

function ENT:Draw()
    self:DrawModel()
    //print(self.RenderChem_Mesh)
    //PrintTable(self.RenderChem_Data)
    if !IsValid(self.RenderChem_Mesh) then return end
    if self:GetNW2Int("Chems") < 1 then return end 
    local msh = self.RenderChem_Mesh
    local size = self.RenderChem_Size
    local height = self.RenderChem_Height

    local m = Matrix()
    m:SetTranslation(self:LocalToWorld(height))
    m:SetScale(self.RenderChem_Size)
    m:Rotate(self:GetAngles())

    render.SetMaterial(self.RenderChem_Mat)
    cam.PushModelMatrix( m, true )
        msh:Draw()
    cam.PopModelMatrix()

end

net.Receive("gs_chem_transfer", function()
    local ent = net.ReadEntity()
    local amnt = net.ReadUInt(8)

    ent:SetTransfer(amnt)
end)