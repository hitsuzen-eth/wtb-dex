%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address

from src.type.oracle import AssetPriceStruct
from src.storage.oracle import OracleStorage
from src.logic.owner import OwnerLogic

namespace OracleInteraction:

    @constructor
    func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        owner : felt
    ):

        OracleStorage.update_owner(owner)

        return ()
    end

    @external
    func read_asset_price{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset_address: felt,
    ) -> (asset_price: AssetPriceStruct):

        return OracleStorage.read_asset_price(
            asset_address = asset_address
        )
    end

    @external
    func update_asset_price{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset_address: felt,
        asset_price: AssetPriceStruct,
    ) -> ():

        let (caller_address) = get_caller_address()
        let (owner_address) = OracleStorage.read_owner()
        OwnerLogic.check_is_owner(
            caller_address = caller_address,
            owner_address = owner_address
        )

        OracleStorage.update_asset_price(
            asset_address = asset_address,
            asset_price = asset_price,
        )
        
        return ()
    end

    @external
    func read_owner_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (owner_address: felt):

        return OracleStorage.read_owner()
    end

    @external
    func update_owner_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        new_owner_address: felt,
    ) -> ():

        let (caller_address) = get_caller_address()
        let (owner_address) = OracleStorage.read_owner()
        OwnerLogic.check_is_owner(
            caller_address = caller_address,
            owner_address = owner_address
        )

        OracleStorage.update_owner(
            owner_address = new_owner_address,
        )
        
        return ()
    end

end