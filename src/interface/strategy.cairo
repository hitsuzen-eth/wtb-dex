%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace StrategyInterface:
    func create_swap(
        position_id: felt,
        asset_in_address: felt,
        asset_in_quantity: Uint256,
        asset_out_address: felt
    ) -> (
        quantity: Uint256
    ):
    end
end