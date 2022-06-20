%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_le,
    uint256_eq
)
from starkware.starknet.common.syscalls import get_caller_address

from openzeppelin.security.safemath import SafeUint256
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20

from src.storage.strategy_limit_order import StrategyLimitOrderStorage
from src.interface.wtb_dex import WtbDexInterface
from src.logic.owner import OwnerLogic
from src.logic.strategy_limit_order import StrategyLimitOrderLogic
from src.type.limit_order_position import LimitOrderPositionStruct


# One Limit order strategy is for testing purpose, in prod it's probably stupid
# Merkle tree of limit order + ipfs may be feasible
namespace StrategyLimitOrderInteraction:

    @constructor
    func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        wtb_dex_address : felt
    ):

        StrategyLimitOrderStorage.update_wtb_dex_address(wtb_dex_address)

        return ()
    end
    
    @external
    func create_swap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        taker_wts_asset_address: felt,
        taker_wts_asset_quantity: Uint256,
        taker_wtb_asset_address: felt
    ) -> (
        taker_wtb_asset_quantity: Uint256
    ):

        alloc_locals

        # Only wtb dex can create a swap
        let (local caller_address) = get_caller_address()
        let (local wtb_dex_address) = StrategyLimitOrderStorage.read_wtb_dex_address()
        OwnerLogic.check_is_owner(
            caller_address = caller_address,
            owner_address = wtb_dex_address
        )

        let (local position) = StrategyLimitOrderStorage.read_position(position_id)

        # Check if swap is valid
        let (is_valid) = StrategyLimitOrderLogic.is_swap_valid(
            taker_wts_asset_address = taker_wts_asset_address,
            taker_wts_asset_quantity = taker_wts_asset_quantity,
            taker_wtb_asset_address = taker_wtb_asset_address,
            maker_wts_asset_address = position.maker_wts_asset_address,
            maker_wtb_asset_address = position.maker_wtb_asset_address,
            maker_wtb_min_asset_quantity = position.maker_wtb_asset_min_quantity,
            is_partial = position.is_partial 
        )
        assert is_valid = 1

        # Compute swap quantity and decrease balance and expected asset quantity
        let (
            local taker_wtb_asset_quantity,
            local maker_wts_asset_quantity,
            local maker_wtb_asset_quantity,
            local maker_wtb_asset_min_quantity,
        ) = StrategyLimitOrderLogic.swap(
            taker_wts_asset_quantity = taker_wts_asset_quantity,
            old_maker_wts_asset_quantity = position.maker_wts_asset_quantity,
            old_maker_wtb_asset_quantity = position.maker_wtb_asset_quantity,
            old_maker_wtb_asset_min_quantity = position.maker_wtb_asset_min_quantity,
        )

        # Update position
        StrategyLimitOrderStorage.update_position(
            id = position_id,
            position = LimitOrderPositionStruct(
                owner_address = position.owner_address,
                maker_wts_asset_address = position.maker_wts_asset_address,
                maker_wts_asset_quantity = maker_wts_asset_quantity,
                maker_wtb_asset_address = position.maker_wtb_asset_address,
                maker_wtb_asset_quantity = maker_wtb_asset_quantity,
                maker_wtb_asset_min_quantity = maker_wtb_asset_min_quantity,
                is_partial = position.is_partial
            )
        )

        return (
            taker_wtb_asset_quantity = taker_wtb_asset_quantity
        )
    end

    @view
    func read_wtb_dex_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (wtb_dex_address: felt):
        return StrategyLimitOrderStorage.read_wtb_dex_address()
    end

    @external
    func create_position{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        owner_address: felt,
        maker_wts_asset_address: felt,
        maker_wts_asset_quantity: Uint256,
        maker_wtb_asset_address: felt,
        maker_wtb_asset_min_quantity: Uint256,
        is_partial: felt
    ) -> (
        position_id: felt
    ):

        alloc_locals

        # Save the caller position
        let (local position_id) = StrategyLimitOrderStorage.create_position(
            position = LimitOrderPositionStruct(
                owner_address = owner_address,
                maker_wts_asset_address = maker_wts_asset_address,
                maker_wts_asset_quantity = maker_wts_asset_quantity,
                maker_wtb_asset_address = maker_wtb_asset_address,
                maker_wtb_asset_quantity = Uint256(
                    low = 0,
                    high = 0
                ),
                maker_wtb_asset_min_quantity = maker_wtb_asset_min_quantity,
                is_partial = is_partial
            )
        )

        # Fetch WTB DEX address and caller address
        let (local wtb_dex_address) = StrategyLimitOrderStorage.read_wtb_dex_address()
        let (local caller_address) = get_caller_address()

        # Transfer maker wts asset from caller to WTB dex
        WtbDexInterface.update_strategy_increase_balance(
            contract_address = wtb_dex_address,
            sender_address = caller_address,
            asset_address = maker_wts_asset_address,
            asset_quantity = maker_wts_asset_quantity
        )
        
        return (
            position_id = position_id
        )
    end

    @view
    func read_position{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
    ) -> (position: LimitOrderPositionStruct):
        return StrategyLimitOrderStorage.read_position(position_id)
    end

    @external
    func update_position_owner_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        owner_address: felt,
    ) -> ():

        alloc_locals
        
        let (local caller_address) = get_caller_address()

        let (local position) = StrategyLimitOrderStorage.read_position(position_id)

        OwnerLogic.check_is_owner(
            caller_address = caller_address,
            owner_address = position.owner_address
        )

        StrategyLimitOrderStorage.update_position(
            id = position_id,
            position = LimitOrderPositionStruct(
                owner_address = owner_address, # Update owner_address
                maker_wts_asset_address = position.maker_wts_asset_address,
                maker_wts_asset_quantity = position.maker_wts_asset_quantity,
                maker_wtb_asset_address = position.maker_wtb_asset_address,
                maker_wtb_asset_quantity = position.maker_wtb_asset_quantity,
                maker_wtb_asset_min_quantity = position.maker_wtb_asset_min_quantity,
                is_partial = position.is_partial
            )
        )

        return ()
    end

    @external
    func update_position_increase_wts_asset{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        deposit_asset_quantity: Uint256,
    ) -> ():

        alloc_locals

        let (local position) = StrategyLimitOrderStorage.read_position(position_id)

        # Increase wts asset and wtb asset min quantity
        let (
            local maker_wts_asset_quantity,
            local maker_wtb_asset_min_quantity
        ) = StrategyLimitOrderLogic.deposit_asset_wts(
            deposit_asset_quantity = deposit_asset_quantity,
            old_maker_wts_asset_quantity = position.maker_wts_asset_quantity,
            old_maker_wtb_asset_min_quantity = position.maker_wtb_asset_min_quantity,
        )
        
        StrategyLimitOrderStorage.update_position(
            id = position_id,
            position = LimitOrderPositionStruct(
                owner_address = position.owner_address,
                maker_wts_asset_address = position.maker_wts_asset_address,
                maker_wts_asset_quantity = maker_wts_asset_quantity, # Update maker_wts_asset_quantity
                maker_wtb_asset_address = position.maker_wtb_asset_address,
                maker_wtb_asset_quantity = position.maker_wtb_asset_quantity,
                maker_wtb_asset_min_quantity = maker_wtb_asset_min_quantity, # Update maker_wtb_asset_min_quantity
                is_partial = position.is_partial
            )
        )

        # Fetch WTB DEX address
        let (local wtb_dex_address) = StrategyLimitOrderStorage.read_wtb_dex_address()

        let (local caller_address) = get_caller_address()

        # Transfer wts asset from caller to WTB dex
        WtbDexInterface.update_strategy_increase_balance(
            contract_address = wtb_dex_address,
            sender_address = caller_address,
            asset_address = position.maker_wts_asset_address,
            asset_quantity = deposit_asset_quantity
        )

        return ()
    end

    @external
    func update_position_decrease_wts_asset{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        withdraw_asset_quantity: Uint256,
    ) -> ():

        alloc_locals

        let (local position) = StrategyLimitOrderStorage.read_position(position_id)
        let (local caller_address) = get_caller_address()

        OwnerLogic.check_is_owner(
            caller_address = caller_address,
            owner_address = position.owner_address
        )

        # Decrease want to sell quantity and want to buy min quantity
        let (
            maker_wts_asset_quantity,
            maker_wtb_asset_min_quantity
        ) = StrategyLimitOrderLogic.withdraw_asset_wts(
            withdraw_asset_quantity = withdraw_asset_quantity,
            old_maker_wts_asset_quantity = position.maker_wts_asset_quantity,
            old_maker_wtb_asset_min_quantity = position.maker_wtb_asset_min_quantity,
        )
        
        StrategyLimitOrderStorage.update_position(
            id = position_id,
            position = LimitOrderPositionStruct(
                owner_address = position.owner_address,
                maker_wts_asset_address = position.maker_wts_asset_address,
                maker_wts_asset_quantity = maker_wts_asset_quantity, # Update maker_wts_asset_quantity
                maker_wtb_asset_address = position.maker_wtb_asset_address,
                maker_wtb_asset_quantity = position.maker_wtb_asset_quantity,
                maker_wtb_asset_min_quantity = maker_wtb_asset_min_quantity, # Update maker_wtb_asset_min_quantity
                is_partial = position.is_partial
            )
        )

        # Fetch WTB DEX address
        let (local wtb_dex_address) = StrategyLimitOrderStorage.read_wtb_dex_address()

        # Transfer want to sell asset from WTB dex to caller
        WtbDexInterface.update_strategy_decrease_balance(
            contract_address = wtb_dex_address,
            recipient_address = caller_address,
            asset_address = position.maker_wts_asset_address,
            asset_quantity = withdraw_asset_quantity
        )

        return ()
    end

    @external
    func update_position_decrease_wtb_asset{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        withdraw_asset_quantity: Uint256,
    ) -> ():

        alloc_locals

        let (local position) = StrategyLimitOrderStorage.read_position(position_id)
        let (local caller_address) = get_caller_address()

        OwnerLogic.check_is_owner(
            caller_address = caller_address,
            owner_address = position.owner_address
        )

        # Decrease wtb asset of caller position
        let (maker_wtb_asset_quantity) = SafeUint256.sub_le(position.maker_wtb_asset_quantity, withdraw_asset_quantity)
        
        StrategyLimitOrderStorage.update_position(
            id = position_id,
            position = LimitOrderPositionStruct(
                owner_address = position.owner_address,
                maker_wts_asset_address = position.maker_wts_asset_address,
                maker_wts_asset_quantity = position.maker_wts_asset_quantity,
                maker_wtb_asset_address = position.maker_wtb_asset_address,
                maker_wtb_asset_quantity = maker_wtb_asset_quantity, # Update maker_wtb_asset_quantity
                maker_wtb_asset_min_quantity = position.maker_wtb_asset_min_quantity,
                is_partial = position.is_partial
            )
        )

        # Fetch WTB DEX address
        let (local wtb_dex_address) = StrategyLimitOrderStorage.read_wtb_dex_address()

        # Transfer asset_out from WTB dex to caller
        WtbDexInterface.update_strategy_decrease_balance(
            contract_address = wtb_dex_address,
            recipient_address = caller_address,
            asset_address = position.maker_wtb_asset_address,
            asset_quantity = withdraw_asset_quantity
        )
        
        return ()
    end

    @external
    func update_position_wtb_asset_min_quantity{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        maker_wtb_asset_min_quantity: Uint256,
    ) -> ():

        alloc_locals

        let (local caller_address) = get_caller_address()

        let (local position) = StrategyLimitOrderStorage.read_position(position_id)

        OwnerLogic.check_is_owner(
            caller_address = caller_address,
            owner_address = position.owner_address
        )
        
        StrategyLimitOrderStorage.update_position(
            id = position_id,
            position = LimitOrderPositionStruct(
                owner_address = position.owner_address,
                maker_wts_asset_address = position.maker_wts_asset_address,
                maker_wts_asset_quantity = position.maker_wts_asset_quantity,
                maker_wtb_asset_address = position.maker_wtb_asset_address,
                maker_wtb_asset_quantity = position.maker_wtb_asset_quantity,
                maker_wtb_asset_min_quantity = maker_wtb_asset_min_quantity, # Update maker_wtb_asset_min_quantity
                is_partial = position.is_partial
            )
        )
        return ()
    end

    @external
    func update_position_is_partial{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        is_partial: felt,
    ) -> ():

        alloc_locals

        let (caller_address) = get_caller_address()

        let (local position) = StrategyLimitOrderStorage.read_position(position_id)

        OwnerLogic.check_is_owner(
            caller_address = caller_address,
            owner_address = position.owner_address
        )
        
        StrategyLimitOrderStorage.update_position(
            id = position_id,
            position = LimitOrderPositionStruct(
                owner_address = position.owner_address,
                maker_wts_asset_address = position.maker_wts_asset_address,
                maker_wts_asset_quantity = position.maker_wts_asset_quantity,
                maker_wtb_asset_address = position.maker_wtb_asset_address,
                maker_wtb_asset_quantity = position.maker_wtb_asset_quantity,
                maker_wtb_asset_min_quantity = position.maker_wtb_asset_min_quantity,
                is_partial = is_partial # Update is_partial
            )
        )
        return ()
    end

end