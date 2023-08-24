GS_Job:CreateDept("med",{
    name  = "Medical unit",
    color = Color(255, 255, 255),
    b_access = 10, 
    b_items  = {
        equipment = {
            BACKPACK = {
                id = "simple_back",
                typ = "backpacks",
            },
            SUIT = {
                id = "suit_work",
                typ = "suit",
            },
        },
    },
    --b_suit   = "worker",
})

GS_Job:CreateJob("cargo_technician", {
    name = "Cargo Technician",
    dept = "cargo",
})