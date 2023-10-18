// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {Owned} from "solmate/auth/Owned.sol";

interface IBitcoin {
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 value) external;
    function decimals() external returns (uint8);
}

contract DropBox is Owned {
    constructor(address owner_) Owned(owner_) {}

    function collect(uint256 value, IBitcoin underlying) public onlyOwner {
        underlying.transfer(owner, value);
    }
}

contract WrappedBitcoin is ERC20 {
    // =============================================================
    //                           ERRORS
    // =============================================================

    error DropBoxNotCreated(address owner);
    error DropBoxAlreadyExists(address owner);
    error DropBoxInsufficientBalance(address owner);
    error OwnerInsufficientBalance(address owner);

    // =============================================================
    //                           EVENTS
    // =============================================================

    event DropBoxCreated(address indexed owner);
    event Wrapped(uint256 indexed value, address indexed owner);
    event Unwrapped(uint256 indexed value, address indexed owner);

    // =============================================================
    //                           STORAGE
    // =============================================================

    IBitcoin public underlying = IBitcoin(address(0x853737186cb24D4152f979B9152F652b67F7e9b7));

    mapping(address => address) public dropBoxes;

    // =============================================================
    //                           CONSTRUCTOR
    // =============================================================

    constructor() ERC20("Wrapped Bitcoin", "WBTC", 8) {}

    // =============================================================
    //                           FUNCTIONS
    // =============================================================

    function createDropBox() public {
        if (dropBoxes[msg.sender] != address(0)) revert DropBoxAlreadyExists(msg.sender);

        dropBoxes[msg.sender] = address(new DropBox(address(this)));

        emit DropBoxCreated(msg.sender);
    }

    function deposit(uint256 value) public {
        address dropBox = dropBoxes[msg.sender];

        if (dropBox == address(0)) revert DropBoxNotCreated(msg.sender);
        if (underlying.balanceOf(dropBox) < value) revert DropBoxInsufficientBalance(msg.sender);

        DropBox(dropBox).collect(value, underlying);
        _mint(msg.sender, value);

        emit Wrapped(value, msg.sender);
    }

    function withdraw(uint256 value) public {
        if (balanceOf[msg.sender] < value) revert OwnerInsufficientBalance(msg.sender);

        underlying.transfer(msg.sender, value);
        _burn(msg.sender, value);

        emit Unwrapped(value, msg.sender);
    }
}
