%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address

from openzeppelin.security.safemath import SafeUint256
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20

from src.storage.strategy_limit_order import StrategyLimitOrderStorage
from src.interface.wtb_dex import WtbDexInterface
from src.logic.owner import OwnerLogic

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
        asset_in_address: felt,
        asset_in_quantity: Uint256,
        asset_out_address: felt
    ) -> (
        quantity: Uint256
    ):
        return ()
    end

    @external
    func read_wtb_dex_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (wtb_dex_address: felt):
        return StrategyLimitOrderStorage.read_wtb_dex_address()
    end

    @external
    func create_position{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        owner_address: felt,
        limit_asset_price: Uint256,
        asset_in_address: felt,
        asset_in_quantity: Uint256,
        asset_out_address: felt,
        is_partial: felt
    ) -> (
        position_id: felt
    ):

        alloc_locals

        # Save the caller position
        let (local position_id) = StrategyLimitOrderStorage.create_position(
            position = LimitOrderPositionStruct(
                owner_address = owner_address,
                limit_asset_price = limit_asset_price,
                asset_in_address = asset_in_address,
                asset_in_quantity = asset_in_quantity,
                asset_out_address = asset_out_address,
                asset_out_quantity = Uint256(
                    low = 0,
                    high = 0
                ),
                is_partial = is_partial
            )
        )

        # Fetch WTB DEX address and caller address
        let (local wtb_dex_address) = StrategyLimitOrderStorage.read_wtb_dex_address()
        let (local caller_address) = get_caller_address()

        # Transfer asset_in from caller to WTB dex
        WtbDexInterface.update_strategy_increase_balance(
            contract_address = wtb_dex_address,
            sender_address = caller_address,
            asset_address = asset_in_address,
            asset_quantity = asset_in_quantity
        )
        
        return ()
    end

    @external
    func read_position{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
    ) -> (position: StrategyLimitOrderStorage):
        return StrategyLimitOrderStorage.read_position(position_id)
    end

    @external
    func update_position_owner_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        owner_address: felt,
    ) -> ():

        let (caller_address) = get_caller_address()

        let (local position) = StrategyLimitOrderStorage.read_position(position_id)

        OwnerLogic.check_is_owner(
            caller_address = caller_address,
            owner_address = position.owner_address
        )

        position.owner_address = owner_address

        StrategyLimitOrderStorage.update_position(
            id = position_id,
            position = position
        )

        return ()
    end

    @external
    func update_position_limit_asset_price{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        limit_asset_price: Uint256,
    ) -> ():

        let (caller_address) = get_caller_address()

        let (local position) = StrategyLimitOrderStorage.read_position(position_id)

        OwnerLogic.check_is_owner(
            caller_address = caller_address,
            owner_address = position.owner_address
        )
        
        position.limit_asset_price = limit_asset_price
        
        StrategyLimitOrderStorage.update_position(
            id = position_id,
            position = position
        )
        return ()
    end

    @external
    func update_position_increase_asset_in{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        asset_quantity: Uint256,
    ) -> ():

        let (local position) = StrategyLimitOrderStorage.read_position(position_id)

        # Increase balance of caller position
        position.asset_in_quantity = SafeUint256.add(position.asset_in_quantity, asset_quantity)
        
        StrategyLimitOrderStorage.update_position(
            id = position_id,
            position = position
        )

        # Fetch WTB DEX address
        let (local wtb_dex_address) = StrategyLimitOrderStorage.read_wtb_dex_address()

        let (local caller_address) = get_caller_address()

        # Transfer asset_in from caller to WTB dex
        IERC20.transferFrom(
            contract_address = position.asset_in_address,
            sender = caller_address,
            recipient = wtb_dex_address,
            amount = asset_quantity
        )

        return ()
    end

    @external
    func update_position_decrease_asset_in{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        asset_quantity: Uint256,
    ) -> ():

        let (local position) = StrategyLimitOrderStorage.read_position(position_id)

        # Decrease balance of caller position
        position.asset_in_quantity = SafeUint256.(position.asset_in_quantity, asset_quantity)
        
        StrategyLimitOrderStorage.update_position(
            id = position_id,
            position = position
        )

        # Fetch WTB DEX address
        let (local wtb_dex_address) = StrategyLimitOrderStorage.read_wtb_dex_address()

        let (local caller_address) = get_caller_address()

        # Transfer asset_in from caller to WTB dex
        IERC20.transferFrom(
            contract_address = position.asset_in_address,
            sender = caller_address,
            recipient = wtb_dex_address,
            amount
        return ()
    end

    @external
    func update_position_increase_asset_out{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        asset_quantity: Uint256,
    ) -> ():

        let (local position) = StrategyLimitOrderStorage.read_position(position_id)

        position.limit_asset_price = limit_asset_price
        
        StrategyLimitOrderStorage.update_position(
            id = position_id,
            position = position
        )
        return ()
    end

    @external
    func update_position_decrease_asset_out{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        asset_quantity: Uint256,
    ) -> ():

        let (local position) = StrategyLimitOrderStorage.read_position(position_id)

        position.limit_asset_price = limit_asset_price
        
        StrategyLimitOrderStorage.update_position(
            id = position_id,
            position = position
        )
        return ()
    end

    @external
    func update_position_is_partial{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        is_partial: felt,
    ) -> ():

        let (local position) = StrategyLimitOrderStorage.read_position(position_id)

        position.limit_asset_price = limit_asset_price
        
        StrategyLimitOrderStorage.update_position(
            id = position_id,
            position = position
        )
        return ()
    end

end