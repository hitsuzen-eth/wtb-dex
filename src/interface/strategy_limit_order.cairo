%lang starknet

from starkware.cairo.common.uint256 import Uint256

from src.type.limit_order_position import LimitOrderPositionStruct

@contract_interface
namespace StrategyLimitOrderInterface:
    func create_swap(
        position_id: felt,
        taker_wts_asset_address: felt,
        taker_wts_asset_quantity: Uint256,
        taker_wtb_asset_address: felt
    ) -> (
        taker_wtb_asset_quantity: Uint256
    ):
    end

    func read_wtb_dex_address(
    ) -> (
        wtb_dex_address: felt
    ):
    end

    func create_position(
        owner_address: felt,
        maker_wts_asset_address: felt,
        maker_wts_asset_quantity: Uint256,
        maker_wtb_asset_address: felt,
        maker_wtb_asset_min_quantity: Uint256,
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

    func update_position_increase_wts_asset(
        position_id: felt,
        deposit_asset_quantity: Uint256,
    ) -> (
    ):
    end

    func update_position_decrease_wts_asset(
        position_id: felt,
        withdraw_asset_quantity: Uint256,
    ) -> (
    ):
    end

    func update_position_decrease_wtb_asset(
        position_id: felt,
        withdraw_asset_quantity: Uint256,
    ) -> (
    ):
    end

    func update_position_wtb_asset_min_quantity(
        position_id: felt,
        maker_wtb_asset_min_quantity: Uint256,
    ) -> (
    ):
    end

    func update_position_is_partial(
        position_id: felt,
        is_partial: felt,
    ) -> (
    ):
    end
end