%lang starknet

from starkware.starknet.common.syscalls import get_contract_address
from src.interface.oracle import OracleInterface
from src.type.oracle import AssetPriceStruct

@view
func __setup__():
    %{
        context.caller_address = 42
        context.oracle_address = deploy_contract("./src/interaction/oracle.cairo", [context.caller_address]).contract_address
    %}
    return ()
end

@external
func test_constructor{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    local caller_address
    local oracle_address
    %{
        ids.caller_address = context.caller_address
        ids.oracle_address = context.oracle_address
        stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.oracle_address)
    %}

    let (owner_address) = OracleInterface.read_owner_address(
        contract_address = oracle_address
    )
    assert owner_address = caller_address
    
    %{ stop_prank_callable() %}
    return ()
end

@external
func test_update_owner_address_success{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    local caller_address
    local oracle_address
    %{
        ids.caller_address = context.caller_address
        ids.oracle_address = context.oracle_address
        stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.oracle_address)
    %}

    local new_owner_address = 42

    OracleInterface.update_owner_address(
        contract_address=oracle_address,
        new_owner_address = new_owner_address
    )

    let (owner_address) = OracleInterface.read_owner_address(
        contract_address = oracle_address
    )
    assert owner_address = new_owner_address
    
    %{ stop_prank_callable() %}
    return ()
end

@external
func test_update_owner_address_not_owner{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    local caller_address
    local oracle_address
    %{
        ids.caller_address = context.caller_address
        ids.oracle_address = context.oracle_address
        stop_prank_callable = start_prank(context.caller_address + 1, target_contract_address=context.oracle_address)
    %}

    %{ expect_revert() %}
    OracleInterface.update_owner_address(
        contract_address=oracle_address,
        new_owner_address = (caller_address + 1)
    )

    %{ stop_prank_callable() %}
    return ()
end

@external
func test_update_asset_price_success{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    local caller_address
    local oracle_address
    %{
        ids.caller_address = context.caller_address
        ids.oracle_address = context.oracle_address
        stop_prank_callable = start_prank(context.caller_address, target_contract_address=context.oracle_address)
    %}

    local asset_address = 42
    local new_asset_price: AssetPriceStruct = AssetPriceStruct(
        price = 100,
        quantization =  100000
    )

    OracleInterface.update_asset_price(
        contract_address = oracle_address,
        asset_address = asset_address,
        asset_price = new_asset_price
    )

    let (asset_price) = OracleInterface.read_asset_price(
        contract_address = oracle_address,
        asset_address = asset_address,
    )
    assert asset_price = new_asset_price

    %{ stop_prank_callable() %}
    return ()
end

@external
func test_update_asset_price_not_owner{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    local caller_address
    local oracle_address
    %{
        ids.caller_address = context.caller_address
        ids.oracle_address = context.oracle_address
        stop_prank_callable = start_prank(context.caller_address + 1, target_contract_address=context.oracle_address)
    %}

    local asset_address = 42
    local new_asset_price: AssetPriceStruct = AssetPriceStruct(
        price = 110,
        quantization =  100000
    )

    %{ expect_revert() %}
    OracleInterface.update_asset_price(
        contract_address = oracle_address,
        asset_address = asset_address,
        asset_price = new_asset_price
    )

    %{ stop_prank_callable() %}
    return ()
end