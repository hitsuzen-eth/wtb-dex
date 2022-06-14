%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address

from openzeppelin.security.safemath import SafeUint256
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20

from src.storage.strategy_limit_order import StrategyLimitOrderStorage
from src.interface.wtb_dex import WtbDexInterface
from src.logic.owner import OwnerLogic
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
        asset_in_address: felt,
        asset_in_quantity: Uint256,
        asset_out_address: felt
    ) -> (
        quantity: Uint256
    ):

        let quantity: Uint256 = Uint256(
            low = 0,
            high = 0
        )

        return (
            quantity = quantity
        )
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
        
        return (
            position_id = position_id
        )
    end

    @external
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
                limit_asset_price = position.limit_asset_price,
                asset_in_address = position.asset_in_address,
                asset_in_quantity = position.asset_in_quantity,
                asset_out_address = position.asset_out_address,
                asset_out_quantity = position.asset_out_quantity,
                is_partial = position.is_partial
            )
        )

        return ()
    end

    @external
    func update_position_limit_asset_price{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        limit_asset_price: Uint256,
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
                limit_asset_price = limit_asset_price, # Update limit_asset_price
                asset_in_address = position.asset_in_address,
                asset_in_quantity = position.asset_in_quantity,
                asset_out_address = position.asset_out_address,
                asset_out_quantity = position.asset_out_quantity,
                is_partial = position.is_partial
            )
        )
        return ()
    end

    @external
    func update_position_increase_asset_in{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        asset_quantity: Uint256,
    ) -> ():

        alloc_locals

        let (local position) = StrategyLimitOrderStorage.read_position(position_id)

        # Increase balance of caller position
        let (local asset_in_quantity) = SafeUint256.add(position.asset_in_quantity, asset_quantity)
        
        StrategyLimitOrderStorage.update_position(
            id = position_id,
            position = LimitOrderPositionStruct(
                owner_address = position.owner_address,
                limit_asset_price = position.limit_asset_price,
                asset_in_address = position.asset_in_address,
                asset_in_quantity = asset_in_quantity, # Update asset_in_quantity
                asset_out_address = position.asset_out_address,
                asset_out_quantity = position.asset_out_quantity,
                is_partial = position.is_partial
            )
        )

        # Fetch WTB DEX address
        let (local wtb_dex_address) = StrategyLimitOrderStorage.read_wtb_dex_address()

        let (local caller_address) = get_caller_address()

        # Transfer asset_in from caller to WTB dex
        WtbDexInterface.update_strategy_increase_balance(
            contract_address = wtb_dex_address,
            sender_address = caller_address,
            asset_address = position.asset_in_address,
            asset_quantity = asset_quantity
        )

        return ()
    end

    @external
    func update_position_decrease_asset_in{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        asset_quantity: Uint256,
    ) -> ():

        alloc_locals

        let (local position) = StrategyLimitOrderStorage.read_position(position_id)

        # Decrease balance of caller position
        let (local asset_in_quantity) = SafeUint256.sub_le(position.asset_in_quantity, asset_quantity)
        
        StrategyLimitOrderStorage.update_position(
            id = position_id,
            position = LimitOrderPositionStruct(
                owner_address = position.owner_address,
                limit_asset_price = position.limit_asset_price,
                asset_in_address = position.asset_in_address,
                asset_in_quantity = asset_in_quantity, # Update asset_in_quantity
                asset_out_address = position.asset_out_address,
                asset_out_quantity = position.asset_out_quantity,
                is_partial = position.is_partial
            )
        )

        # Fetch WTB DEX address
        let (local wtb_dex_address) = StrategyLimitOrderStorage.read_wtb_dex_address()

        let (local caller_address) = get_caller_address()

        # Transfer asset_in from WTB dex to caller
        WtbDexInterface.update_strategy_decrease_balance(
            contract_address = wtb_dex_address,
            recipient_address = caller_address,
            asset_address = position.asset_in_address,
            asset_quantity = asset_quantity
        )

        return ()
    end

    @external
    func update_position_decrease_asset_out{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        asset_quantity: Uint256,
    ) -> ():

        alloc_locals

        let (local position) = StrategyLimitOrderStorage.read_position(position_id)

        # Decrease balance of caller position
        let (asset_out_quantity) = SafeUint256.sub_le(position.asset_out_quantity, asset_quantity)
        
        StrategyLimitOrderStorage.update_position(
            id = position_id,
            position = LimitOrderPositionStruct(
                owner_address = position.owner_address,
                limit_asset_price = position.limit_asset_price,
                asset_in_address = position.asset_in_address,
                asset_in_quantity = position.asset_in_quantity,
                asset_out_address = position.asset_out_address,
                asset_out_quantity = asset_out_quantity, # Update asset_out_quantity
                is_partial = position.is_partial
            )
        )

        # Fetch WTB DEX address
        let (local wtb_dex_address) = StrategyLimitOrderStorage.read_wtb_dex_address()

        let (local caller_address) = get_caller_address()

        # Transfer asset_out from WTB dex to caller
        WtbDexInterface.update_strategy_decrease_balance(
            contract_address = wtb_dex_address,
            recipient_address = caller_address,
            asset_address = position.asset_out_address,
            asset_quantity = asset_quantity
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
                limit_asset_price = position.limit_asset_price,
                asset_in_address = position.asset_in_address,
                asset_in_quantity = position.asset_in_quantity,
                asset_out_address = position.asset_out_address,
                asset_out_quantity = position.asset_out_quantity,
                is_partial = is_partial # Update is_partial
            )
        )
        return ()
    end

end