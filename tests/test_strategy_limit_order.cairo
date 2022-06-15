%lang starknet
# TODO Reentrancy attack test
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_contract_address
from starkware.cairo.common.uint256 import (
    Uint256,
    split_64
)

from openzeppelin.token.erc20.interfaces.IERC20 import IERC20
from openzeppelin.security.safemath import SafeUint256

from src.interface.wtb_dex import WtbDexInterface
from src.interface.strategy_limit_order import StrategyLimitOrderInterface

@view
func __setup__():
    let initial_supply: Uint256 = Uint256(
        low = 1000,
        high = 0
    )
    %{
        context.caller_address = 42
        context.wtb_dex_address = deploy_contract("./src/interaction/wtb_dex.cairo").contract_address
        
        context.strategy_limit_order_address = deploy_contract(
            "./src/interaction/strategy_limit_order.cairo",
            [context.wtb_dex_address]
        ).contract_address

        context.token_a_address = deploy_contract(
            "./lib/cairo_contracts/openzeppelin/token/erc20/ERC20.cairo",
            [
                1111,
                11,
                18,
                1000,
                0,
                context.caller_address
            ]
        ).contract_address
        context.token_b_address = deploy_contract(
            "./lib/cairo_contracts/openzeppelin/token/erc20/ERC20.cairo",
            [
                2222,
                22,
                18,
                1000,
                0,
                context.caller_address
            ]
        ).contract_address
    %}
    return ()
end

@external
func test_constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local caller_address
    local wtb_dex_address
    local strategy_limit_order_address
    local token_a_address
    local token_b_address
    %{
        ids.caller_address = context.caller_address
        ids.wtb_dex_address = context.wtb_dex_address
        ids.strategy_limit_order_address = context.strategy_limit_order_address
        ids.token_a_address = context.token_a_address
        ids.token_b_address = context.token_b_address
    %}
    
    let (wtb_dex_address_stored) = StrategyLimitOrderInterface.read_wtb_dex_address(
        contract_address = strategy_limit_order_address,
    )
    assert wtb_dex_address_stored = wtb_dex_address
    
    return ()
end

@external
func test_create_position_success{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local caller_address
    local wtb_dex_address
    local strategy_limit_order_address
    local token_a_address
    local token_b_address
    %{
        ids.caller_address = context.caller_address
        ids.wtb_dex_address = context.wtb_dex_address
        ids.strategy_limit_order_address = context.strategy_limit_order_address
        ids.token_a_address = context.token_a_address
        ids.token_b_address = context.token_b_address
    %}
    
    let limit_asset_price: Uint256 = Uint256(
        low = 10,
        high = 0
    )
    
    let asset_in_quantity: Uint256 = Uint256(
        low = 100,
        high = 0
    )
    
    let asset_out_quantity: Uint256 = Uint256(
        low = 0,
        high = 0
    )
    
    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_a_address) %}
    IERC20.approve(
        contract_address = token_a_address,
        spender = wtb_dex_address,
        amount = asset_in_quantity,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.strategy_limit_order_address) %}
    let (position_id) = StrategyLimitOrderInterface.create_position(
        contract_address = strategy_limit_order_address,
        owner_address = caller_address,
        limit_asset_price = limit_asset_price,
        asset_in_address = token_a_address,
        asset_in_quantity = asset_in_quantity,
        asset_out_address = token_b_address,
        is_partial = 1
    )
    %{ stop_prank_callable() %}

    let (position) = StrategyLimitOrderInterface.read_position(
        contract_address = strategy_limit_order_address,
        position_id = position_id
    )

    assert position_id = 0
    assert position.owner_address = caller_address
    assert position.limit_asset_price = limit_asset_price
    assert position.asset_in_address = token_a_address
    assert position.asset_in_quantity = asset_in_quantity
    assert position.asset_out_address = token_b_address
    assert position.asset_out_quantity = asset_out_quantity
    assert position.is_partial = 1

    ########
    
    let limit_asset_price_2: Uint256 = Uint256(
        low = 4,
        high = 0
    )
    
    let asset_in_quantity_2: Uint256 = Uint256(
        low = 8,
        high = 0
    )
    
    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_a_address) %}
    IERC20.approve(
        contract_address = token_a_address,
        spender = wtb_dex_address,
        amount = asset_in_quantity_2,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.strategy_limit_order_address) %}
    let (position_id_2) = StrategyLimitOrderInterface.create_position(
        contract_address = strategy_limit_order_address,
        owner_address = caller_address,
        limit_asset_price = limit_asset_price_2,
        asset_in_address = token_a_address,
        asset_in_quantity = asset_in_quantity_2,
        asset_out_address = token_b_address,
        is_partial = 1
    )
    %{ stop_prank_callable() %}

    let (position_2) = StrategyLimitOrderInterface.read_position(
        contract_address = strategy_limit_order_address,
        position_id = position_id_2
    )

    assert position_id_2 = 1
    assert position_2.owner_address = caller_address
    assert position_2.limit_asset_price = limit_asset_price_2
    assert position_2.asset_in_address = token_a_address
    assert position_2.asset_in_quantity = asset_in_quantity_2
    assert position_2.asset_out_address = token_b_address
    assert position_2.asset_out_quantity = asset_out_quantity
    assert position_2.is_partial = 1
    
    return ()
