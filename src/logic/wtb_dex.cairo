%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_le
)

namespace WtbDexLogic:

    func is_swap_valid{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset_out_min_quantity: Uint256,
        asset_out_quantity_offered: Uint256,
        asset_out_quantity_owned: Uint256
    ) -> (is_valid: felt):
        alloc_locals

        # Check if the quantity offered match the min quantity asked by caller
        let (local is_offered_gt_min) = uint256_le(asset_out_min_quantity, asset_out_quantity_offered)

        # Check that the strategy has enough asset_out to perform the swap 
        let (local is_owned_gt_offered) = uint256_le(asset_out_quantity_offered, asset_out_quantity_owned)

        # If both condition are true, swap is valid
        local is_valid = is_offered_gt_min + is_owned_gt_offered

        if is_valid == 2:
            return (
                is_valid = 1
            )
        end

        return (
            is_valid = 0
        )
    end

end