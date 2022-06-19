%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_eq
)
from starkware.cairo.common.math_cmp import is_not_zero
from openzeppelin.security.safemath import SafeUint256
from src.lib.mul_div import mul_div
from src.lib.is_eq import is_eq

namespace StrategyLimitOrderLogic:

    func deposit_asset_wts{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        deposit_asset_quantity: Uint256,
        old_maker_wts_asset_quantity: Uint256,
        old_maker_wtb_asset_min_quantity: Uint256,
    ) -> (
        maker_wts_asset_quantity: Uint256,
        maker_wtb_asset_min_quantity: Uint256,
    ):
        alloc_locals

        # Increase balance of maker want to sell asset
        let (local maker_wts_asset_quantity) = SafeUint256.add(old_maker_wts_asset_quantity, deposit_asset_quantity)

        # Compute maker want to buy asset min quantity for this deposit => ( deposit * wtb ) / wts
        let (local maker_wtb_asset_min_quantity) = mul_div(
            x = deposit_asset_quantity,
            y = old_maker_wtb_asset_min_quantity,
            z = old_maker_wts_asset_quantity,
        )

        # Increase expected maker want to buy quantity
        let (local maker_wtb_asset_min_quantity) = SafeUint256.add(maker_wtb_asset_min_quantity, old_maker_wtb_asset_min_quantity)

        return (
            maker_wts_asset_quantity = maker_wts_asset_quantity,
            maker_wtb_asset_min_quantity = maker_wtb_asset_min_quantity,
        )
    end

    func withdraw_asset_wts{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        withdraw_asset_quantity: Uint256,
        old_maker_wts_asset_quantity: Uint256,
        old_maker_wtb_asset_min_quantity: Uint256,
    ) -> (
        maker_wts_asset_quantity: Uint256,
        maker_wtb_asset_min_quantity: Uint256,
    ):
        alloc_locals

        # Decrease balance of maker want to sell asset
        let (local maker_wts_asset_quantity) = SafeUint256.sub_le(old_maker_wts_asset_quantity, withdraw_asset_quantity)

        # Compute new maker wtb asset for this withdraw => ( withdraw * wtb ) / wts
        let (local maker_wtb_asset_min_quantity) = mul_div(
            x = withdraw_asset_quantity,
            y = old_maker_wtb_asset_min_quantity,
            z = old_maker_wts_asset_quantity,
        )

        # Decrease asset want to buy min quantity
        let (local maker_wtb_asset_min_quantity) = SafeUint256.sub_le(old_maker_wtb_asset_min_quantity, maker_wtb_asset_min_quantity)

        return (
            maker_wts_asset_quantity = maker_wts_asset_quantity,
            maker_wtb_asset_min_quantity = maker_wtb_asset_min_quantity,
        )
    end

    func swap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        taker_wts_asset_quantity: Uint256,
        old_maker_wts_asset_quantity: Uint256,
        old_maker_wtb_asset_quantity: Uint256,
        old_maker_wtb_asset_min_quantity: Uint256,
    ) -> (
        taker_wtb_asset_quantity: Uint256,
        maker_wts_asset_quantity: Uint256,
        maker_wtb_asset_quantity: Uint256,
        maker_wtb_asset_min_quantity: Uint256,
    ):
        alloc_locals

        # Compute taker want to buy asset quantity for this swap => ( taker_wts * maker_wts ) / maker_wtb
        let (local taker_wtb_asset_quantity) = mul_div(
            x = taker_wts_asset_quantity,
            y = old_maker_wts_asset_quantity,
            z = old_maker_wtb_asset_min_quantity,
        )

        # Increase balance of maker want to buy asset and decrease min by same amount
        let (local maker_wtb_asset_quantity) = SafeUint256.add(old_maker_wtb_asset_quantity, taker_wts_asset_quantity)
        let (local maker_wtb_asset_min_quantity) = SafeUint256.sub_le(old_maker_wtb_asset_min_quantity, taker_wts_asset_quantity)

        # Decrease balance of maker want to sell asset
        let (local maker_wts_asset_quantity) = SafeUint256.sub_le(old_maker_wts_asset_quantity, taker_wtb_asset_quantity)

        return (
            taker_wtb_asset_quantity = taker_wtb_asset_quantity,
            maker_wts_asset_quantity = maker_wts_asset_quantity,
            maker_wtb_asset_quantity = maker_wtb_asset_quantity,
            maker_wtb_asset_min_quantity = maker_wtb_asset_min_quantity,
        )
    end

    func is_swap_valid{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        taker_wts_asset_address: felt,
        taker_wts_asset_quantity: Uint256,
        taker_wtb_asset_address: felt,
        maker_wts_asset_address: felt,
        maker_wtb_asset_address: felt,
        maker_wtb_min_asset_quantity: Uint256,
        is_partial: felt
    ) -> (is_valid: felt):
        alloc_locals

        # Check if maker want to buy asset is same as taker want to sell asset
        let (is_valid) = is_eq(maker_wtb_asset_address, taker_wts_asset_address)
        if is_valid == 0:
            return (
                is_valid = is_valid
            )
        end
        # Check if maker want to sell asset is same as taker want to buy asset
        let (is_valid) = is_eq(maker_wts_asset_address, taker_wtb_asset_address)
        if is_valid == 0:
            return (
                is_valid = is_valid
            )
        end

        # Check if position is fully filled
        let (local is_full_filled) = uint256_eq(maker_wtb_min_asset_quantity, taker_wts_asset_quantity)

        # Need to be fully filled if partial is not allowed
        let (is_valid) = is_not_zero(is_full_filled + is_partial)

        return (
            is_valid = is_valid
        )
    end

end