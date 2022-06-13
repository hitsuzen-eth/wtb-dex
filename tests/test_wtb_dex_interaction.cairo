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

@view
func __setup__():
    let initial_supply: Uint256 = Uint256(
        low = 1000,
        high = 0
    )
    %{
        context.caller_address = 42
        context.wtb_dex_address = deploy_contract("./src/interaction/wtb_dex.cairo").contract_address
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
func test_update_strategy_increase_balance_success{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local caller_address
    local wtb_dex_address
    local token_a_address
    local token_b_address
    %{
        ids.caller_address = context.caller_address
        ids.wtb_dex_address = context.wtb_dex_address
        ids.token_a_address = context.token_a_address
        ids.token_b_address = context.token_b_address
    %}
    
    local quantity: Uint256 = Uint256(
        low = 10,
        high = 0
    )

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_a_address) %}
    IERC20.approve(
        contract_address = token_a_address,
        spender = wtb_dex_address,
        amount = quantity,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.wtb_dex_address) %}
    WtbDexInterface.update_strategy_increase_balance(
        contract_address = wtb_dex_address,
        asset_address = token_a_address,
        asset_quantity = quantity
    )

    let (quantity_updated: Uint256) = WtbDexInterface.read_strategy_asset_balance(
        contract_address = wtb_dex_address,
        strategy_address = caller_address,
        asset_address = token_a_address
    )
    assert quantity = quantity_updated
    
    %{ stop_prank_callable() %}
    
    ##################

    local quantity_2: Uint256 = Uint256(
        low = 4,
        high = 0
    )

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_a_address) %}
    IERC20.approve(
        contract_address = token_a_address,
        spender = wtb_dex_address,
        amount = quantity_2,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.wtb_dex_address) %}
    WtbDexInterface.update_strategy_increase_balance(
        contract_address = wtb_dex_address,
        asset_address = token_a_address,
        asset_quantity = quantity_2
    )

    let (quantity_updated: Uint256) = WtbDexInterface.read_strategy_asset_balance(
        contract_address = wtb_dex_address,
        strategy_address = caller_address,
        asset_address = token_a_address
    )
    let (local quantity_2) = SafeUint256.add(quantity_2, quantity)
    assert quantity_2 = quantity_updated
    
    %{ stop_prank_callable() %}
    return ()
end

@external
func test_update_strategy_increase_balance_different_strategy{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local caller_address
    local wtb_dex_address
    local token_a_address
    local token_b_address
    %{
        ids.caller_address = context.caller_address
        ids.wtb_dex_address = context.wtb_dex_address
        ids.token_a_address = context.token_a_address
        ids.token_b_address = context.token_b_address
    %}
    
    local quantity: Uint256 = Uint256(
        low = 10,
        high = 0
    )

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_a_address) %}
    IERC20.approve(
        contract_address = token_a_address,
        spender = wtb_dex_address,
        amount = quantity,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.wtb_dex_address) %}
    WtbDexInterface.update_strategy_increase_balance(
        contract_address = wtb_dex_address,
        asset_address = token_a_address,
        asset_quantity = quantity
    )

    let (quantity_updated: Uint256) = WtbDexInterface.read_strategy_asset_balance(
        contract_address = wtb_dex_address,
        strategy_address = caller_address,
        asset_address = token_a_address
    )
    assert quantity = quantity_updated
    
    %{ stop_prank_callable() %}
    
    ##################

    local quantity_2: Uint256 = Uint256(
        low = 4,
        high = 0
    )

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_a_address) %}
    IERC20.transfer(
        contract_address = token_a_address,
        recipient = caller_address + 1,
        amount = quantity_2,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address + 1, target_contract_address=context.token_a_address) %}
    IERC20.approve(
        contract_address = token_a_address,
        spender = wtb_dex_address,
        amount = quantity_2,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address + 1, target_contract_address=context.wtb_dex_address) %}
    WtbDexInterface.update_strategy_increase_balance(
        contract_address = wtb_dex_address,
        asset_address = token_a_address,
        asset_quantity = quantity_2
    )

    let (quantity_updated: Uint256) = WtbDexInterface.read_strategy_asset_balance(
        contract_address = wtb_dex_address,
        strategy_address = (caller_address + 1),
        asset_address = token_a_address
    )
    assert quantity_2 = quantity_updated
    
    %{ stop_prank_callable() %}
    return ()
end

@external
func test_update_strategy_increase_balance_add_zero{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local caller_address
    local wtb_dex_address
    local token_a_address
    local token_b_address
    %{
        ids.caller_address = context.caller_address
        ids.wtb_dex_address = context.wtb_dex_address
        ids.token_a_address = context.token_a_address
        ids.token_b_address = context.token_b_address
    %}

    local quantity: Uint256 = Uint256(
        low = 0,
        high = 0
    )

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.wtb_dex_address) %}
    WtbDexInterface.update_strategy_increase_balance(
        contract_address = wtb_dex_address,
        asset_address = token_a_address,
        asset_quantity = quantity
    )

    let (quantity_updated: Uint256) = WtbDexInterface.read_strategy_asset_balance(
        contract_address = wtb_dex_address,
        strategy_address = caller_address,
        asset_address = token_a_address
    )
    assert quantity = quantity_updated
    
    %{ stop_prank_callable() %}
    
    return ()
end

