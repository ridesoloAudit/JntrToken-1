pragma solidity 0.5.9;

contract MultiOwnable {


    address public primaryOwner = address(0);
    address public systemAddress = address(0);
    
    string constant PRIMARY_OWNER = "PRIMARY_OWNER";
    string constant SYSTEM_ADDRESS = "SYSTEM_ADDRESS";
    string constant ERR_ALLOWED_ADDRESS_ONLY = "ERR_ALLOWED_ADDRESS_ONLY";
    string constant ERR_NOT_THIS_ADDRESS = "ERR_NOT_THIS_ADDRESS";
    string constant ERR_ACTION_NOT_ALLOWED  = "ERR_ACTION_NOT_ALLOWED";


    /**
    * @dev The Ownable constructor sets the `primaryOwner` and `systemAddress`
    * account.
    */
    constructor(address _systemAddress) public {
        primaryOwner = msg.sender;
        systemAddress = _systemAddress;
    }
    
    //  new primary owner address
    address public primaryOwnerAllowed = address(0);
    
    //  new system owner address
    address public systemAddressAllowed = address(0);

    event OwnershipTransferred(string ownerType,address indexed previousOwner, address indexed newOwner);
    event AllowChangeOwner(string ownerType,address indexed _allowedBy,address indexed _allowed);



    modifier onlyOwner() {
        require(msg.sender == primaryOwner,ERR_ALLOWED_ADDRESS_ONLY);
        _;
    }

    modifier onlySystem() {
        require(msg.sender == primaryOwner ||
            msg.sender == systemAddress,ERR_ALLOWED_ADDRESS_ONLY);
        _;
    }

    
    modifier notOwnAddress(address _which) {
        require(msg.sender != _which,ERR_NOT_THIS_ADDRESS);
        _;
    }

    /**
    * @dev Allow To change primary account
    * @param _address The address which was approved.
    */
    function allowChangePrimaryOwner(address _address) public onlyOwner notOwnAddress(_address) returns(bool){
        primaryOwnerAllowed = _address;
        emit AllowChangeOwner(PRIMARY_OWNER,msg.sender,_address);
        return true;
    }

    /**
    * @dev Allow To change system account
    * @param _address The address which was approved.
    */
    function allowChangeSystemAddress(address _address) public onlyOwner notOwnAddress(_address) returns(bool){
        systemAddressAllowed = _address;
        emit AllowChangeOwner(SYSTEM_ADDRESS,msg.sender,_address);
         return true;
    }
    
    
    /**
    * @dev Accept primary ownership
    */
    function acceptPrimaryOwnership() public returns(bool){
        require(msg.sender == primaryOwnerAllowed,ERR_ACTION_NOT_ALLOWED);
        emit OwnershipTransferred(PRIMARY_OWNER,primaryOwner,primaryOwnerAllowed);
        primaryOwner = primaryOwnerAllowed;
        primaryOwnerAllowed = address(0);
        return true;
    }

    
    /**
    * @dev Accept system ownership
    */
    function acceptSystemAddressOwnership() public returns(bool){
        require(msg.sender == systemAddressAllowed,ERR_ACTION_NOT_ALLOWED);
        emit OwnershipTransferred(SYSTEM_ADDRESS,systemAddress,systemAddressAllowed);
        systemAddress = msg.sender;
        systemAddressAllowed = address(0);
        return true;
    }
    
}