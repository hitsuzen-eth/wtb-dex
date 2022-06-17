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

    let (position) = StrategyLimitOrderInterface.read_position(
        contract_address = strategy_limit_order_address,
        position_id = position_id
    )

    assert position_id = 0
    assert position.owner_address = caller_address
    assert position.maker_wts_asset_address = token_a_address
    assert position.maker_wts_asset_quantity = maker_wts_asset_quantity
    assert position.maker_wtb_asset_address = token_b_address
    assert position.maker_wtb_asset_quantity = maker_wtb_asset_quantity
    assert position.maker_wtb_asset_min_quantity = maker_wtb_asset_min_quantity
    assert position.is_partial = 1

    let (balance) = IERC20.balanceOf(
        contract_address = token_a_address,
        account = wtb_dex_address,
    )
    
    assert balance = maker_wts_asset_quantity

    ########
    
    let maker_wts_asset_quantity_2: Uint256 = Uint256(
        low = 8,
        high = 0
    )
    
    let maker_wtb_asset_min_quantity_2: Uint256 = Uint256(
        low = 352,
        high = 0
    )
    
    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_a_address) %}
    IERC20.approve(
        contract_address = token_a_address,
        spender = wtb_dex_address,
        amount = maker_wts_asset_quantity_2,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.strategy_limit_order_address) %}
    let (position_id_2) = StrategyLimitOrderInterface.create_position(
        contract_address = strategy_limit_order_address,
        owner_address = caller_address,
        maker_wts_asset_address = token_a_address,
        maker_wts_asset_quantity = maker_wts_asset_quantity_2,
        maker_wtb_asset_address = token_b_address,
        maker_wtb_asset_min_quantity = maker_wtb_asset_min_quantity_2,
        is_partial = 1
    )
    %{ stop_prank_callable() %}

    let (position_2) = StrategyLimitOrderInterface.read_position(
        contract_address = strategy_limit_order_address,
        position_id = position_id_2
    )

    assert position_id_2 = 1
    assert position.owner_address = caller_address
    assert position_2.maker_wts_asset_address = token_a_address
    assert position_2.maker_wts_asset_quantity = maker_wts_asset_quantity_2
    assert position_2.maker_wtb_asset_address = token_b_address
    assert position_2.maker_wtb_asset_quantity = maker_wtb_asset_quantity
    assert position_2.maker_wtb_asset_min_quantity = maker_wtb_asset_min_quantity_2
    assert position_2.is_partial = 1

    let (balance_2) = IERC20.balanceOf(
        contract_address = token_a_address,
        account = wtb_dex_address,
    )
    
    let (local sum_maker_wts_asset) = SafeUint256.add(maker_wts_asset_quantity, maker_wts_asset_quantity_2)
    assert balance_2 = sum_maker_wts_asset
    
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
    
    let maker_wts_asset_quantity: Uint256 = Uint256(
        low = 100,
        high = 0
    )
    
    let maker_wtb_asset_quantity: Uint256 = Uint256(
        low = 0,
        high = 0
    )
    
    let maker_wtb_asset_min_quantity: Uint256 = Uint256(
        low = 9432,
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
        owner_address = (caller_address + 1),
        maker_wts_asset_address = token_a_address,
        maker_wts_asset_quantity = maker_wts_asset_quantity,
        maker_wtb_asset_address = token_b_address,
        maker_wtb_asset_min_quantity = maker_wtb_asset_min_quantity,
        is_partial = 1
    )
    %{ stop_prank_callable() %}

    let (position) = StrategyLimitOrderInterface.read_position(
        contract_address = strategy_limit_order_address,
        position_id = position_id
    )

    assert position.owner_address = (caller_address + 1)

    let (balance) = IERC20.balanceOf(
        contract_address = token_a_address,
        account = wtb_dex_address,
    )
    
    assert balance = maker_wts_asset_quantity

    return ()
end

@external
func test_create_position_no_wts_asset{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
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
        low = 0,
        high = 0
    )
    
    let maker_wtb_asset_quantity: Uint256 = Uint256(
        low = 0,
        high = 0
    )
    
    let maker_wtb_asset_min_quantity: Uint256 = Uint256(
        low = 9942,
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

    let (position) = StrategyLimitOrderInterface.read_position(
        contract_address = strategy_limit_order_address,
        position_id = position_id
    )

    assert position.maker_wts_asset_quantity = maker_wts_asset_quantity

    let (balance) = IERC20.balanceOf(
        contract_address = token_a_address,
        account = wtb_dex_address,
    )
    
    assert balance = maker_wts_asset_quantity

    return ()
end

@external
func test_update_position_owner_address_success{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
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

    test_create_position_success()

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.strategy_limit_order_address) %}
    StrategyLimitOrderInterface.update_position_owner_address(
        contract_address = strategy_limit_order_address,
        position_id = 0,
        owner_address = (caller_address + 5),
    )
    %{ stop_prank_callable() %}

    let (position) = StrategyLimitOrderInterface.read_position(
        contract_address = strategy_limit_order_address,
        position_id = 0
    )

    assert position.owner_address = (caller_address + 5)
    
    return ()
