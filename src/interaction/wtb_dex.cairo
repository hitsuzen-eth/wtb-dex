%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import (
    get_caller_address,
    get_contract_address
)
from starkware.cairo.common.uint256 import Uint256

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
        sender_address: felt,
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

        # Transfer asset from the sender(caller of strategy) to this contract
        IERC20.transferFrom(
            contract_address = asset_address,
            sender = sender_address,
            recipient = this_address,
            amount = asset_quantity
        )

        return ()
    end

    @external
    func update_strategy_decrease_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        recipient_address: felt,
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

        # Transfer asset from this contract to the recipient(caller of strategy)
        IERC20.transfer(
            contract_address = asset_address,
            recipient = recipient_address,
            amount = asset_quantity
        )

        return ()
    end

    @external
    func create_swap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        strategy_address: felt,
        position_id: felt,
        taker_wts_asset_address: felt,
        taker_wts_asset_quantity: Uint256,
        taker_wtb_asset_address: felt,
        taker_wtb_asset_min_quantity: Uint256
    ) -> ():
        alloc_locals

        # Compute quantity asset offered by this strategy
        let (local taker_wtb_asset_quantity) = StrategyInterface.create_swap(
            contract_address = strategy_address,
            position_id = position_id,
            taker_wts_asset_address = taker_wts_asset_address,
            taker_wts_asset_quantity = taker_wts_asset_quantity,
            taker_wtb_asset_address = taker_wtb_asset_address
        )

        # Fetch strategy maker want to sell quantity(taker wtb = maker wts)
        let (local old_maker_wts_asset_quantity) = WtbDexStorage.read_strategy_asset_quantity(
            strategy_address = strategy_address,
            asset_address = taker_wtb_asset_address
        )

        # Fetch strategy maker want to buy quantity(taker wts = maker wtb)
        let (local old_maker_wtb_asset_quantity) = WtbDexStorage.read_strategy_asset_quantity(
            strategy_address = strategy_address,
            asset_address = taker_wts_asset_address
        )

        # Check swap is valid
        let (is_valid) = WtbDexLogic.is_swap_valid(
            taker_wtb_asset_min_quantity = taker_wtb_asset_min_quantity,
            taker_wtb_asset_quantity = taker_wtb_asset_quantity,
            maker_wts_asset_quantity = old_maker_wts_asset_quantity
        )  
        assert_not_zero(is_valid)

        # Decrease strategy maker want to sell asset
        let (maker_wts_asset_quantity) = SafeUint256.sub_le(old_maker_wts_asset_quantity, taker_wtb_asset_quantity)
        WtbDexStorage.update_strategy_asset_quantity_map(
            strategy_address = strategy_address,
            asset_address = taker_wtb_asset_address,
            quantity = maker_wts_asset_quantity
        )

        # Increase strategy maker want to buy asset
        let (maker_wtb_asset_quantity) = SafeUint256.add(old_maker_wtb_asset_quantity, taker_wts_asset_quantity)
        WtbDexStorage.update_strategy_asset_quantity_map(
            strategy_address = strategy_address,
            asset_address = taker_wts_asset_address,
            quantity = maker_wtb_asset_quantity
        )
        
        let (local taker_address) = get_caller_address()
        let (local maker_address) = get_contract_address()

        # Transfer taker wts asset from the caller(taker) to this contract(maker)
        IERC20.transferFrom(
            contract_address = taker_wts_asset_address,
            sender = taker_address,
            recipient = maker_address,
            amount = taker_wts_asset_quantity
        )

        # Transfer maker wts asset from this contract(maker) to the caller(taker)
        IERC20.transfer(
            contract_address = taker_wtb_asset_address,
            recipient = taker_address,
            amount = taker_wtb_asset_quantity
        )

        return ()
    end

end