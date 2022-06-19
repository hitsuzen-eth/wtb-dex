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
        
        context.strategy_limit_order_address = deploy_contract(
            "./src/interaction/strategy_limit_order.cairo",
            [context.wtb_dex_address]
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
        sender_address = caller_address,
        asset_address = token_a_address,
        asset_quantity = quantity
    )

    let (quantity_updated: Uint256) = WtbDexInterface.read_strategy_asset_balance(
        contract_address = wtb_dex_address,
        strategy_address = caller_address,
        asset_address = token_a_address
    )
    assert quantity = quantity_updated

    let (balance) = IERC20.balanceOf(
        contract_address = token_a_address,
        account = wtb_dex_address,
    )
    
    assert balance = quantity
    
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
        sender_address = caller_address,
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

    let (local balance_2) = IERC20.balanceOf(
        contract_address = token_a_address,
        account = wtb_dex_address,
    )
    
    assert balance_2 = quantity_2
    
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
        sender_address = caller_address,
        asset_address = token_a_address,
        asset_quantity = quantity
    )

    let (quantity_updated: Uint256) = WtbDexInterface.read_strategy_asset_balance(
        contract_address = wtb_dex_address,
        strategy_address = caller_address,
        asset_address = token_a_address
    )
    assert quantity = quantity_updated

    let (balance) = IERC20.balanceOf(
        contract_address = token_a_address,
        account = wtb_dex_address,
    )
    
    assert balance = quantity
    
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
        sender_address = (caller_address + 1 ),
        asset_address = token_a_address,
        asset_quantity = quantity_2
    )

    let (quantity_updated: Uint256) = WtbDexInterface.read_strategy_asset_balance(
        contract_address = wtb_dex_address,
        strategy_address = (caller_address + 1),
        asset_address = token_a_address
    )
    assert quantity_2 = quantity_updated

    let (local quantity_2) = SafeUint256.add(quantity_2, quantity)

    let (balance_2) = IERC20.balanceOf(
        contract_address = token_a_address,
        account = wtb_dex_address,
    )
    
    assert balance_2 = quantity_2
    
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
        sender_address = caller_address,
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

    let (balance) = IERC20.balanceOf(
        contract_address = token_a_address,
        account = wtb_dex_address,
    )
    
    assert balance = quantity
    
    return ()
end

@external
func test_update_strategy_decrease_balance_success{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
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
    
    test_update_strategy_increase_balance_success()

    local quantity: Uint256 = Uint256(
        low = 10,
        high = 0
    )

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.wtb_dex_address) %}
    WtbDexInterface.update_strategy_decrease_balance(
        contract_address = wtb_dex_address,
        recipient_address = caller_address,
        asset_address = token_a_address,
        asset_quantity = quantity
    )

    let (quantity_updated: Uint256) = WtbDexInterface.read_strategy_asset_balance(
        contract_address = wtb_dex_address,
        strategy_address = caller_address,
        asset_address = token_a_address
    )
    local quantity: Uint256 = Uint256(
        low = 4,
        high = 0
    )
    assert quantity = quantity_updated
    
    %{ stop_prank_callable() %}

    let (balance) = IERC20.balanceOf(
        contract_address = token_a_address,
        account = wtb_dex_address,
    )
    
    assert balance = quantity
    
    ##################

    local quantity_2: Uint256 = Uint256(
        low = 4,
        high = 0
    )

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.wtb_dex_address) %}
    WtbDexInterface.update_strategy_decrease_balance(
        contract_address = wtb_dex_address,
        recipient_address = caller_address,
        asset_address = token_a_address,
        asset_quantity = quantity_2
    )

    let (quantity_updated: Uint256) = WtbDexInterface.read_strategy_asset_balance(
        contract_address = wtb_dex_address,
        strategy_address = caller_address,
        asset_address = token_a_address
    )
    local quantity_2: Uint256 = Uint256(
        low = 0,
        high = 0
    )
    assert quantity_2 = quantity_updated
    
    %{ stop_prank_callable() %}

    let (balance_2) = IERC20.balanceOf(
        contract_address = token_a_address,
        account = wtb_dex_address,
    )
    
    assert balance_2 = quantity_2

    return ()
