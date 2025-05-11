/*
    нужна синхронизация!
    как минимум для equipment
    
    при подключении игрок не будет видеть чужие бэкпеки и тому подобное
*/

if SERVER then
    // if game started then send sync

    function StartSync(ply)
        //
    end

    hook.Add("PlayerInitialSpawn", "Syncing", StartSync )
end