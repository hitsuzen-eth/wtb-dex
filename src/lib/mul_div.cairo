%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from openzeppelin.security.safemath import SafeUint256

func mul_div{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    x: Uint256,
    y: Uint256,
    z: Uint256,
) -> (x_times_y_div_by_z: Uint256):
    alloc_locals

    let (local x_times_y_div_by_z) = SafeUint256.mul(x, y)
    let (local x_times_y_div_by_z, _) = SafeUint256.div_rem(x_times_y_div_by_z, z)

    return (
        x_times_y_div_by_z = x_times_y_div_by_z
    )
end