end

@external
func test_update_strategy_decrease_balance_too_much{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
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
    
    test_update_strategy_increase_balance_different_strategy()

    local quantity: Uint256 = Uint256(
        low = 11,
        high = 0
    )

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.wtb_dex_address) %}
    %{ expect_revert() %}
    WtbDexInterface.update_strategy_decrease_balance(
        contract_address = wtb_dex_address,
        recipient_address = caller_address,
        asset_address = token_a_address,
        asset_quantity = quantity
    )
    
    %{ stop_prank_callable() %}
    
    return ()
end

@external
func test_update_strategy_decrease_balance_empty{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
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
        low = 42,
        high = 0
    )

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.wtb_dex_address) %}
    %{ expect_revert() %}
    WtbDexInterface.update_strategy_decrease_balance(
        contract_address = wtb_dex_address,
        recipient_address = caller_address,
        asset_address = token_a_address,
        asset_quantity = quantity
    )
    
    %{ stop_prank_callable() %}
    
    return ()
end

@external
func test_update_strategy_decrease_balance_remove_zero{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
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
    
    test_update_strategy_increase_balance_success()

    local quantity: Uint256 = Uint256(
        low = 0,
        high = 0
    )

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.wtb_dex_address) %}
    WtbDexInterface.update_strategy_decrease_balance(
        contract_address = wtb_dex_address,
        recipient_address = caller_address,
        asset_address = token_a_address,
        asset_quantity = quantity
    )

    let (quantity_updated: Uint256) = WtbDexInterface.read_strategy_asset_balance(
        contract_address = wtb_dex_address,
        strategy_address = caller_address,
        asset_address = token_a_address
    )
    local quantity: Uint256 = Uint256(
        low = 14,
        high = 0
    )
    assert quantity = quantity_updated
    
    %{ stop_prank_callable() %}

    let (balance) = IERC20.balanceOf(
        contract_address = token_a_address,
        account = wtb_dex_address,
    )
    
    assert balance = quantity

    return ()
end

@external
func create_limit_order_position{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
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
    
    let maker_wts_asset_quantity: Uint256 = Uint256(
        low = 100,
        high = 0
    )
    
    let maker_wtb_asset_min_quantity: Uint256 = Uint256(
        low = 4400,
        high = 0
    )
    
    let maker_wtb_asset_quantity: Uint256 = Uint256(
        low = 0,
        high = 0
    )
    
    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_a_address) %}
    IERC20.approve(
        contract_address = token_a_address,
        spender = wtb_dex_address,
        amount = maker_wts_asset_quantity,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.strategy_limit_order_address) %}
    let (position_id) = StrategyLimitOrderInterface.create_position(
        contract_address = strategy_limit_order_address,
        owner_address = caller_address,
        maker_wts_asset_address = token_a_address,
        maker_wts_asset_quantity = maker_wts_asset_quantity,
        maker_wtb_asset_address = token_b_address,
        maker_wtb_asset_min_quantity = maker_wtb_asset_min_quantity,
        is_partial = 1
    )
    %{ stop_prank_callable() %}

    return ()
end

@external
func create_limit_order_position_not_partial{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
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
    
    let maker_wts_asset_quantity: Uint256 = Uint256(
        low = 100,
        high = 0
    )
    
    let maker_wtb_asset_min_quantity: Uint256 = Uint256(
        low = 4400,
        high = 0
    )
    
    let maker_wtb_asset_quantity: Uint256 = Uint256(
        low = 0,
        high = 0
    )
    
    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_a_address) %}
    IERC20.approve(
        contract_address = token_a_address,
        spender = wtb_dex_address,
        amount = maker_wts_asset_quantity,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.strategy_limit_order_address) %}
    let (position_id) = StrategyLimitOrderInterface.create_position(
        contract_address = strategy_limit_order_address,
        owner_address = caller_address,
        maker_wts_asset_address = token_a_address,
        maker_wts_asset_quantity = maker_wts_asset_quantity,
        maker_wtb_asset_address = token_b_address,
        maker_wtb_asset_min_quantity = maker_wtb_asset_min_quantity,
        is_partial = 0
    )
    %{ stop_prank_callable() %}

    return ()
end

