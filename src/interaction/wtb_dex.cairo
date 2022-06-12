%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_le
from starkware.starknet.common.syscalls import (
    get_caller_address,
    get_contract_address
)

from openzeppelin.token.erc20.interfaces.IERC20 from IERC20


from src.storage.wtb_dex import WtbDexStorage
from src.interface.strategy import StrategyInterface

namespace WtbDexInteraction:

    @external
    func create_strategy{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> ():

        let (strategy_address) = get_caller_address()

        let (last_id) = WtbDexStorage.read_strategy_list_last_id_storage()

        WtbDexStorage.update_strategy_asset_quantity_storage(
            id = last_id,
            strategy_address = strategy_address
        )
        WtbDexStorage.update_strategy_list_last_id_storage(
            last_id = (last_id + 1)
        )
    end

    @external
    func read_strategy{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        id: felt
    ) -> (strategy_address: felt):

        return WtbDexStorage.strategy_list_storage(
            id = id
        )
    end

    @external
    func create_swap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        strategy_id: felt,
        position_id: felt,
        asset_in_address: felt,
        asset_in_quantity: felt,
        asset_out_address: felt,
        asset_out_min_quantity: felt
    ) -> ():

        let (strategy_address) = WtbDexStorage.strategy_list_storage(
            id = strategy_id
        )

        let (quantity) = StrategyInterface.create_swap(
            contract_address = strategy_address,
            position_id = position_id,
            asset_in_address = asset_in_address,
            asset_in_quantity = asset_in_quantity,
            asset_out_address = asset_out_address
        )

        assert_le(asset_out_min_quantity, quantity)
        
        let (sender_asset_in) = get_caller_address()
        let (receiver_asset_in) = get_contract_address()

        IERC20.transferFrom(
            contract_address = asset_in_address,
            sender = sender_asset_in,
            recipient = receiver_asset_in,
            amount = asset_in_quantity
        )

        IERC20.transfer(
            contract_address = asset_out_address,
            recipient = sender_asset_in,
            amount = quantity
        )

        # NEED TO IMPLEMENT SOMETHING TO ALLOW WITHDRAW OF FUND(NEED INFO ON FEE UPDATE SAME VS DIFF)

        return ()
    end

end