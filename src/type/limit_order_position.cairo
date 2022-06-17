%lang starknet

from starkware.cairo.common.uint256 import Uint256

struct LimitOrderPositionStruct:
    member owner_address: felt
    member maker_wts_asset_address: felt
    member maker_wts_asset_quantity: Uint256
    member maker_wtb_asset_address: felt
    member maker_wtb_asset_quantity: Uint256
    member maker_wtb_asset_min_quantity: Uint256
    member is_partial: felt
end