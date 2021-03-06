pragma solidity 0.5.9;
import './StandardToken.sol';


contract StockTokenUtils is StandardToken{
    
    // actulprice * 1000000
    // basePrice is set $1 
    uint public tokenPrice = 1000000;
    
    // price decimal 
    uint public priceDecimal = 6;

    uint256 public tokenSaleStartDate = 0;
    
    uint256 public tokenMaturityDays = 3560;
    
    uint public tokenHoldBackDays = 90;
    
    bool public securityCheck = true;
    
    address payable public tokenHolderWallet = address(0);
    
    address public whiteListAddress = address(0);
    
    address public mainTokenAddress = address(0);
    
    address public etnTokenAddress = address(0);
    
    bool public isDirectSwap = false;

    
    constructor(string memory _name,
                string memory _symbol,
                address _systemAddress,
                address payable _tokenHolderWallet,
                address _whiteListAddress) public  notZeroAddress(_tokenHolderWallet) notZeroAddress(_whiteListAddress) StandardToken(_name,_symbol,_systemAddress){
                    tokenHolderWallet = _tokenHolderWallet;
                    whiteListAddress = _whiteListAddress;
                    tokenSaleStartDate = now;
                }
                
    function setTokenPrice(uint _tokenPrice) public onlySystem returns(bool){
        tokenPrice = _tokenPrice;
        return true;
    }
    
    
    function setMainTokenAddress(address _mainTokenAddress) public onlySystem notZeroAddress(_mainTokenAddress) returns(bool){
        mainTokenAddress = _mainTokenAddress;
        return true;
    }
    
    function setEtnAddress(address _etnTokenAddress) public notZeroAddress(_etnTokenAddress) onlySystem returns(bool){
        etnTokenAddress = _etnTokenAddress;
        return true;
    }
    
    
    function setIsDirectSwap(bool _isDirectSwap) public onlySystem returns(bool){
        isDirectSwap = _isDirectSwap;
        return true;
    }
    

    function setSecurityCheck(bool _securityCheck) public onlySystem returns(bool){
        securityCheck = _securityCheck;
        return true;
    }
    
    function setWhiteListAddress(address _whiteListAddress) public onlySystem notZeroAddress(_whiteListAddress) returns(bool){
        whiteListAddress = _whiteListAddress;
        return true;
    }
   
    function setTokenHoldBackDays(uint _holdBackDays) public onlyOwner returns(bool){
        tokenHoldBackDays = _holdBackDays;
        return true;
    }
    
    function setTokenMaturityDays(uint256 _tokenMaturityDays) public onlyOwner returns(bool){
        tokenMaturityDays = _tokenMaturityDays;
        return true;
    }
    
    function setTokenHolderWallet(address payable _tokenHolderWallet) public onlyOwner notZeroAddress(_tokenHolderWallet) returns(bool){
        tokenHolderWallet = _tokenHolderWallet;
        return true;
    }
    
    
    
    function isTokenMature() public view returns(bool){
        if(tokenMaturityDays == 0)
            return false;
        uint256 tempDay = safeMul(86400,tokenMaturityDays);
        uint256 tempMature = safeAdd(tempDay,tokenSaleStartDate);
        if(now >= tempMature){
            return true;
        }
        return false;
    }
    
    function isHoldbackDaysOver() public view returns(bool){
        uint256 tempDay = safeMul(86400,tokenHoldBackDays);
        
        uint256 holdBackDaysEndDay = safeAdd(tempDay,tokenSaleStartDate);
        
        if(now >= holdBackDaysEndDay){
            return true;
        }
        
        return false;
    }
    
    
    
}