@external
func test_create_swap_success{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local caller_address
    local wtb_dex_address
    local token_a_address
    local token_b_address
    local strategy_limit_order_address
    %{
        ids.caller_address = context.caller_address
        ids.wtb_dex_address = context.wtb_dex_address
        ids.token_a_address = context.token_a_address
        ids.token_b_address = context.token_b_address
        ids.strategy_limit_order_address = context.strategy_limit_order_address
    %}
    
    create_limit_order_position()

    let taker_wts_asset_quantity: Uint256 = Uint256(
        low = 88,
        high = 0
    )

    # Price is 44
    let taker_wtb_asset_min_quantity: Uint256 = Uint256(
        low = 2,
        high = 0
    )

    let (local old_balance_a) = IERC20.balanceOf(
        contract_address = token_a_address,
        account = caller_address,
    )
    let (local old_balance_b) = IERC20.balanceOf(
        contract_address = token_b_address,
        account = wtb_dex_address,
    )
    let (local old_quantity_a: Uint256) = WtbDexInterface.read_strategy_asset_balance(
        contract_address = wtb_dex_address,
        strategy_address = strategy_limit_order_address,
        asset_address = token_a_address
    )
    let (local old_quantity_b: Uint256) = WtbDexInterface.read_strategy_asset_balance(
        contract_address = wtb_dex_address,
        strategy_address = strategy_limit_order_address,
        asset_address = token_b_address
    )

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_b_address) %}
    IERC20.approve(
        contract_address = token_b_address,
        spender = wtb_dex_address,
        amount = taker_wts_asset_quantity,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.wtb_dex_address) %}
    WtbDexInterface.create_swap(
        contract_address = wtb_dex_address,
        strategy_address = strategy_limit_order_address,
        position_id = 0,
        taker_wts_asset_address = token_b_address,
        taker_wts_asset_quantity = taker_wts_asset_quantity,
        taker_wtb_asset_address = token_a_address,
        taker_wtb_asset_min_quantity = taker_wtb_asset_min_quantity,
    )
    %{ stop_prank_callable() %}

    let (local balance_a) = IERC20.balanceOf(
        contract_address = token_a_address,
        account = caller_address,
    )
    let (local balance_b) = IERC20.balanceOf(
        contract_address = token_b_address,
        account = wtb_dex_address,
    )
    let (local quantity_a: Uint256) = WtbDexInterface.read_strategy_asset_balance(
        contract_address = wtb_dex_address,
        strategy_address = strategy_limit_order_address,
        asset_address = token_a_address
    )
    let (local quantity_b: Uint256) = WtbDexInterface.read_strategy_asset_balance(
        contract_address = wtb_dex_address,
        strategy_address = strategy_limit_order_address,
        asset_address = token_b_address
    )

    let (local old_balance_a) = SafeUint256.add(old_balance_a, taker_wtb_asset_min_quantity)
    let (local old_balance_b) = SafeUint256.add(old_balance_b, taker_wts_asset_quantity)
    let (local old_quantity_a) = SafeUint256.sub_le(old_quantity_a, taker_wtb_asset_min_quantity)
    let (local old_quantity_b) = SafeUint256.add(old_quantity_b, taker_wts_asset_quantity)

    assert old_balance_a = balance_a
    assert old_balance_b = balance_b
    assert old_quantity_a = quantity_a
    assert old_quantity_b = quantity_b

    return ()
end

@external
func test_create_swap_wrong_strategy{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local caller_address
    local wtb_dex_address
    local token_a_address
    local token_b_address
    local strategy_limit_order_address
    %{
        ids.caller_address = context.caller_address
        ids.wtb_dex_address = context.wtb_dex_address
        ids.token_a_address = context.token_a_address
        ids.token_b_address = context.token_b_address
        ids.strategy_limit_order_address = context.strategy_limit_order_address
    %}
    
    create_limit_order_position()

    let taker_wts_asset_quantity: Uint256 = Uint256(
        low = 88,
        high = 0
    )

    # Price is 44
    let taker_wtb_asset_min_quantity: Uint256 = Uint256(
        low = 2,
        high = 0
    )

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_b_address) %}
    IERC20.approve(
        contract_address = token_b_address,
        spender = wtb_dex_address,
        amount = taker_wts_asset_quantity,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.wtb_dex_address) %}
    %{ expect_revert() %}
    WtbDexInterface.create_swap(
        contract_address = wtb_dex_address,
        strategy_address = (strategy_limit_order_address + 42),
        position_id = 0,
        taker_wts_asset_address = token_b_address,
        taker_wts_asset_quantity = taker_wts_asset_quantity,
        taker_wtb_asset_address = token_a_address,
        taker_wtb_asset_min_quantity = taker_wtb_asset_min_quantity,
    )
    %{ stop_prank_callable() %}

    return ()
