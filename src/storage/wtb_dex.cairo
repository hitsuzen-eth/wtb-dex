%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

@storage_var
func strategy_list_storage(
    id: felt,
) -> (
    strategy_address: felt
):
end

@storage_var
func strategy_list_last_id_storage(
) -> (
    last_id: felt
):
end

namespace WtbDexStorage:

    func read_strategy_list_storage{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        id: felt
    ) -> (
        strategy_address: felt
    ):

        return strategy_list_storage.read(
            id = id
        )
    end

    func update_strategy_list_storage{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        id: felt,
        strategy_address: felt,
    ) -> ():

        strategy_list_storage.write(
            id = id,
            value = strategy_address
        )

        return ()
    end

    func read_strategy_list_last_id_storage{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (
        last_id: felt
    ):

        return strategy_list_last_id_storage.read()
    end

    func update_strategy_list_last_id_storagee{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        last_id: felt,
    ) -> ():

        strategy_list_last_id_storage.write(
            value = last_id
        )

        return ()
    end
    
end