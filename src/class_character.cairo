#[starknet::contract]
mod ClassCharacterV2 {
    use core::zeroable::Zeroable;

     #[storage]
    struct Storage {
        owner: ContractAddress,
        students: LegacyMap::<ContractAddress, Student>
    }

    #[derive(Copy, Drop, Serde, starknet::Store)]
    struct Student {
        name: felt252,
        age: u8,
        is_active: bool,
        has_reward: bool,
        xp_earnings: u256
    }

    #[constructor]
    fn constructor(ref self: ContractState, _init_owner: ContractAddress) {
        self.owner.write(_init_owner);
    }

}