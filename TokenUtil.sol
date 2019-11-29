pragma solidity 0.5.9;
import './Ownable.sol';
import './SafeMath.sol';

contract TokenUtil is Ownable,SafeMath{
    
    constructor() public{
       
    }
    
    string constant ARRAY_NOT_MATCHED = "ARRAY_NOT_MATCHED";
    
    //check if address is swapble with tokens 
    mapping (address => bool) isSwappable;
    //ActualPrice * 1000 becaus of fraction;Price in $
    mapping (address => uint256) tokenPrice;
    // Address which can perform action without any restrications 
    mapping (address => bool) byPassedAddress;
    // Token HoldBack Days mapped by conract address
    mapping (address => uint256) tokenHoldBackDays;
    // check if address need security check 
    mapping (address => bool) securityCheck;
    // check if swap is on for tokens 
    mapping (address => bool) swapOn;
    //token maturity Days
    mapping (address => uint256) tokenMaturityDays;
    // token preaucation is on 
    mapping (address => bool) preAuction;
    // tokenHolderWallet
    mapping (address => address) tokenHolderWallet;
    // mapping minitng fees 
    mapping (address => uint256) mintingFeesPercent;
    // return tokens while swaping 
    mapping (address => address) returnToken;
    
    
    event TokenPriceUpdate(address indexed _which,uint256 _from,uint256 _to);
    event AddressByPassed(address indexed _which,bool _isPassed);
    event TokenHoldBackDaysUpdated(address indexed _which,uint256 _from,uint256 _to);
    event TokenSwappableUpdated(address indexed _which,bool _isPassed);
    event TokenMaturityDaysUpdated(address indexed _which,uint256 _tokenMaturityDays);
    event TokenMintingFeesPercentUpdated(address indexed _which,uint256 _mintingFeesPercent);
    event TokenSecurityCheckUpdated(address indexed _which,bool _securityCheck);
    event TokenSwapOnUpdated(address indexed _which,bool _swapOn);
    event TokenPreAuctionUpdated(address indexed _which,bool _preAuction);
    event TokenHolderWalletUpdated(address indexed _which,address indexed _whom);
    event TokenReturnUpdated(address indexed _which,address indexed _whom);
    
    function setTokenSwappable(address _which,bool _isSwappable) public onlyOwner returns(bool){
        isSwappable[_which] = _isSwappable;
        emit TokenSwappableUpdated(_which,_isSwappable);
        return true;
    }
    
    function getTokenSwappable(address _which) public view returns(bool){
        return isSwappable[_which];
    }
    
    function setTokenPrice(address _which,uint256 _price) public onlyOwner returns(bool){
        uint256 oldPrice = tokenPrice[_which];
        tokenPrice[_which] = _price;
        emit TokenPriceUpdate(_which,oldPrice,_price);
        return true;
    }
    
    function getTokenPrice(address _which) public view returns(uint256){
        return tokenPrice[_which];
    }
     
    function setByPassedAddress(address _which,bool _isPassed) public onlyOwner returns(bool){
        byPassedAddress[_which] = _isPassed;
        emit AddressByPassed(_which,_isPassed);
        return true;
    }
     
    function getByPassedAddress(address _which) public view returns(bool){
        return byPassedAddress[_which];
    }
    
    function setTokenHoldBackDays(address _which,uint256 _holdBackDays) public onlyOwner returns(bool){
        uint256 oldHoldBack = tokenHoldBackDays[_which];
        tokenHoldBackDays[_which] = _holdBackDays;
        emit TokenHoldBackDaysUpdated(_which,oldHoldBack,_holdBackDays);
        return true;
    }
    
    function getTokenHoldBackDays(address _which) public view returns(uint256){
        return tokenHoldBackDays[_which];
    }
    
    function setSecurityCheck(address _which,bool _securityCheck) public onlyOwner returns(bool){
        securityCheck[_which] = _securityCheck;
        emit TokenSecurityCheckUpdated(_which,_securityCheck);
        return true;
    }
    
    function getSecurityCheck(address _which) public view returns(bool){
        return securityCheck[_which];
    }
    
    function setSwapOn(address _which,bool _swapOn) public onlyOwner returns(bool){
        swapOn[_which] = _swapOn;
        emit TokenSwapOnUpdated(_which,_swapOn);
        return true;
    }
    
    function getSwapOn(address _which) public view returns(bool){
        return swapOn[_which];
    }
    
    function setTokenMaturityDays(address _which,uint256 _tokenMaturityDays) public onlyOwner returns(bool){
        tokenMaturityDays[_which] = _tokenMaturityDays;
        emit TokenMaturityDaysUpdated(_which,_tokenMaturityDays);
        return true;
    }
    
    function getTokenMaturityDays(address _which) public view returns(uint256){
        return tokenMaturityDays[_which];
    }
    
    function setPreAuction(address _which,bool _preAuction) public onlyOwner returns(bool){
        preAuction[_which] = _preAuction;
        emit TokenPreAuctionUpdated(_which,_preAuction);
        return true;
    }
    
    function getPreAuction(address _which) public view returns(bool){
        return preAuction[_which];
    }
    
    function setTokenHolderWallet(address _which,address _whom) public onlyOwner returns(bool){
        tokenHolderWallet[_which] = _whom;
        emit TokenHolderWalletUpdated(_which,_whom);
        return true;
    }
    
    function getTokenHolderWallet(address _which) public view returns(address){
        return tokenHolderWallet[_which];
    }
    
    function setMintingFeesPercent(address _which,uint256 _mintingFeesPercent) public onlyOwner returns(bool){
        mintingFeesPercent[_which] = _mintingFeesPercent;
        emit TokenMintingFeesPercentUpdated(_which,_mintingFeesPercent);
        return true;
    }
    
    function getMintingFeesPercent(address _which) public view returns(uint256){
        return mintingFeesPercent[_which];
        
    }
    
    function setReturnToken(address _which,address _whom) public onlyOwner returns(bool){
        returnToken[_which] = _whom;
        emit TokenReturnUpdated(_which,_whom);
        return true;
    }
    
    function getReturnToken(address _which) public view returns(address){
        return returnToken[_which];
    }
    
    function getTokenIsMature(address _which,uint256 tokenSaleStartDate) public view returns(bool){
        uint256 maturityDays = tokenMaturityDays[_which];
        if(maturityDays == 0){
            return false;
        }
        uint256 tempDay = safeMul(86400,maturityDays);
        uint256 isTokenMature = safeAdd(tempDay,tokenSaleStartDate);
        if(now >= isTokenMature){
            return true;
        }
        return false;
    }
    
    function isHoldbackDaysOver(address _which,uint256 tokenSaleStartDate) public view returns(bool){
        uint256  holdBackDays = tokenHoldBackDays[_which];
        uint256 tempDay = safeMul(86400,holdBackDays);
        uint256 holdBackDaysEndDay = safeAdd(tempDay,tokenSaleStartDate);
        if(now >= holdBackDaysEndDay){
            return true;
        }
        return false;
    }
    
    
    
    
    
    
}