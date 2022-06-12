%lang starknet

from src.type.oracle import AssetPriceStruct

@contract_interface
namespace OracleInterface:
    func read_asset_price(
        asset_address: felt,
    ) -> (asset_price: AssetPriceStruct):
    end

    func update_asset_price(
        asset_address: felt,
        asset_price: AssetPriceStruct,
    ) -> ():
    end

    func read_owner_address(
    ) -> (owner_address: felt):
    end

    func update_owner_address(
        new_owner_address: felt,
    ) -> ():
    end
end