end

@external
func test_create_swap_wrong_position_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local caller_address
    local wtb_dex_address
    local token_a_address
    local token_b_address
    local strategy_limit_order_address
    %{
        ids.caller_address = context.caller_address
        ids.wtb_dex_address = context.wtb_dex_address
        ids.token_a_address = context.token_a_address
        ids.token_b_address = context.token_b_address
        ids.strategy_limit_order_address = context.strategy_limit_order_address
    %}
    
    create_limit_order_position()

    let taker_wts_asset_quantity: Uint256 = Uint256(
        low = 88,
        high = 0
    )

    # Price is 44
    let taker_wtb_asset_min_quantity: Uint256 = Uint256(
        low = 2,
        high = 0
    )

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_b_address) %}
    IERC20.approve(
        contract_address = token_b_address,
        spender = wtb_dex_address,
        amount = taker_wts_asset_quantity,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.wtb_dex_address) %}
    %{ expect_revert() %}
    WtbDexInterface.create_swap(
        contract_address = wtb_dex_address,
        strategy_address = strategy_limit_order_address,
        position_id = 3,
        taker_wts_asset_address = token_b_address,
        taker_wts_asset_quantity = taker_wts_asset_quantity,
        taker_wtb_asset_address = token_a_address,
        taker_wtb_asset_min_quantity = taker_wtb_asset_min_quantity,
    )
    %{ stop_prank_callable() %}

    return ()
end

@external
func test_create_swap_wrong_asset{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local caller_address
    local wtb_dex_address
    local token_a_address
    local token_b_address
    local strategy_limit_order_address
    %{
        ids.caller_address = context.caller_address
        ids.wtb_dex_address = context.wtb_dex_address
        ids.token_a_address = context.token_a_address
        ids.token_b_address = context.token_b_address
        ids.strategy_limit_order_address = context.strategy_limit_order_address
    %}
    
    create_limit_order_position()

    let taker_wts_asset_quantity: Uint256 = Uint256(
        low = 88,
        high = 0
    )

    # Price is 44
    let taker_wtb_asset_min_quantity: Uint256 = Uint256(
        low = 2,
        high = 0
    )

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_b_address) %}
    IERC20.approve(
        contract_address = token_a_address,
        spender = wtb_dex_address,
        amount = taker_wts_asset_quantity,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.wtb_dex_address) %}
    %{ expect_revert() %}
    WtbDexInterface.create_swap(
        contract_address = wtb_dex_address,
        strategy_address = strategy_limit_order_address,
        position_id = 0,
        taker_wts_asset_address = token_a_address,
        taker_wts_asset_quantity = taker_wts_asset_quantity,
        taker_wtb_asset_address = token_a_address,
        taker_wtb_asset_min_quantity = taker_wtb_asset_min_quantity,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_b_address) %}
    IERC20.approve(
        contract_address = token_b_address,
        spender = wtb_dex_address,
        amount = taker_wts_asset_quantity,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.wtb_dex_address) %}
    %{ expect_revert() %}
    WtbDexInterface.create_swap(
        contract_address = wtb_dex_address,
        strategy_address = strategy_limit_order_address,
        position_id = 0,
        taker_wts_asset_address = token_b_address,
        taker_wts_asset_quantity = taker_wts_asset_quantity,
        taker_wtb_asset_address = token_b_address,
        taker_wtb_asset_min_quantity = taker_wtb_asset_min_quantity,
    )
    %{ stop_prank_callable() %}

    return ()
end

