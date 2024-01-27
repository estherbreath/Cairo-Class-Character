#[starknet::contract]
mod ClassCharacterV2 {
    use core::zeroable::Zeroable;
    use core::starknet::event::EventEmitter;
    use starknet::{ContractAddress, get_caller_address};

    // event 
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnerUpdated: OwnerUpdated,
        StudentAdded: StudentAdded
    }

    #[derive(Drop, starknet::Event)]
    struct OwnerUpdated {
        init_owner: ContractAddress,
        new_owner: ContractAddress
    }

    #[derive(Drop, starknet::Event)]
    struct StudentAdded {
        student: ContractAddress,
    }

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

      impl ContractState for Self {
        fn set_owner(self:ContractAddress, new_owner: ContractAddress) -> bool {
            let owner = self.owner.read();
            let caller = get_caller_address();
            assert(owner == caller, 'caller not owner');
            self.owner.write(new_owner);
            self.emit(OwnerUpdated { init_owner: owner, new_owner: new_owner });
            true
        }

        fn get_owner(self:ContractAddress) -> ContractAddress {
            self.owner.read()
        }

        fn internal_get_owner(self:ContractAddress) -> ContractAddress {
            self.owner.read()
        }
      }

       // validate age 
    fn validate_age(age: u8) -> bool {
        if age >= 18 && age <= 100 {
            return true;
        } else {
            return false;
        }
    }
    

    #[constructor]
    fn constructor(ref self: ContractState, _init_owner: ContractAddress) {
        self.owner.write(_init_owner);
    }

    #[external(v0)]
    fn add_student(
        ref self: ContractState,
        student_account: ContractAddress,
        _name: felt252,
        _age: u8,
        _is_active: bool,
        _has_reward: bool,
        _xp_earnings: u256,
    ) {
        let owner = self.owner.read();
        let caller = get_caller_address();
        assert(owner == caller, 'caller not owner');
        assert(!student_account.is_zero(), 'caller cannot be address zero');
        assert(student_account != owner, 'student_account cannot be owner');
        assert(_name != '', 'name cannot be empty');
        assert(_age != 0, 'age cannot be zero');
        let student_instance = Student {
            name: _name,
            age: _age,
            is_active: _is_active,
            has_reward: _has_reward,
            xp_earnings: _xp_earnings
        };
        self.students.write(student_account, student_instance);
        self.emit(StudentAdded { student: student_account });

        assert(validate_age(_age), 'invalid age');
        assert(validate_address(student_account), 'invalid student address');
    }

     #[external(v0)]
    fn set_owner(ref self: ContractState, _new_owner: ContractAddress) -> bool {
        let owner = self.owner.read();
        let caller = get_caller_address();
        assert(owner == caller, 'caller not owner');
        self.owner.write(_new_owner);
        self.emit(OwnerUpdated { init_owner: owner, new_owner: _new_owner });
        true
    }

    #[external(v0)]
    fn get_owner(self: @ContractState) -> ContractAddress {
        self.owner.read()
    }

     // This function cannot be access outside this contract (internal)
    fn internal_get_owner(self: @ContractState) -> ContractAddress {
        self.owner.read()
    }

    #[external(v0)]
    fn get_student(self: @ContractState, student_account: ContractAddress) -> Student {
        self.students.read(student_account)
    }

}
