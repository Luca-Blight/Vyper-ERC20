# @version ^0.3.3

from vyper.interfaces import ERC20

implements: ERC20

NAME: constant(String[10]) = "blockies"
 
DECIMALS: constant(uint256) = 18

event Transfer:
    _from: indexed(address)
    _to: indexed(address)
    _value: uint256
    
event Approval:
    _owner: indexed(address)
    _spender: indexed(address) #delegrated spender on behalf of owner
    _value: uint256

_totalSupply: uint256
_balances: HashMap[address,uint256]
_allowances: HashMap[address, HashMap[address,uint256]] 
_minted: bool
_minter: address


@external
def __init__():
    self._minter = msg.sender
    self._minted = False  


@external
@view
def balanceOf(_address: address) -> uint256:
    return self._balances[_address]

@external
@view
def name() -> String[10]:
    return NAME

@external
@view
def totalSupply() -> uint256:
    return self._totalSupply 

@external
@view
def allowance(_owner: address, _spender: address) -> uint256:
    return self._allowances[_owner][_spender]
    #checks state of allowances

@external
@view
def decimals() -> uint256:
    return DECIMALS


@internal
def _transfer(_from: address, _to: address, _amount: uint256):
    assert self._balances[_from] >= _amount, "The balance is not enough"
    assert _from != ZERO_ADDRESS
    assert _to != ZERO_ADDRESS
    self._balances[_from] -= _amount
    self._balances[_to] += _amount
    log Transfer(_from, _to, _amount)


@internal
def _approve(_owner: address, _spender: address, _amount: uint256):
    assert _owner != ZERO_ADDRESS
    assert _spender != ZERO_ADDRESS
    self._allowances[_owner][_spender] = _amount
    log Approval(_owner, _spender, _amount)

@external
def mint(_to: address, _tSupply: uint256) -> bool:
    assert msg.sender == self._minter, 'only owner can mint and only once'
    assert self._minted == False, 'This token has already been minted'
    self._totalSupply = 10 ** (_tSupply + DECIMALS)
    self._balances[_to] = self._totalSupply
    self._minted = True
    log Transfer(ZERO_ADDRESS, _to, self._totalSupply)
    return True



@external
def approve(_spender: address, _amount_increased: uint256) -> bool:
    self._approve(msg.sender, _spender, self._allowances[msg.sender][_spender] + _amount_increased)
    return True

@external
def increaseAllowance(_spender: address, _amount_increased: uint256) -> bool:
    self._approve(msg.sender, _spender, self._allowances[msg.sender][_spender] + _amount_increased)
    return True

@external
def decreaseAllowance(_spender: address, _amount_decreased: uint256) -> bool:
    assert self._allowances[msg.sender][_spender] >= _amount_decreased, "negative allowance not allowed"
    self._approve(msg.sender, _spender, self._allowances[msg.sender][_spender] - _amount_decreased)
    return True


@external
def transfer(_to: address, _amount: uint256) -> bool:
    self._transfer(msg.sender, _to ,_amount)
    return True



@external
def transferFrom(_owner:address, _to: address, _amount: uint256) -> bool:
    assert self._allowances[_owner][msg.sender] >= _amount, "the allowance is not enough for this operation" #also ensures, by the values existence that the owner gave approval
    assert self._balances[_owner] >= _amount, "the balance is not enough for this operation"
    self._balances[_owner] -= _amount
    self._balances[_to] += _amount
    self._allowances[_owner][msg.sender] -= _amount
    return True