@external
func test_create_swap_too_much_wts{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local caller_address
    local wtb_dex_address
    local token_a_address
    local token_b_address
    local strategy_limit_order_address
    %{
        ids.caller_address = context.caller_address
        ids.wtb_dex_address = context.wtb_dex_address
        ids.token_a_address = context.token_a_address
        ids.token_b_address = context.token_b_address
        ids.strategy_limit_order_address = context.strategy_limit_order_address
    %}
    
    create_limit_order_position()

    let taker_wts_asset_quantity: Uint256 = Uint256(
        low = 4401,
        high = 0
    )

    # Price is 44
    let taker_wtb_asset_min_quantity: Uint256 = Uint256(
        low = 100,
        high = 0
    )

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_b_address) %}
    IERC20.approve(
        contract_address = token_b_address,
        spender = wtb_dex_address,
        amount = taker_wts_asset_quantity,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.wtb_dex_address) %}
    %{ expect_revert() %}
    WtbDexInterface.create_swap(
        contract_address = wtb_dex_address,
        strategy_address = strategy_limit_order_address,
        position_id = 0,
        taker_wts_asset_address = token_b_address,
        taker_wts_asset_quantity = taker_wts_asset_quantity,
        taker_wtb_asset_address = token_a_address,
        taker_wtb_asset_min_quantity = taker_wtb_asset_min_quantity,
    )
    %{ stop_prank_callable() %}

    return ()
end

@external
func test_create_swap_bad_price{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local caller_address
    local wtb_dex_address
    local token_a_address
    local token_b_address
    local strategy_limit_order_address
    %{
        ids.caller_address = context.caller_address
        ids.wtb_dex_address = context.wtb_dex_address
        ids.token_a_address = context.token_a_address
        ids.token_b_address = context.token_b_address
        ids.strategy_limit_order_address = context.strategy_limit_order_address
    %}
    
    create_limit_order_position()

    let taker_wts_asset_quantity: Uint256 = Uint256(
        low = 87,
        high = 0
    )

    # Price is 44
    let taker_wtb_asset_min_quantity: Uint256 = Uint256(
        low = 2,
        high = 0
    )

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_b_address) %}
    IERC20.approve(
        contract_address = token_b_address,
        spender = wtb_dex_address,
        amount = taker_wts_asset_quantity,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.wtb_dex_address) %}
    %{ expect_revert() %}
    WtbDexInterface.create_swap(
        contract_address = wtb_dex_address,
        strategy_address = strategy_limit_order_address,
        position_id = 0,
        taker_wts_asset_address = token_b_address,
        taker_wts_asset_quantity = taker_wts_asset_quantity,
        taker_wtb_asset_address = token_a_address,
        taker_wtb_asset_min_quantity = taker_wtb_asset_min_quantity,
    )
    %{ stop_prank_callable() %}

    return ()
end

@external
func test_create_swap_not_fully_filled{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals

    local caller_address
    local wtb_dex_address
    local token_a_address
    local token_b_address
    local strategy_limit_order_address
    %{
        ids.caller_address = context.caller_address
        ids.wtb_dex_address = context.wtb_dex_address
        ids.token_a_address = context.token_a_address
        ids.token_b_address = context.token_b_address
        ids.strategy_limit_order_address = context.strategy_limit_order_address
    %}
    
    create_limit_order_position_not_partial()

    let taker_wts_asset_quantity: Uint256 = Uint256(
        low = 88,
        high = 0
    )

    # Price is 44
    let taker_wtb_asset_min_quantity: Uint256 = Uint256(
        low = 2,
        high = 0
    )

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_b_address) %}
    IERC20.approve(
        contract_address = token_b_address,
        spender = wtb_dex_address,
        amount = taker_wts_asset_quantity,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.wtb_dex_address) %}
    %{ expect_revert() %}
    WtbDexInterface.create_swap(
        contract_address = wtb_dex_address,
        strategy_address = strategy_limit_order_address,
        position_id = 0,
        taker_wts_asset_address = token_b_address,
        taker_wts_asset_quantity = taker_wts_asset_quantity,
        taker_wtb_asset_address = token_a_address,
        taker_wtb_asset_min_quantity = taker_wtb_asset_min_quantity,
    )
    %{ stop_prank_callable() %}

    return ()
end