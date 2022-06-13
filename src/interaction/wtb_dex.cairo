%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import (
    get_caller_address,
    get_contract_address
)
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_le
)

from openzeppelin.security.safemath import SafeUint256
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20


from src.storage.wtb_dex import WtbDexStorage
from src.logic.wtb_dex import WtbDexLogic
from src.interface.strategy import StrategyInterface

namespace WtbDexInteraction:



    @external
    func read_strategy_asset_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        strategy_address: felt,
        asset_address: felt
    ) -> (quantity: Uint256):

        return WtbDexStorage.read_strategy_asset_quantity(
            strategy_address = strategy_address,
            asset_address = asset_address,
        )
    end

    @external
    func update_strategy_increase_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset_address: felt,
        asset_quantity: Uint256,
    ) -> ():
        alloc_locals

        let (local strategy_address) = get_caller_address()
        let (local this_address) = get_contract_address()

        # Fetch strategy asset quantity
        let (local asset_quantity_owned) = WtbDexStorage.read_strategy_asset_quantity(
            strategy_address = strategy_address,
            asset_address = asset_address
        )

        # Increase strategy asset balance
        let (local _quantity) = SafeUint256.add(asset_quantity_owned, asset_quantity)
        WtbDexStorage.update_strategy_asset_quantity_map(
            strategy_address = strategy_address,
            asset_address = asset_address,
            quantity = _quantity
        )

        # Transfer asset from the caller(strategy) to this contract
        IERC20.transferFrom(
            contract_address = asset_address,
            sender = strategy_address,
            recipient = this_address,
            amount = asset_quantity
        )

        return ()
    end

    @external
    func update_strategy_decrease_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset_address: felt,
        asset_quantity: Uint256,
    ) -> ():
        alloc_locals

        let (local strategy_address) = get_caller_address()

        # Fetch strategy asset quantity
        let (local asset_quantity_owned) = WtbDexStorage.read_strategy_asset_quantity(
            strategy_address = strategy_address,
            asset_address = asset_address
        )

        # Check enough asset to decrease
        # Decrease strategy asset balance
        let (local _quantity) = SafeUint256.sub_le(asset_quantity_owned, asset_quantity)
        WtbDexStorage.update_strategy_asset_quantity_map(
            strategy_address = strategy_address,
            asset_address = asset_address,
            quantity = _quantity
        )

        # Transfer asset from this contract to the caller(strategy)
        IERC20.transfer(
            contract_address = asset_address,
            recipient = strategy_address,
            amount = asset_quantity
        )

        return ()
    end

    @external
    func create_swap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        strategy_address: felt,
        position_id: felt,
        asset_in_address: felt,
        asset_in_quantity: Uint256,
        asset_out_address: felt,
        asset_out_min_quantity: Uint256
    ) -> ():
        alloc_locals

        # Compute quantity asset offered by this strategy
        let (local asset_out_quantity_offered) = StrategyInterface.create_swap(
            contract_address = strategy_address,
            position_id = position_id,
            asset_in_address = asset_in_address,
            asset_in_quantity = asset_in_quantity,
            asset_out_address = asset_out_address
        )

        # Fetch strategy asset_in quantity
        let (local asset_in_quantity_owned) = WtbDexStorage.read_strategy_asset_quantity(
            strategy_address = strategy_address,
            asset_address = asset_in_address
        )

        # Fetch strategy asset_out quantity
        let (local asset_out_quantity_owned) = WtbDexStorage.read_strategy_asset_quantity(
            strategy_address = strategy_address,
            asset_address = asset_out_address
        )

        # Check swap is valid
        let (is_valid) = WtbDexLogic.is_swap_valid(
            asset_out_min_quantity = asset_out_min_quantity,
            asset_out_quantity_offered = asset_out_quantity_offered,
            asset_out_quantity_owned = asset_out_quantity_owned
        )  
        assert_not_zero(is_valid)

        # Decrease strategy asset_out balance
        let (local _quantity) = SafeUint256.sub_le(asset_out_quantity_owned, asset_out_quantity_offered)
        WtbDexStorage.update_strategy_asset_quantity_map(
            strategy_address = strategy_address,
            asset_address = asset_out_address,
            quantity = _quantity
        )

        # Increase strategy asset_in balance
        let (local _quantity) = SafeUint256.add(asset_in_quantity_owned, asset_in_quantity)
        WtbDexStorage.update_strategy_asset_quantity_map(
            strategy_address = strategy_address,
            asset_address = asset_in_address,
            quantity = _quantity
        )
        
        let (local taker_address) = get_caller_address()
        let (local maker_address) = get_contract_address()

        # Transfer asset_in from the caller(taker) to this contract(maker)
        IERC20.transferFrom(
            contract_address = asset_in_address,
            sender = taker_address,
            recipient = maker_address,
            amount = asset_in_quantity
        )

        # Transfer asset_out from this contract(maker) to the caller(taker)
        IERC20.transfer(
            contract_address = asset_out_address,
            recipient = taker_address,
            amount = asset_out_quantity_offered
        )

        return ()
    end

end