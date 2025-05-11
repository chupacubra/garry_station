-- init chem container if have
ENT.Base = "gs_entity"

ENT.ChemContainerInit = {
    Max = 100,
    Chems = {}
}

/*
this data only for initialize, in init this will be ChemContainer object

ENT.ChemContainer = {
    Max = 100,
    -- if we want to make empty bucket, Chems = nil
    Chems = {
        some_chem_id = 20,
    }
}
*/

function ENT:ChemContainerInit()
    local tbl = self.ChemContainer.Chems
    self.ChemContainer = CHEMIC_CONTAINER:New_Container(self, self.ChemContainerInit.Max)
    // TODO: add from self.ChemContainer =
end

function ENT:PostInit()
    self:ChemContainerInit()
end