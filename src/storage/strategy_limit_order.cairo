%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from src.type.limit_order_position import LimitOrderPositionStruct

@storage_var
func position_list_storage(
    id: felt
) -> (
    position: LimitOrderPositionStruct
):
end

@storage_var
func position_len_storage() -> (
    position_len: felt
):
end

@storage_var
func wtb_dex_address_storage() -> (
    wtb_dex_address: felt
):
end

namespace StrategyLimitOrderStorage:

    func create_position{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position: LimitOrderPositionStruct,
    ) -> (
        id: felt
    ):

        alloc_locals

        let (local position_len) = position_len_storage.read()

        position_list_storage.write(
            id = position_len,
            value = position
        )

        position_len_storage.write(
            value = (position_len + 1)
        )

        return (
            id = position_len
        )
    end

    func read_position{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        id: felt,
    ) -> (
        position: LimitOrderPositionStruct
    ):

        return position_list_storage.read(
            id = id
        )
    end

    func update_position{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        id: felt,
        position: LimitOrderPositionStruct,
    ) -> ():

        position_list_storage.write(
            id = id,
            value = position
        )

        return ()
    end

    func read_wtb_dex_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (
        wtb_dex_address: felt
    ):

        return wtb_dex_address_storage.read()
    end

    func update_wtb_dex_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        wtb_dex_address: felt,
    ) -> ():

        wtb_dex_address_storage.write(
            value = wtb_dex_address
        )

        return ()
    end

end