%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

namespace OwnerLogic:

    func check_is_owner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        caller_address: felt,
        owner_address: felt,
    ) -> ():

        with_attr error_message("CALLER IS NOT OWNER"):
            assert caller_address = owner_address
        end
        
        return ()
    end

end