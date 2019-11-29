pragma solidity 0.5.9;
import './Ownable.sol';
import './SafeMath.sol';

contract WhiteList is Ownable,SafeMath{


    constructor() public{
        whiteListAccount(msg.sender,0);
        allowedInPrimary[0] = true;
        allowedInSecondary[0] = true;
    }

    event AccountWhiteListed(address indexed which ,uint walletType);
    event WalletAdded(address indexed from,address indexed which);

    struct UserDetails{
        string  email;
        string name;
        string phone;
    }

    uint thresholdKycRenewale = 0;
    uint thresholdTransctions = 0;

    mapping (address => bool) public is_whiteListed;
    mapping (address => uint) public whitelist_type;
    mapping (address => address) public address_belongs;
    mapping (address => UserDetails) public user_details;
    mapping (address => bool) public recive_block;
    mapping (address => bool) public sent_block;
    mapping (uint => bool) public allowedInPrimary;
    mapping (uint => bool) public allowedInSecondary;

    
   
    function whiteListAccount(address _address,uint _whiteListType) internal returns (bool){
        is_whiteListed[_address] = true;
        whitelist_type[_address] = _whiteListType;
        address_belongs[_address] = _address;
        emit AccountWhiteListed(_address,_whiteListType);
        return true;
    }

     /**
    * @dev add new whitelisted account
    * @param _address The address which was whitelisted.
    * @param _whiteListType account type
    */
    function addNewWallet(address _address,uint _whiteListType) public onlyOwner returns(bool){
        require(address_belongs[_address] == address(0));
        return whiteListAccount(_address,_whiteListType);
    }
    
    /**
    * @dev once user whiltelisted it can add more address itself
    * @param _address The address which was whitelisted.
    */
    function addMoreWallets(address _which) public returns (bool){
        require(address_belongs[_which] == address(0));
        address sender = msg.sender;
        address primaryAddress = address_belongs[sender];
        require(is_whiteListed[primaryAddress]);
        address_belongs[_which] = primaryAddress;
        emit WalletAdded(primaryAddress,_which);
        return true;
    }

    
    /**
    * @dev number of transaction valid for whitelisting 
    * @param _thresholdTransctions transaction number allowed
    */
    function setThresholdTransctions(uint _thresholdTransctions) public onlyOwner returns (bool){
        thresholdTransctions = _thresholdTransctions;
        return true;
    }
    
    /**
    * @dev number of days valid for whitelisting 
    * @param _thresholdKycRenewale days number allowed
    */
    function setThresholdKycRenewal(uint _thresholdKycRenewale) public onlyOwner returns (bool){
        thresholdKycRenewale = _thresholdKycRenewale;
        return true;
    }
    
    /**
    * @dev function to set if user can receive token or not
    * @param _which The address which was blocked or unblocked.
    * @param _recive bool is set unlbocking or blocking.
    */
    function setCanRecive(address _which,bool _recive)public onlyOwner returns (bool){
        recive_block[_which] = _recive;
        return true;
    }
    
    /**
    * @dev function to set if user can send token or not
    * @param _which The address which was blocked or unblocked.
    * @param _recive bool is set unlbocking or blocking.
    */
    function setCansent(address _which,bool sent)public onlyOwner returns (bool){
        recive_block[_which] = sent;
        return true;
    }
    
    /**
    * @dev function to check if user can send token or not
    * @param _which The address which was blocked or unblocked.
    */
    function canSentToken(address _which)public view returns (bool){
        address primaryAddress = address_belongs[_which];
        return !sent_block[primaryAddress];

    }
    
    /**
    * @dev function to check if user can recive token or not
    * @param _which The address which was blocked or unblocked.
    */
    function canReciveToken(address _which)public view returns (bool){
        address primaryAddress = address_belongs[_which];
        return !recive_block[primaryAddress];
    }
    
    
    /**
    * @dev function to check if address whitelisted or not
    * @param _which The address which was whitelisted.
    */
    function isWhiteListed(address _which) public view returns(bool){
        address primaryAddress = address_belongs[_which];
        return is_whiteListed[primaryAddress];
    }
    
    
    /**
    * @dev function to check if transfer allowed between whitelist type
    * @param _which The address which was whitelisted.
    */
    function isTransferAllowed(address _which) public view returns(bool){
        address primaryAddress = address_belongs[_which];
        uint accountType = whitelist_type[primaryAddress];
        return allowedInSecondary[accountType];
    }
    
    /**
    * @dev function to set primary whiteList type allowed
    * @param _whiteListType is array for type of account .
    * @param _isAlloweded is array for bool.
    */
    function changeAllowInPrimary(uint[] memory _whiteListType , bool[] memory _isAlloweded) public onlyOwner returns (bool){
        require( _whiteListType.length == _isAlloweded.length);
        for(uint temp_x = 0 ; temp_x < _whiteListType.length ; temp_x ++){
            allowedInPrimary[_whiteListType[temp_x]] = _isAlloweded[temp_x];
        }
        return true;

    }
    
    /**
    * @dev function to set secondary whiteList type allowed
    * @param _whiteListType is array for type of account .
    * @param _isAlloweded is array for bool.
    */
    function changeAllowInSecondary(uint[] memory _whiteListType , bool[] memory _isAlloweded) public onlyOwner returns (bool){
        require( _whiteListType.length == _isAlloweded.length);
        for(uint temp_x = 0 ; temp_x < _whiteListType.length ; temp_x ++){
            allowedInSecondary[_whiteListType[temp_x]] = _isAlloweded[temp_x];
        }
        return true;

    }


}
