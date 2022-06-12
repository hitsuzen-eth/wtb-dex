%lang starknet

@contract_interface
namespace StrategyInterface:
    func create_swap(
        position_id: felt,
        asset_in_address: felt,
        asset_in_quantity: felt,
        asset_out_address: felt
    ) -> (quantity: felt):
    end
end