%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address

from src.storage.wtb_dex import WtbDexStorage
from src.type.strategy import StrategyInterface

namespace WtbDexInteraction:

    @external
    func read_strategy_asset_quantity{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        strategy_address: felt,
        asset_address: felt
    ) -> (quantity: felt):

        return WtbDexStorage.read_strategy_asset_quantity_storage(
            strategy_address = strategy_address,
            asset_address = asset_address
        )
    end

    @external
    func update_strategy_asset_quantity{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset_address: felt,
        quantity: felt
    ) -> ():

        let (strategy_address) = get_caller_address()

        return WtbDexStorage.update_strategy_asset_quantity_storage(
            strategy_address = strategy_address,
            asset_address = asset_address,
            quantity = quantity
        )
    end

    @external
    func create_swap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        strategy_address: felt,
        position_id: felt,
        asset_in_address: felt,
        asset_in_quantity: felt,
        asset_out_address: felt,
        asset_out_min_quantity: felt
    ) -> ():

        let (strategy_address) = get_caller_address()

        let (quantity) = StrategyInterface.create_swap(
            position_id = position_id,
            asset_in_address = asset_in_address,
            asset_in_quantity = asset_in_quantity,
            asset_out_address = asset_out_address
        )

        return WtbDexStorage.update_strategy_asset_quantity_storage(
            strategy_address = strategy_address,
            asset_address = asset_address,
            quantity = quantity
        )
    end

end