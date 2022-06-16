%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from openzeppelin.security.safemath import SafeUint256
from src.lib.mul_div import mul_div

namespace StrategyLimitOrderLogic:

    func deposit_asset_in{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset_quantity: Uint256,
        asset_in_position_quantity: Uint256,
        asset_out_position_min_quantity: Uint256,
    ) -> (
        asset_in_quantity: Uint256,
        asset_out_min_quantity: Uint256,
    ):
        alloc_locals

        # Increase balance of caller position
        let (local asset_in_quantity) = SafeUint256.add(asset_in_position_quantity, asset_quantity)

        # Compute asset_out_min_quantity for this deposit => ( deposit * out ) / in
        let (local asset_out_min_quantity) = mul_div(
            x = asset_quantity,
            y = asset_out_position_min_quantity,
            z = asset_in_position_quantity,
        )

        # Increase expected asset out min quantity
        let (local asset_out_min_quantity) = SafeUint256.add(asset_out_min_quantity, asset_out_position_min_quantity)

        return (
            asset_in_quantity = asset_in_quantity,
            asset_out_min_quantity = asset_out_min_quantity,
        )
    end

    func withdraw_asset_in{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset_quantity: Uint256,
        asset_in_position_quantity: Uint256,
        asset_out_position_min_quantity: Uint256,
    ) -> (
        asset_in_quantity: Uint256,
        asset_out_min_quantity: Uint256,
    ):
        alloc_locals

        # Decrease balance of caller position
        let (local asset_in_quantity) = SafeUint256.sub_le(asset_in_position_quantity, asset_quantity)

        # Compute asset_out_min_quantity for this withdraw => ( withdraw * out ) / in
        let (local asset_out_min_quantity) = mul_div(
            x = asset_quantity,
            y = asset_out_position_min_quantity,
            z = asset_in_position_quantity,
        )

        # Decrease expected asset out min quantity
        let (local asset_out_min_quantity) = SafeUint256.sub_le(asset_out_position_min_quantity, asset_out_min_quantity)

        return (
            asset_in_quantity = asset_in_quantity,
            asset_out_min_quantity = asset_out_min_quantity,
        )
    end

end