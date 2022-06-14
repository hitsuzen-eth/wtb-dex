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
    
    let (wtb_dex_address_stored: felt) = StrategyLimitOrderInterface.read_wtb_dex_address(
        contract_address = strategy_limit_order_address,
    )
    assert wtb_dex_address_stored = wtb_dex_address
    
    return ()
end
