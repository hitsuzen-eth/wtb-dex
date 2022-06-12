%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

@storage_var
func strategy_asset_quantity_storage(
    strategy_address: felt,
    asset_address: felt
) -> (
    quantity: felt
):
end

namespace WtbDexStorage:

    func read_strategy_asset_quantity_storage{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        strategy_address: felt,
        asset_address: felt
    ) -> (
        quantity: felt
    ):

        return strategy_asset_quantity_storage.read(
            strategy_address = strategy_address,
            asset_address = asset_address
        )
    end

    func update_strategy_asset_quantity_storage{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        strategy_address: felt,
        asset_address: felt,
        quantity: felt
    ) -> ():

        strategy_asset_quantity_storage.write(
            strategy_address = strategy_address,
            asset_address = asset_address,
            value = quantity
        )

        return ()
    end
    
end