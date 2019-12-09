pragma solidity 0.5.9;
import './StandardToken.sol';
import './MultiOwnable.sol';

contract WhiteList{
    //whiteList functions
    function isWhiteListed(address _who) public view returns(bool);
    function canSentToken(address _which)public view returns (bool);
    function canReciveToken(address _which)public view returns (bool);
    function isTransferAllowed(address _who)public view returns(bool);
}

contract Utils {
    //utils functions
    function getByPassedAddress(address _which) public view returns(bool);
    function isHoldbackDaysOver(address _which,uint256 tokenSaleStartDate) public view returns(bool);
    function getTokenHoldBackDays(address _which) public view returns(uint256);
    function getTokenPrice(address _which) public view returns(uint256);
    function getTokenSwappable(address _which) public view returns(bool);
    function getSecurityCheck(address _which) public view returns(bool);
    function getSwapOn(address _which) public view returns(bool);
    function getTokenMaturityDays(address _which) public view returns(uint256);
    function getPreAuction(address _which) public view returns(bool);
    function getTokenHolderWallet(address _which) public view returns(address);
    function getMintingFeesPercent(address _which) public view returns(uint256);
    function getReturnToken(address _which) public view returns(address);
    function getTokenIsMature(address _which,uint256 tokenSaleStartDate) public view returns(bool);
    
}

contract Token {
    function swapForToken(address _to,uint256 _value) public returns (bool);
}

