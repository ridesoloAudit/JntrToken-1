pragma solidity 0.5.9;
import './SafeMath.sol';
import './ERC20.sol';

contract StandardToken is ERC20,SafeMath{
    
    string public name;
    
    string public symbol;
    
    uint public totalSupply = 0 ;
    
    uint public constant decimals = 18;
    
    mapping(address => uint256) balances;
    
    mapping (address => mapping (address => uint256)) allowed;
    
    string constant ERR_BALANCE = "ERR_BALANCE";
    string constant ERR_ADDRESS_NOT_VALID = "ERR_ADDRESS_NOT_VALID";
    string constant ERR_TRANSFER = "ERR_TRANSFER";
    
    event Mint(address indexed _to,uint256 value);
    event Burn(address indexed _from,uint256 value);
  
    /**
      * @dev transfer token for a specified address
      * @param _from The address to transfer from.
      * @param _to The address to transfer to.
      * @param _value The amount to be transferred.
    */
    function _transfer(address _from,address _to, uint _value) internal returns (bool) {
        uint256 senderBalance = balances[_from];
        require(senderBalance >= _value,ERR_BALANCE);
        senderBalance = safeSub(senderBalance, _value);
        balances[_from] = senderBalance;
        balances[_to] = safeAdd(balances[_to],_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    function _burn(address _from,uint _value) internal returns (bool){
        uint256 senderBalance = balances[_from];
        require(senderBalance >= _value,"BALANCE_ERR");
        senderBalance = safeSub(senderBalance, _value);
        balances[_from] = senderBalance;
        totalSupply = safeSub(totalSupply, _value);
        emit Burn(_from,_value);
        emit Transfer(_from, address(0), _value);
        return true;
    }

    function _mint(address _to,uint _value) internal returns(bool){
        balances[_to] = safeAdd(balances[_to],_value);
        totalSupply = safeAdd(totalSupply, _value);
        emit Mint(_to,_value);
        emit Transfer(address(0),_to, _value);
        return true;
    }
    
  
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0),ERR_ADDRESS_NOT_VALID);
        return _transfer(msg.sender,_to,_value);
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _who The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _who) public view returns (uint256 balance) {
        return balances[_who];
    }
    
    // @param _owner The address of the account owning tokens
    // @param _spender The address of the account able to transfer the tokens
    // @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint) {
        return allowed[_owner][_spender];
    }
    
    /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0),ERR_ADDRESS_NOT_VALID);
        require(allowed[_from][msg.sender] >= _value ,ERR_BALANCE);
        bool ok = _transfer(_from,_to,_value);
        require(ok,ERR_TRANSFER);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender],_value);
        return true;
    }
    
    //  `msg.sender` approves `spender` to spend `value` tokens
    // @param spender The address of the account able to transfer the tokens
    // @param value The amount of wei to be approved for transfer
    // @return Whether the approval was successful or not
    function approve(address _spender, uint _value) public returns (bool ok) {
        //validate _spender address
        require(_spender != address(0),ERR_ADDRESS_NOT_VALID);
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

}