end

@external
func test_update_position_owner_address_not_owner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
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

    test_create_position_success()

    %{ stop_prank_callable = start_prank((context.caller_address + 1), target_contract_address=context.strategy_limit_order_address) %}
    %{ expect_revert() %}
    StrategyLimitOrderInterface.update_position_owner_address(
        contract_address = strategy_limit_order_address,
        position_id = 0,
        owner_address = (caller_address + 5),
    )
    %{ stop_prank_callable() %}
    
    return ()
end

@external
func test_update_position_increase_wts_asset_success{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
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

    test_create_position_success()

    let (local old_balance) = IERC20.balanceOf(
        contract_address = token_a_address,
        account = wtb_dex_address,
    )

    let (local position) = StrategyLimitOrderInterface.read_position(
        contract_address = strategy_limit_order_address,
        position_id = 0
    )

    local old_maker_wts_asset_quantity: Uint256 = position.maker_wts_asset_quantity

    let deposit_asset_quantity: Uint256 = Uint256(
        low = 42,
        high = 0
    )
    # Price is 44
    let (local new_maker_wtb_asset_min_quantity) = SafeUint256.mul(
        deposit_asset_quantity,
        Uint256(
            low = 44,
            high = 0
        )
    )
    let (local maker_wtb_asset_min_quantity) = SafeUint256.add(new_maker_wtb_asset_min_quantity, position.maker_wtb_asset_min_quantity)

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_a_address) %}
    IERC20.approve(
        contract_address = token_a_address,
        spender = wtb_dex_address,
        amount = deposit_asset_quantity,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.strategy_limit_order_address) %}
    StrategyLimitOrderInterface.update_position_increase_wts_asset(
        contract_address = strategy_limit_order_address,
        position_id = 0,
        deposit_asset_quantity = deposit_asset_quantity,
    )
    %{ stop_prank_callable() %}

    let (local position) = StrategyLimitOrderInterface.read_position(
        contract_address = strategy_limit_order_address,
        position_id = 0
    )

    let (local maker_wts_asset_quantity) = SafeUint256.add(old_maker_wts_asset_quantity, deposit_asset_quantity)
    assert position.maker_wts_asset_quantity = maker_wts_asset_quantity
    assert position.maker_wtb_asset_min_quantity = maker_wtb_asset_min_quantity

    let (balance) = IERC20.balanceOf(
        contract_address = token_a_address,
        account = wtb_dex_address,
    )
    
    let (local sum_balance) = SafeUint256.add(old_balance, deposit_asset_quantity)
    assert balance = sum_balance
    
    return ()
end

@external
func test_update_position_increase_wts_asset_not_owner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
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

    test_create_position_success()

    let (local old_balance) = IERC20.balanceOf(
        contract_address = token_a_address,
        account = wtb_dex_address,
    )

    let (local position) = StrategyLimitOrderInterface.read_position(
        contract_address = strategy_limit_order_address,
        position_id = 0
    )

    local old_maker_wts_asset_quantity: Uint256 = position.maker_wts_asset_quantity

    let deposit_asset_quantity: Uint256 = Uint256(
        low = 18,
        high = 0
    )
    # Price is 44
    let (local new_maker_wtb_asset_min_quantity) = SafeUint256.mul(
        deposit_asset_quantity,
        Uint256(
            low = 44,
            high = 0
        )
    )
    let (local maker_wtb_asset_min_quantity) = SafeUint256.add(new_maker_wtb_asset_min_quantity, position.maker_wtb_asset_min_quantity)

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.token_a_address) %}
    IERC20.transfer(
        contract_address = token_a_address,
        recipient = caller_address + 8,
        amount = deposit_asset_quantity,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address + 8, target_contract_address=context.token_a_address) %}
    IERC20.approve(
        contract_address = token_a_address,
        spender = wtb_dex_address,
        amount = deposit_asset_quantity,
    )
    %{ stop_prank_callable() %}

    %{ stop_prank_callable = start_prank(context.caller_address + 8, target_contract_address=context.strategy_limit_order_address) %}
    StrategyLimitOrderInterface.update_position_increase_wts_asset(
        contract_address = strategy_limit_order_address,
        position_id = 0,
        deposit_asset_quantity = deposit_asset_quantity,
    )
    %{ stop_prank_callable() %}

    let (local position) = StrategyLimitOrderInterface.read_position(
        contract_address = strategy_limit_order_address,
        position_id = 0
    )

    let (local maker_wts_asset_quantity) = SafeUint256.add(old_maker_wts_asset_quantity, deposit_asset_quantity)
    assert position.maker_wts_asset_quantity = maker_wts_asset_quantity
    assert position.maker_wtb_asset_min_quantity = maker_wtb_asset_min_quantity

    let (balance) = IERC20.balanceOf(
        contract_address = token_a_address,
        account = wtb_dex_address,
    )
    
    let (local sum_balance) = SafeUint256.add(old_balance, deposit_asset_quantity)
    assert balance = sum_balance
    
    return ()
