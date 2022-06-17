%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

func is_eq{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    a: felt,
    b: felt,
) -> (is_eq: felt):
    
    if a == b:
        return (
            is_eq = 1
        )
    end

    return (
        is_eq = 0
    )
end
