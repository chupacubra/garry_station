
GL_CLIENT_CHEM = {}
net.Receive("Chem_CLChemicalsList",function()
  local chem = {}
  local int = net.ReadInt(10)
  for _=0,int do
    local chems = net.ReadString()
    local tbl = string.Explode( "/", chems )
    GL_CLIENT_CHEM[tbl[1]] = tbl[2]
  end
  PrintTable(GL_CLIENT_CHEM)
end)

function list_length( t )
 
    local len = 0
    for _,_ in pairs( t ) do
        len = len + 1
    end
 
    return len
end
