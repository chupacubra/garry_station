local hpicon = {
    "material/health_1.vmt",
    "material/health_2.vmt",
    "material/health_3.vmt",
    "material/health_4.vmt",
    "material/health_5.vmt",
    "material/health_6.vmt",
    "material/health_7.vmt",
    "material/health_8.vmt",
}

for k,v in pairs(hpicon) do
    resource.AddFile( v )
end