end

@external
func test_create_position_different_owner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local caller_address
    local wtb_dex_address
    local strategy_limit_order_address
    local token_a_address
    local token_b_address
    %{
        ids.caller_address = context.caller_address
        ids.wtb_dex_address = context.wtb_dex_address
        ids.strategy_limit_order_address = context.strategy_limit_order_address
        ids.token_a_address = context.token_a_address
        ids.token_b_address = context.token_b_address
    %}
    
    let limit_asset_price: Uint256 = Uint256(
        low = 10,
        high = 0
    )
    
    let asset_in_quantity: Uint256 = Uint256(
        low = 100,
        high = 0
    )
    
    let asset_out_quantity: Uint256 = Uint256(
        low = 0,
        high = 0
    )
    
    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_a_address) %}
    IERC20.approve(
        contract_address = token_a_address,
        spender = wtb_dex_address,
        amount = asset_in_quantity,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.strategy_limit_order_address) %}
    let (position_id) = StrategyLimitOrderInterface.create_position(
        contract_address = strategy_limit_order_address,
        owner_address = (caller_address + 1),
        limit_asset_price = limit_asset_price,
        asset_in_address = token_a_address,
        asset_in_quantity = asset_in_quantity,
        asset_out_address = token_b_address,
        is_partial = 1
    )
    %{ stop_prank_callable() %}

    let (position) = StrategyLimitOrderInterface.read_position(
        contract_address = strategy_limit_order_address,
        position_id = position_id
    )

    assert position.owner_address = (caller_address + 1)

    return ()
end

@external
func test_create_position_no_asset_in{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local caller_address
    local wtb_dex_address
    local strategy_limit_order_address
    local token_a_address
    local token_b_address
    %{
        ids.caller_address = context.caller_address
        ids.wtb_dex_address = context.wtb_dex_address
        ids.strategy_limit_order_address = context.strategy_limit_order_address
        ids.token_a_address = context.token_a_address
        ids.token_b_address = context.token_b_address
    %}
    
    let limit_asset_price: Uint256 = Uint256(
        low = 10,
        high = 0
    )
    
    let asset_in_quantity: Uint256 = Uint256(
        low = 0,
        high = 0
    )
    
    let asset_out_quantity: Uint256 = Uint256(
        low = 0,
        high = 0
    )
    
    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_a_address) %}
    IERC20.approve(
        contract_address = token_a_address,
        spender = wtb_dex_address,
        amount = asset_in_quantity,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.strategy_limit_order_address) %}
    let (position_id) = StrategyLimitOrderInterface.create_position(
        contract_address = strategy_limit_order_address,
        owner_address = caller_address,
        limit_asset_price = limit_asset_price,
        asset_in_address = token_a_address,
        asset_in_quantity = asset_in_quantity,
        asset_out_address = token_b_address,
        is_partial = 1
    )
    %{ stop_prank_callable() %}

    let (position) = StrategyLimitOrderInterface.read_position(
        contract_address = strategy_limit_order_address,
        position_id = position_id
    )

    assert position.asset_in_quantity = asset_in_quantity

    return ()
end
