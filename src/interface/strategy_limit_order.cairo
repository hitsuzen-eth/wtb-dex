%lang starknet

from starkware.cairo.common.uint256 import Uint256

from src.type.limit_order_position import LimitOrderPositionStruct

@contract_interface
namespace StrategyLimitOrderInterface:
    func create_swap(
        position_id: felt,
        asset_in_address: felt,
        asset_in_quantity: Uint256,
        asset_out_address: felt
    ) -> (
        quantity: Uint256
    ):
    end

    func read_wtb_dex_address(
    ) -> (
        wtb_dex_address: felt
    ):
    end

    func create_position(
        owner_address: felt,
        asset_in_address: felt,
        asset_in_quantity: Uint256,
        asset_out_address: felt,
        asset_out_min_quantity: Uint256,
        is_partial: felt
    ) -> (
        position_id: felt
    ):
    end

    func read_position(
        position_id: felt,
    ) -> (
        position: LimitOrderPositionStruct
    ):
    end

    func update_position_owner_address(
        position_id: felt,
        owner_address: felt,
    ) -> (
    ):
    end

    func update_position_increase_asset_in(
        position_id: felt,
        asset_quantity: Uint256,
    ) -> (
    ):
    end

    func update_position_decrease_asset_in(
        position_id: felt,
        asset_quantity: Uint256,
    ) -> (
    ):
    end

    func update_position_decrease_asset_out(
        position_id: felt,
        asset_quantity: Uint256,
    ) -> (
    ):
    end

    func update_position_is_partial(
        position_id: felt,
        is_partial: felt,
    ) -> (
    ):
    end

    func update_position_asset_out_min_quantity(
        position_id: felt,
        asset_out_min_quantity: Uint256,
    ) -> (
    ):
    end
end