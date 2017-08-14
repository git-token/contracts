pragma solidity ^0.4.11;

/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function sum(uint[] _values) internal constant returns (uint) {
        assert(_values.length > 0);
        uint s = 0;
        for (uint i = 0; i < _values.length; i++) {
            s = add(s, _values[i]);
        }
        assert(s > 0);
        return s;
   }

  function wtdAvg(uint[] _weights, uint[] _values) internal constant returns (uint) {

     assert(_values.length > 0);
     assert(_weights.length > 0);

     uint s = sum(_weights);
     uint m = 0;

     for (uint i = 0; i < _values.length; i++) {
          uint w = _weights[i];
          uint x = _values[i];
          m = add(m, div(mul(w, x), s));
      }

      assert(m > 0);
      return m;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}
