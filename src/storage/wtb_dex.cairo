%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

@storage_var
func strategy_asset_quantity_map_storage(
    strategy_address: felt,
    asset_address: felt,
) -> (
    quantity: Uint256
):
end


namespace WtbDexStorage:

    func read_strategy_asset_quantity{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        strategy_address: felt,
        asset_address: felt,
    ) -> (
        quantity: Uint256
    ):

        return strategy_asset_quantity_map_storage.read(
            strategy_address = strategy_address,
            asset_address = asset_address
        )
    end

    func update_strategy_asset_quantity_map{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        strategy_address: felt,
        asset_address: felt,
        quantity: Uint256,
    ) -> ():

        strategy_asset_quantity_map_storage.write(
            strategy_address = strategy_address,
            asset_address = asset_address,
            value = quantity
        )

        return ()
    end
    
end