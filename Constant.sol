pragma solidity 0.5.9;


contract Constant{ 
    
    string constant ERR_CONTRACT_SELF_ADDRESS = "ERR_CONTRACT_SELF_ADDRESS";
    string constant ERR_ZERO_ADDRESS = "ERR_ZERO_ADDRESS";
    
    string constant ERR_ACTION_NOT_ALLOWED  = "ERR_ACTION_NOT_ALLOWED";
    string constant ERR_MAXIMUM_WALLET_LIMIT = "ERR_MAXIMUM_WALLET_LIMIT";
    
    string constant ERR_NOT_ENOUGH_BALANCE = "ERR_NOT_ENOUGH_BALANCE";
    string constant ERR_VALUE_IS_ZERO = "ERR_VALUE_IS_ZERO";
    
    string constant ERR_TRANSFER_CHECK_WHITELIST = "ERR_TRANSFER_CHECK_WHITELIST";
    string constant ERR_TRANSFER_CHECK_BLOCK_WALLET = "ERR_TRANSFER_CHECK_BLOCK_WALLET";
    string constant ERR_TOKEN_SWAP_FAILED = "ERR_TOKEN_SWAP_FAILED";
    
    
    modifier notOwnAddress(address _which) {
        require(msg.sender != _which,ERR_ACTION_NOT_ALLOWED);
        _;
    }
    
    modifier notZeroAddress(address _which){
        require(_which != address(0),ERR_ZERO_ADDRESS);
        _;
    }
    
    modifier notThisAddress(address _which){
        require(_which != address(this),ERR_CONTRACT_SELF_ADDRESS);
        _;
    }
    
    modifier notZeroValue(uint256 _value){
         require(_value > 0,ERR_VALUE_IS_ZERO);
        _;
    }
}