pragma solidity 0.5.9;
import './JntrStockUtils.sol';

contract WhiteList{
    function isWhiteListed(address _who) public view returns(bool);
    function checkBeforeTransfer(address _from ,address _to) public view returns (bool);
    function isAddressByPassed(address _which) public view returns (bool);
}

contract Token {
    function swapForTokens(uint256 _tokenPrice,address _to,uint256 _value) public returns(bool);
}


contract JntrStock is JntrStockUtils{

     constructor(string memory _name,string memory _symbol,
                address _systemAddress,address payable _tokenHolderWallet,
                address _whiteListAddress,
                uint256 reserveSupply,uint256 holdBackSupply) public JntrStockUtils(_name,_symbol,_systemAddress,_tokenHolderWallet,_whiteListAddress){
                    
                reserveSupply = reserveSupply * 10 ** uint256(decimals);
                holdBackSupply = holdBackSupply * 10 ** uint256(decimals);
        
                if(reserveSupply > 0)
                    _mint(address(this),reserveSupply);
                
                if(holdBackSupply > 0 )
                    _mint(_tokenHolderWallet,holdBackSupply);      
            }
    
    
    
    function checkBeforeTransfer(address _from,address _to) internal view returns(bool){
        if(securityCheck){
            if(WhiteList(whiteListAddress).isAddressByPassed(msg.sender) == false){
                require(WhiteList(whiteListAddress).checkBeforeTransfer(_from,_to),ERR_TRANSFER_CHECK_WHITELIST);
                require(!isTokenMature() && isHoldbackDaysOver(),ERR_ACTION_NOT_ALLOWED);
            }
        }
        return true;
    }
    
    function transfer(address _to, uint256 _value) public returns (bool ok) {
        require(checkBeforeTransfer(msg.sender,_to));
        return super.transfer(_to,_value);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(checkBeforeTransfer(_from,_to));
        return super.transferFrom(_from,_to,_value);
    }
    
    /**
       * @dev TransferFrom tokens from this address to another  
       * we need this function bcz forceswap with other equiatiy and note tokens 
       * @param _spender address The address which you want to transfer to
       * @param _value uint256 the amount of tokens to be transferred
    */
    function allowTrasferFrom(address _spender,uint256 _value) public onlySystem returns (bool){
        allowed[address(this)][_spender] = _value;
        emit Approval(address(this), _spender,_value);
        return true;
    }
    
   function swapForTokens(uint256 _tokenPrice,address _to,uint256 _value) public returns(bool){
        require(msg.sender == jntrAddress || msg.sender == etnAddress,ERR_ACTION_NOT_ALLOWED);
        
        uint256 _assignToken = safeDiv(safeMul(_value,_tokenPrice),tokenPrice);

        if(balances[address(this)] >= _assignToken){
          return _transfer(address(this),_to,_assignToken);
        }else{
            uint256 _remaningToken = safeSub(_assignToken,balances[address(this)]);
            _transfer(address(this),_to,balances[address(this)]);
            return _mint(_to,_remaningToken);
        }
    }
    
    function swapToken(address swapble,uint256 _value) public notZeroValue(_value) notZeroAddress(swapble) returns (bool){
        require(isDirectSwap && (swapble == jntrAddress || swapble == etnAddress));
        require(_burn(msg.sender,_value));
        require(Token(swapble).swapForTokens(tokenPrice,msg.sender,_value));
        return true;
    }
    
    //In case if there is other tokens into contract
    function returnTokens(address _tokenAddress,address _to,uint256 _value) public notThisAddress(_tokenAddress) onlyOwner returns (bool){
        ERC20 tokens = ERC20(_tokenAddress);
        return tokens.transfer(_to,_value);
    }
    
    function forceSwap(address[] memory _from)  public onlySystem returns (bool){
         for(uint temp_x = 0 ; temp_x < _from.length ; temp_x++){
            address _address = _from[temp_x];
            uint256 _value = balances[_address];
            if(_value >= 0){
                require(_burn(_address,balances[_address]));
                require(Token(jntrAddress).swapForTokens(tokenPrice,_address,_value));
            }
         }
         return true;
    }
    
    //in case there is ether in contarct 
    function finaliaze() public onlyOwner returns(bool){
        tokenHolderWallet.transfer(address(this).balance);
    }
    
   
    
    function() external payable{
       revert();
    }
    
}

