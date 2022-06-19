%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_le
)
from openzeppelin.security.safemath import SafeUint256

namespace WtbDexLogic:

    func is_swap_valid{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        taker_wtb_asset_min_quantity: Uint256,
        taker_wtb_asset_quantity: Uint256,
    ) -> (is_valid: felt):

        # Check if wtb min quantity by taker is less or equal to wtb quantity offered by maker
        let (is_min_ok) = uint256_le(taker_wtb_asset_min_quantity, taker_wtb_asset_quantity)

        return (
            is_valid = is_min_ok
        )
    end

    func swap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        taker_wts_asset_quantity: Uint256,
        taker_wtb_asset_quantity: Uint256,
        old_maker_wts_asset_quantity: Uint256,
        old_maker_wtb_asset_quantity: Uint256
    ) -> (
        maker_wts_asset_quantity: Uint256,
        maker_wtb_asset_quantity: Uint256
    ):
        alloc_locals

        # Decrease strategy maker want to sell asset(taker wtb = maker wts)
        let (maker_wts_asset_quantity) = SafeUint256.sub_le(old_maker_wts_asset_quantity, taker_wtb_asset_quantity)

        # Increase strategy maker want to buy asset(taker wts = maker wtb)
        let (maker_wtb_asset_quantity) = SafeUint256.add(old_maker_wtb_asset_quantity, taker_wts_asset_quantity)

        return (
            maker_wts_asset_quantity = maker_wts_asset_quantity,
            maker_wtb_asset_quantity = maker_wtb_asset_quantity,
        )
    end

end