end

@external
func test_update_position_decrease_wts_asset_success{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
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

    test_create_position_success()

    let (local old_balance) = IERC20.balanceOf(
        contract_address = token_a_address,
        account = caller_address,
    )

    let (local position) = StrategyLimitOrderInterface.read_position(
        contract_address = strategy_limit_order_address,
        position_id = 1
    )

    local old_maker_wts_asset_quantity: Uint256 = position.maker_wts_asset_quantity

    let withdraw_asset_quantity: Uint256 = Uint256(
        low = 3,
        high = 0
    )
    # Price is 44
    let (local new_maker_wtb_asset_min_quantity) = SafeUint256.mul(
        withdraw_asset_quantity,
        Uint256(
            low = 44,
            high = 0
        )
    )
    let (local maker_wtb_asset_min_quantity) = SafeUint256.sub_le(position.maker_wtb_asset_min_quantity, new_maker_wtb_asset_min_quantity)

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.strategy_limit_order_address) %}
    StrategyLimitOrderInterface.update_position_decrease_wts_asset(
        contract_address = strategy_limit_order_address,
        position_id = 1,
        withdraw_asset_quantity = withdraw_asset_quantity,
    )
    %{ stop_prank_callable() %}

    let (local position) = StrategyLimitOrderInterface.read_position(
        contract_address = strategy_limit_order_address,
        position_id = 1
    )

    let (local maker_wts_asset_quantity) = SafeUint256.sub_le(old_maker_wts_asset_quantity, withdraw_asset_quantity)
    assert position.maker_wts_asset_quantity = maker_wts_asset_quantity
    assert position.maker_wtb_asset_min_quantity = maker_wtb_asset_min_quantity

    let (balance) = IERC20.balanceOf(
        contract_address = token_a_address,
        account = caller_address,
    )
    
    let (local sum_balance) = SafeUint256.add(old_balance, withdraw_asset_quantity)
    assert balance = sum_balance
    
    return ()
end

@external
func test_update_position_decrease_wts_asset_not_owner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
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

    test_create_position_success()

    let withdraw_asset_quantity: Uint256 = Uint256(
        low = 3,
        high = 0
    )

    %{ stop_prank_callable = start_prank(context.caller_address + 10, target_contract_address=context.strategy_limit_order_address) %}
    %{ expect_revert() %}
    StrategyLimitOrderInterface.update_position_decrease_wts_asset(
        contract_address = strategy_limit_order_address,
        position_id = 0,
        withdraw_asset_quantity = withdraw_asset_quantity,
    )
    %{ stop_prank_callable() %}
    
    return ()
end

@external
func test_update_position_wtb_asset_min_quantity_success{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
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

    test_create_position_success()

    let maker_wtb_asset_min_quantity: Uint256 = Uint256(
        low = 999,
        high = 0
    )

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.strategy_limit_order_address) %}
    StrategyLimitOrderInterface.update_position_wtb_asset_min_quantity(
        contract_address = strategy_limit_order_address,
        position_id = 1,
        maker_wtb_asset_min_quantity = maker_wtb_asset_min_quantity,
    )
    %{ stop_prank_callable() %}

    let (position) = StrategyLimitOrderInterface.read_position(
        contract_address = strategy_limit_order_address,
        position_id = 1
    )

    assert position.maker_wtb_asset_min_quantity = maker_wtb_asset_min_quantity
    
    return ()
end

@external
func test_update_position_wtb_asset_min_quantity_not_owner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
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

    test_create_position_success()

    let maker_wtb_asset_min_quantity: Uint256 = Uint256(
        low = 42,
        high = 0
    )

    %{ stop_prank_callable = start_prank((context.caller_address + 10), target_contract_address=context.strategy_limit_order_address) %}
    %{ expect_revert() %}
    StrategyLimitOrderInterface.update_position_wtb_asset_min_quantity(
        contract_address = strategy_limit_order_address,
        position_id = 1,
        maker_wtb_asset_min_quantity = maker_wtb_asset_min_quantity,
    )
    %{ stop_prank_callable() %}
    
    return ()
end

@external
func test_update_position_is_partial_success{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
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

    test_create_position_success()

    %{ stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.strategy_limit_order_address) %}
    StrategyLimitOrderInterface.update_position_is_partial(
        contract_address = strategy_limit_order_address,
        position_id = 0,
        is_partial = 0,
    )
    %{ stop_prank_callable() %}

    let (position) = StrategyLimitOrderInterface.read_position(
        contract_address = strategy_limit_order_address,
        position_id = 0
    )

    assert position.is_partial = 0
    
    return ()
end

@external
func test_update_position_is_partial_not_owner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
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

    test_create_position_success()

    %{ stop_prank_callable = start_prank((context.caller_address + 1), target_contract_address=context.strategy_limit_order_address) %}
    %{ expect_revert() %}
    StrategyLimitOrderInterface.update_position_is_partial(
        contract_address = strategy_limit_order_address,
        position_id = 0,
        is_partial = 1,
    )
    %{ stop_prank_callable() %}
    
    return ()
end
