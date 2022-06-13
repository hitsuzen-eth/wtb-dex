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
        asset_address: felt,
        asset_quantity: Uint256,
    ) -> ():
    end

    func update_strategy_decrease_balance(
        asset_address: felt,
        asset_quantity: Uint256,
    ) -> ():
    end

    func create_swap(
        strategy_address: felt,
        position_id: felt,
        asset_in_address: felt,
        asset_in_quantity: Uint256,
        asset_out_address: felt,
        asset_out_min_quantity: Uint256
    ) -> ():
    end
end