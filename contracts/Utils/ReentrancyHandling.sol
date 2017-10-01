pragma solidity ^0.4.13;

contract ReentrancyHandling {

    bool locked;

    modifier noReentrancy() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }
}
