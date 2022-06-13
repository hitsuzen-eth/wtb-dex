%lang starknet

from starkware.cairo.common.uint256 import Uint256

struct LimitOrderPositionStruct:
    member owner_address: felt
    member oracle_address: felt
    member limit_asset_price: Uint256
    member asset_in_address: felt
    member asset_in_quantity: Uint256
    member asset_out_address: felt
    member asset_out_quantity: Uint256
    member is_partial: felt
end