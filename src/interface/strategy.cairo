%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace StrategyInterface:
    func create_swap(
        position_id: felt,
        taker_wts_asset_address: felt,
        taker_wts_asset_quantity: Uint256,
        taker_wtb_asset_address: felt
    ) -> (
        taker_wtb_asset_quantity: Uint256
    ):
    end
end