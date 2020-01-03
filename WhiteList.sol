pragma solidity 0.5.9;
import './Ownable.sol';

 
contract WhiteList is Ownable{
    
    struct UserDetails{
        uint whiteListType;
        uint maxWallets;
        bool canRecive;
        bool canSend;
        address[] wallets;
        mapping (string => string) moreDetails;
    }
    
    constructor(address _systemAddress) public Ownable(_systemAddress){
        whiteListAccount(msg.sender,0,10);
        whiteListAccount(_systemAddress,0,10);
        allowed_in_primary[0] = true;
        allowed_in_secondary[0] = true;
    }
    
    mapping (address => bool) public is_whiteListed;
    
    mapping (address => address) public address_belongs;
    
    mapping (address => UserDetails) public user_details;
    
    mapping (uint => bool) public allowed_in_primary;
    
    mapping (uint => bool) public allowed_in_secondary;
    
    event AccountWhiteListed(address indexed which ,uint walletType);
    event WalletAdded(address indexed from,address indexed which);
    
    function whiteListAccount(address _which,uint _whiteListType,uint256 _maxWallets) internal returns (bool){
        is_whiteListed[_which] = true;
        UserDetails storage details = user_details[_which];
        details.whiteListType = _whiteListType;
        details.maxWallets = _maxWallets;
        details.canRecive = true;
        details.canSend = true;
        address_belongs[_which] = _which;
        emit AccountWhiteListed(_which,_whiteListType);
        return true;
    }
    
    
    /**
        * @dev add new whitelisted account
        * @param _which The address which was whitelisted.
        * @param _whiteListType account type
        * @param _maxWallets user can whitelist limted wallets
        * @return true if transcation success
    */
    function addNewWallet(address _which,uint _whiteListType,uint256 _maxWallets) public onlySystem returns(bool){
        require(address_belongs[_which] == address(0));
        return whiteListAccount(_which,_whiteListType,_maxWallets);
    }
    
    
    /**
        * @dev update how many wallet one user can have 
        * @param _which The address which was whitelisted.
        * @param _maxWallets user can whitelist limted wallets
        * @return true if transcation success
    */
    function updateMaxWallet(address _which,uint _maxWallets) public onlyOwner returns(bool){
        require(is_whiteListed[_which],ERR_ACTION_NOT_ALLOWED);
        UserDetails storage details = user_details[_which];
        details.maxWallets = _maxWallets;
        return true;
    }
    
    
    /**
        * @dev once user whiltelisted they can add more address itself
        * @param _which The address which was whitelisted.
        * @return true if transcation success
    */
    function addMoreWallets(address _which) public returns (bool){
        require(address_belongs[_which] == address(0),ERR_ACTION_NOT_ALLOWED);
        address sender = msg.sender;
        address primaryAddress = address_belongs[sender];
        require(is_whiteListed[primaryAddress] && sender == primaryAddress,ERR_ACTION_NOT_ALLOWED);
        UserDetails storage details = user_details[primaryAddress];
        require(details.maxWallets > details.wallets.length,ERR_MAXIMUM_WALLET_LIMIT);
        address_belongs[_which] = primaryAddress;
        details.wallets.push(_which);
        emit WalletAdded(primaryAddress,_which);
        return true;
    }
    
    function getUserWallets(address _which) public view returns (address[] memory){
        UserDetails storage details = user_details[_which];
        return details.wallets;
    }
    
    /**
    * @dev function to set if user can receive token or not
    * @param _which The address which was blocked or unblocked.
    * @param _recive bool is set unlbocking or blocking.
    */
    function setReciveAndSend(address _which,bool _recive,bool _send)public onlySystem returns (bool){
        require(is_whiteListed[_which],ERR_ACTION_NOT_ALLOWED);
        UserDetails storage details = user_details[_which];
        details.canRecive = _recive;
        details.canSend = _send;
        return true;
    }
    
   
    /**
    * @dev function to check if user can send token or not
    * @param _which The address which was blocked or unblocked.
    */
    function canSentToken(address _which) public view returns (bool){
        address primaryAddress = address_belongs[_which];
        return user_details[primaryAddress].canSend;
    }
    
    /**
        * @dev function to check if user can recive token or not
        * @param _which The address which was blocked or unblocked.
    */
    function canReciveToken(address _which) public view returns (bool){
        address primaryAddress = address_belongs[_which];
        return user_details[primaryAddress].canRecive;
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
        return allowed_in_secondary[user_details[primaryAddress].whiteListType];
    }
    
    /**
    * @dev function to set primary whiteList type allowed
    * @param _whiteListType is array for type of account .
    * @param _isAlloweded is array for bool.
    */
    function changeAllowInPrimary(uint[] memory _whiteListType , bool[] memory _isAlloweded) public onlyOwner returns (bool){
        require( _whiteListType.length == _isAlloweded.length);
        for(uint temp_x = 0 ; temp_x < _whiteListType.length ; temp_x ++){
            allowed_in_primary[_whiteListType[temp_x]] = _isAlloweded[temp_x];
        }
        return true;

    }
    
    /**
    * @dev function to set primary whiteList type allowed
    * @param _whiteListType is array for type of account .
    * @param _isAlloweded is array for bool.
    */
    function changeAllowInSecondary(uint[] memory _whiteListType , bool[] memory _isAlloweded) public onlyOwner returns (bool){
        require( _whiteListType.length == _isAlloweded.length);
        for(uint temp_x = 0 ; temp_x < _whiteListType.length ; temp_x ++){
            allowed_in_secondary[_whiteListType[temp_x]] = _isAlloweded[temp_x];
        }
        return true;

    }
    

    
}   