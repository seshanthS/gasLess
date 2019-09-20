contract gasLessVariables:
    def getTokenAddress(_token: uint256) -> address: constant
    
contract ERC20Contract:
    def balanceOf(_from: address) -> uint256: constant
    
GASLESSVARIABLES_CONTRACT_ADDRESS: address    

owners: map(address,bool)
nonce: uint256

@public
def __init__(_owner: address, _gasLessVariables: address):
    self.owners[_owner] = True
    self.GASLESSVARIABLES_CONTRACT_ADDRESS  = _gasLessVariables

@private
def _payRelayer(_tokenToPay: uint256, _amount: uint256) -> bool:
    feeTokenAddress: address = gasLessVariables(self.GASLESSVARIABLES_CONTRACT_ADDRESS).getTokenAddress(_tokenToPay)
    tokenBalance: uint256 = ERC20Contract(feeTokenAddress).balanceOf(self)
    assert(tokenBalance > _amount)
    return True

@private
def payRelayer(_data: bytes[500], _gas: uint256) -> bool:
    raw_call(self, _data, outsize=32, gas=_gas)
    return True

@public
def exec(_to :address, _value: uint256, _data: bytes[500], _gasLimit: uint256, _nonce: uint256, _signature: bytes32, _curvePoints: uint256[3])-> bool:
    assert self.nonce == _nonce
    _sender: address = ecrecover(_signature, _curvePoints[0], _curvePoints[1], _curvePoints[2] ) # v, r,s
    assert self.owners[_sender] == True
    self.nonce = self.nonce + 1
    if len(_data) == 0:
        self.payRelayer(_data, _gasLimit)
    else:
        send(_to, _value)
    return True
    
@public
def getNonce()-> uint256:
    return self.nonce
    
    
