-- init chem container if have

ENT.ChemContainer = nil

/*
this data only for initialize, in init this will be ChemContainer object

ENT.ChemContainer = {
    Limit = 100,
    
    -- if we want to make empty bucket, Chems = nil
    Chems = {
        some_chem_id = 20,
    }
}
*/

function ENT:ChemContainerInit()
    local tbl = self.ChemContainer.Chems
    self.ChemContainer = CHEMIC_CONTAINER:New_Container(self, self.ChemContainer.Max)
end