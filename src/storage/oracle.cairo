%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from src.type.oracle import AssetPriceStruct

@storage_var
func asset_price_storage(
    asset_address: felt
) -> (
    asset_price: AssetPriceStruct
):
end

@storage_var
func owner_storage() -> (
    owner_address: felt
):
end

namespace OracleStorage:

    func read_asset_price_storage{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset_address: felt,
    ) -> (
        asset_price: AssetPriceStruct
    ):

        let (asset_price) = asset_price_storage.read(asset_address)

        return (
            asset_price = asset_price
        )
    end

    func update_asset_price_storage{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset_address: felt,
        asset_price: AssetPriceStruct,
    ) -> ():

        asset_price_storage.write(asset_address, asset_price)

        return ()
    end

    func read_owner_storage{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        owner_address: felt
    ):

        return owner_storage.read()
    end

    func update_owner_storage{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        owner_address: felt
    ) -> ():

        owner_storage.write(owner_address)

        return ()
    end

end