contract JNTR is StandardToken,MultiOwnable{
    
    uint256 public tokenSaleStartDate = 0;
 

    Utils util ;
    WhiteList whiteList;
    
    string constant ERR_WHITELIST_ADDRESS = "ERR_WHITELIST_ADDRESS";
    string constant ERR_TRANSFER_BLOCKED = "ERR_TRANSFER_BLOCKED";
    string constant ERR_TRANSFER_NOT_ALLOWED = "ERR_TRANSFER_NOT_ALLOWED";
    string constant ERR_HOLDBACK_DAYS = "ERR_HOLDBACK_DAYS";
    string constant ERR_TOKEN_SWAP_OFF = "ERR_TOKEN_SWAP_OFF";
    string constant ERR_TOKEN_SWAP_FAILED = "ERR_TOKEN_SWAP_FAILED";
    string constant ERR_TOKEN_MATURE = "ERR_TOKEN_MATURE";
    
    
    
    
    constructor(
                string memory _name,
                string memory _symbol,
                uint256 reserveSupply,
                uint256 holdBackSupply,
                address _tokenHolderWallet,
                address _systemAddress,
                address _whiteListAddress,
                address _utilAddress) public MultiOwnable(_systemAddress){
        name = _name;
        symbol = _symbol;
        reserveSupply = reserveSupply * 10 ** uint256(decimals);
        holdBackSupply = holdBackSupply * 10 ** uint256(decimals);
        _mint(address(this),reserveSupply);
        _mint(_tokenHolderWallet,holdBackSupply);
        tokenSaleStartDate = now;
        util = Utils(_utilAddress);
        whiteList = WhiteList(_whiteListAddress);
    }
    
    
    function setWhiteListAddress(address _whiteListAddress) public onlySystem returns (bool){
        whiteList = WhiteList(_whiteListAddress);
        return true;
    }
    function setUtilsAddress(address _utilAddress) public onlySystem returns (bool){
        util = Utils(_utilAddress);
        return true;
    }

    
    function swapForToken(address _to,uint256 _value) public returns (bool){
        require(util.getTokenSwappable(msg.sender),ERR_TRANSFER_NOT_ALLOWED);
        uint256 swapTokenPrice = util.getTokenPrice(msg.sender);
        uint256 tokenPrice = util.getTokenPrice(address(this));
        uint256 _assignToken = safeDiv(safeMul(_value,swapTokenPrice),tokenPrice);
        if(balances[address(this)] >= _assignToken){
          return _transfer(address(this),_to,_assignToken);
        }else{
            uint256 _remaningToken = safeSub(_assignToken,balances[address(this)]);
            _transfer(address(this),_to,balances[address(this)]);
            return _mint(_to,_remaningToken);
        }

    }
    
    function checkBeforeTransfer(address _from,address _to) internal view returns(bool){
        bool isByPassed = util.getByPassedAddress(msg.sender);
        bool securityCheck = util.getSecurityCheck(address(this));
        if(securityCheck && !isByPassed){
           require(whiteList.isWhiteListed(_from) && whiteList.canSentToken(_from),ERR_WHITELIST_ADDRESS);
           require(whiteList.isWhiteListed(_to) && whiteList.canReciveToken(_to),ERR_WHITELIST_ADDRESS); 
           require(whiteList.isTransferAllowed(_to),ERR_TRANSFER_NOT_ALLOWED);
           require(util.isHoldbackDaysOver(address(this),tokenSaleStartDate),ERR_HOLDBACK_DAYS);
           require(!util.getTokenIsMature(address(this),tokenSaleStartDate),ERR_TOKEN_MATURE);
        }
        return true;
    }
    
    function transfer(address _to, uint256 _value) public returns (bool ok) {
        bool reciveSwap = util.getTokenSwappable(_to);
        if(reciveSwap){
            bool swapOn = util.getSwapOn(address(this));
            require(swapOn,ERR_TOKEN_SWAP_OFF);
            bool is_trasnferd = _transfer(msg.sender,address(this),_value);
            require(is_trasnferd,ERR_TOKEN_SWAP_FAILED);
            Token token = Token(_to);
            return token.swapForToken(msg.sender,_value);
        }
        require(checkBeforeTransfer(msg.sender,_to));
        return super.transfer(_to,_value);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(checkBeforeTransfer(_from,_to));
        
        return super.transferFrom(_from,_to,_value);
    }

    function mint(address _to,uint256 _value) public onlySystem returns (bool){
        bool preAuction = util.getPreAuction(address(this));
        if(preAuction){
           uint256 mintingFeesPercent =  util.getMintingFeesPercent(address(this));
           uint256 mintingFee = safeDiv(safeMul(_value,mintingFeesPercent),100);
           address tokenHolderWallet = util.getTokenHolderWallet(address(this));
           require(tokenHolderWallet != address(0),ERR_ADDRESS_NOT_VALID);
            _mint(_to,_value);
            return _mint(tokenHolderWallet,mintingFee);
        }else{
            return _mint(_to,_value);
        }

    }
    
    function assignToken(address _to,uint256 _value) public onlyOwner returns (bool){
        if(balances[address(this)] >= _value){
           return _transfer(address(this),_to,_value);
        }else{
            uint256 _remaningToken = safeSub(_value,balances[address(this)]);
            _transfer(address(this),_to,balances[address(this)]);
            return _mint(_to,_remaningToken); 
        }
    }
    
    function burn(uint256 _value) public onlyOwner returns (bool){
        return _burn(address(this),_value);
    }
    
    //In case if there is other tokens into contract
    function returnTokens(address _tokenAddress,address _to,uint256 _value)public onlyOwner returns (bool){
        require(_tokenAddress != address(this));
        ERC20 tokens = ERC20(_tokenAddress);
        return tokens.transfer(_to,_value);
    }
    
    function forceSwapWallet(address[] memory _from) public onlyOwner returns (bool){
        address returnToken = util.getReturnToken(address(this));
        require(returnToken != address(0),ERR_ADDRESS_NOT_VALID);
        for(uint temp_x = 0 ; temp_x < _from.length ; temp_x++){
            address _address = _from[temp_x];
            bool is_burned = _burn(_address,balances[_address]);
            require(is_burned,ERR_TOKEN_SWAP_FAILED);
            Token token = Token(returnToken);
            bool token_swapped = token.swapForToken(_address,balances[_address]);
            require(token_swapped,ERR_TOKEN_SWAP_FAILED);
        }

    }
  
    function () external payable{
       revert();
    }
}