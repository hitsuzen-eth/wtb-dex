%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from src.storage.strategy_limit_order import StrategyLimitOrderStorage

# One Limit order strategy is for testing purpose, in prod it's probably stupid
# Merkle tree of limit order + ipfs may be feasible
namespace StrategyLimitOrderInteraction:

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
    func read_position{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
    ) -> (position: StrategyLimitOrderStorage):
        return ()
    end

    @external
    func create_position{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        owner_address: felt,
        oracle_address: felt,
        limit_asset_price: Uint256,
        asset_in_address: felt,
        asset_in_quantity: Uint256,
        asset_out_address: felt,
        is_partial: felt
    ) -> (
        id: felt
    ):
        return ()
    end

    @external
    func update_position_owner_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        owner_address: felt,
    ) -> ():
        return ()
    end

    @external
    func update_position_oracle_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        oracle_address: felt,
    ) -> ():
        return ()
    end

    @external
    func update_position_limit_asset_price{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        limit_asset_price: Uint256,
    ) -> ():
        return ()
    end

    @external
    func update_position_increase_asset_in{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        asset_quantity: Uint256,
    ) -> ():
        return ()
    end

    @external
    func update_position_decrease_asset_in{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        asset_quantity: Uint256,
    ) -> ():
        return ()
    end

    @external
    func update_position_increase_asset_out{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        asset_quantity: Uint256,
    ) -> ():
        return ()
    end

    @external
    func update_position_decrease_asset_out{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        asset_quantity: Uint256,
    ) -> ():
        return ()
    end

    @external
    func update_position_is_partial{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position_id: felt,
        is_partial: felt,
    ) -> ():
        return ()
    end

end