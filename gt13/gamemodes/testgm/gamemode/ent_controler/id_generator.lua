--[[
        access. his whole idea
in the card we put information about the person and his access
--[[
    Private_Data = {
        Info = {
            Name = "Chupacbra",
            Job  = "Assistent",
            Another_Info = ...
        },
        Access = 3,
    }
    
    Access is a 32/16 binary key, where each number is an indicator of whether it has access to anything
    3 = 00000000000000000000000000000111
                                     |||
                            _________/|\________
                           /          |         \
                        exit       constr        civilian doors, lockers 
                    from station    site

    for example, an assistant is trying to get into the scientific zone
    the doors of the scientific zone request such access
    16 = 10000
    To check access, we do a logical operation AND

    000000000000000000000000000|0|0111|AND
                               |1|0000|
      --------------------------------|
                                     0|
    
    as you can see, the answer is zero and the door does not open
    now there is an access check with the scientist
    
    000000100001000000000000010|1|1111|AND
                               |1|0000|
      --------------------------------|
                                 10000|

    as we can see, the result is equal to the requested access and the scientist can pass
]]

GS_ID = {}

function GS_ID:PrestartGenerateID(char, access, job)

end

function CheckAccess(have, need)
    return bit.band(have, need) == need
end
