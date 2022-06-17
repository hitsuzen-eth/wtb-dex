%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace WtbDexInterface:
    func read_strategy_asset_balance(
        strategy_address: felt,
        asset_address: felt
    ) -> (
        quantity: Uint256
    ):
    end

    func update_strategy_increase_balance(
        sender_address: felt,
        asset_address: felt,
        asset_quantity: Uint256,
    ) -> ():
    end

    func update_strategy_decrease_balance(
        recipient_address: felt,
        asset_address: felt,
        asset_quantity: Uint256,
    ) -> ():
    end

    func create_swap(
        strategy_address: felt,
        position_id: felt,
        taker_wts_asset_address: felt,
        taker_wts_asset_quantity: Uint256,
        taker_wtb_asset_address: felt,
        taker_wtb_asset_min_quantity: Uint256
    ) -> ():
    end
end