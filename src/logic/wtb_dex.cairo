%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_le
)

namespace WtbDexLogic:

    func is_swap_valid{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        taker_wtb_asset_min_quantity: Uint256,
        taker_wtb_asset_quantity: Uint256,
        maker_wts_asset_quantity: Uint256
    ) -> (is_valid: felt):
        alloc_locals

        # Check if wtb min quantity by taker is less or equal to wtb quantity offered by maker
        let (local is_min_ok) = uint256_le(taker_wtb_asset_min_quantity, taker_wtb_asset_quantity)

        # Check that the strategy has enough wts asset to perform the swap 
        let (local is_funded) = uint256_le(maker_wts_asset_quantity, maker_wts_asset_quantity)

        # If both condition are true, swap is valid
        local is_valid = is_min_ok + is_funded

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