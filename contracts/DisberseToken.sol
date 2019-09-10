pragma solidity ^0.5.10;

// Interfaces:
import "./libraries/Ownable.sol";
import "./libraries/SafeMath.sol";

/**
 * @title DisberseToken
 * @author Disberse LTD
 * @notice An ERC20 compatible token contract with one addition:
 * - Provides `bins` to subdivide funds within an address
*/
contract DisberseToken is Ownable {

    using SafeMath for uint256;

    /////
    // Constants:
    /////

    uint8 public constant DECIMALS = 18;

    // The default bin that assumes no specific allocation of tokens. Also used to provide backwards
    // compatibility with ERC-20 tokens.
    bytes32 public constant OP_BIN = bytes32(0);

    /////
    // Storage:
    /////

    uint256 public totalSupply;
    string public name;
    string public symbol;

    // Map: user => bin => amount.
    mapping (address => mapping (bytes32 => uint)) internal _balances;

    // Map: approver => spender => bin => amount.
    mapping (address => mapping (address => mapping (bytes32 => uint))) internal _allowances;

    /////
    // Events:
    /////

    event Transfer(address indexed src, address indexed dst, bytes32 indexed bin, uint256 amt);
    event Approval(address indexed src, address indexed dst, bytes32 indexed bin, uint256 amt);
    event Mint(address indexed src, address indexed dst, bytes32 indexed bin, uint256 amt);
    event Burn(address indexed src, bytes32 indexed bin, uint256 amt);
    event Allocate(address indexed gal, bytes32 indexed src, bytes32 indexed dst, uint256 amt);

    /////
    // Constructor:
    /////

    /**
     * @dev Constructor
     * @param _name Token name.
     * @param _symbol Token symbol.
    */
    constructor(string memory _name, string memory _symbol)
        public
    {
        name = _name;
        symbol = _symbol;
    }

    /////
    // Public functions
    /////

    /**
     * @dev Transfers `_amt` of tokens from `msg.sender`'s `_bin` to `_dst`'s `_bin`.
     * @param _dst The recipient of the tokens.
     * @param _amt The amount of tokens to transfer.
     * @param _bin The bin in which the transfer is executed.
    */
    function transfer(
        address _dst,
        uint _amt,
        bytes32 _bin
    )
        public
        returns (bool)
    {
        return _transfer(msg.sender, _dst, _amt, _bin);
    }

    /**
     * @dev Transfers `_amt` of tokens from msg.sender's OP_BIN to `_dst`'s OP_BIN.
     * @param _dst The recipient of the tokens.
     * @param _amt The amount of tokens to transfer.
    */
    function transfer(
        address _dst,
        uint _amt
    )
        public
        returns (bool)
    {
        return _transfer(msg.sender, _dst, _amt, OP_BIN);
    }

    /**
     * @dev Approves `_gal` to transfer `_amt` of tokens from `msg.sender`'s `_bin`.
     * @param _gal The address that is approved to transfer the tokens.
     * @param _amt The amount of tokens being approved for transfer.
     * @param _bin The bin in which the tokens are approved to be transferred.
    */
    function approve(
        address _gal,
        uint256 _amt,
        bytes32 _bin
    )
        public
        returns (bool)
    {
        return _approve(_gal, _amt, _bin);
    }

    /**
     * @dev Approves `_gal` to transfer `_amt` of tokens from `msg.sender`'s OP_BIN.
     * @param _gal The address that is approved to transfer the tokens
     * @param _amt The amount of tokens being approved for transfer
    */
    function approve(
        address _gal,
        uint _amt
    )
        public
        returns (bool)
    {
        return _approve(_gal, _amt, OP_BIN);
    }

    /**
     * @dev Transfers `amt` tokens from `src`s `bin` to `_dst`'s bin.
     * @param _src The address to transfer tokens from.
     * @param _dst The address to transfer tokens to.
     * @param _amt The amount of tokens to transfer.
     * @param _bin The bin in which the transfer is executed.
    */
    function transferFrom(
        address _src,
        address _dst,
        uint256 _amt,
        bytes32 _bin
    )
        public
        returns (bool)
    {
        return _transferFrom(_src, _dst, _amt, _bin);
    }

    /**
     * @dev Transfers _amt of tokens from _src's OP_BIN to _dst
     * @param _src The address to transfer tokens from
     * @param _dst The address to transfer tokens to
     * @param _amt The amount of tokens to transfer
    */
    function transferFrom(
        address _src,
        address _dst,
        uint256 _amt
    )
        public
        returns (bool)
    {
        return _transferFrom(_src, _dst, _amt, OP_BIN);
    }

    /**
     * @dev Allocates _amt of tokens from _srcBin to _dstBin
     * @param _amt The amount of tokens to allocate
     * @param _srcBin The bin to allocate tokens from
     * @param _dstBin The bin to allocate tokens to
    */
    function allocate(uint _amt, bytes32 _srcBin, bytes32 _dstBin)
        public
        returns (bool)
    {
        return _allocate(msg.sender, _amt, _srcBin, _dstBin);
    }

    /////
    // Public Auth functions
    /////

    /**
     * @dev Generates `_amt` new tokens in `_gal`'s `_bin`.
     * @param _gal Address to mint new tokens to.
     * @param _amt Amount of tokens to mint.
     * @param _bin Bin in which to mint tokens.
    */
    function mint(
        address _gal,
        uint256 _amt,
        bytes32 _bin
    )
        external
        onlyOwner
    {
        _mint(_gal, _amt, _bin);
    }

    /**
     * @dev Generates `_amt` new tokens in `_gal`'s OP_BIN.
     * @param _gal Address to mint new tokens to.
     * @param _amt Amount of tokens to mint.
    */
    function mint(
        address _gal,
        uint256 _amt
    )
        external
        onlyOwner
    {
        _mint(_gal, _amt, OP_BIN);
    }

    /**
     * @dev Destroys `_amt` tokens in `_gal`'s `_bin`.
     * @param _gal Addres to burn tokens from.
    * @param _amt Amount of tokens to burn.
    * @param _bin Bin to burn tokens from.
    */
    function burn(
        address _gal,
        uint256 _amt,
        bytes32 _bin
    )
        external
        onlyOwner
    {
        _burn(_gal, _amt, _bin);
    }

    /**
     * @dev Removes `_amt` of tokens from `_gal`'s OP_BIN.
     * @param _gal Addres to burn tokens from.
     * @param _amt Amount of tokens to burn.
    */
    function burn(
        address _gal,
        uint256 _amt
    )
        external
        onlyOwner
    {
        _burn(_gal, _amt, OP_BIN);
    }

    /////
    // Public view functions:
    /////

    /**
     * @dev Queries the balance of tokens in `_gal`'s `_bin`.
     * @param _gal The address to query the balance of.
     * @param _bin The bin in which to query the balance.
     * @return The balance of the requested address's `_bin`.
    */
    function balanceOf(
        address _gal,
        bytes32 _bin
    )
        public
        view
        returns (uint256)
    {
        return _balances[_gal][_bin];
    }

    /**
     * @dev Queries the balance of tokens in `_gal`'s OP_BIN.
     * @param _gal The address to query the balance of.
     * @return The balance of the requested address's OP_BIN.
    */
    function balanceOf(address _gal)
        public
        view
        returns (uint256)
    {
        return balanceOf(_gal, OP_BIN);
    }

    /**
     * @dev Queries the amount of tokens that `_dst` is currently allowed to transfer from `_src`'s
     * `_bin`.
     * @param _src The address that holds the tokens.
     * @param _dst The address that is allowed to transfer the tokens.
     * @param _bin The bin in which the tokens are held.
     * @return The amount of tokens that `_dst` can transfer from `_src`'s `_bin`.
    */
    function allowance(
        address _src,
        address _dst,
        bytes32 _bin
    )
        public
        view
        returns (uint256)
    {
        return _allowances[_src][_dst][_bin];
    }

    /**
     * @dev Queries the amount of tokens that `_dst` is currently allowed to transfer from `_src`'s
     * OP_BIN.
     * @param _src The address that holds the tokens.
     * @param _dst The address that is allowed to transfer the tokens.
     * @return The amount of tokens that _dst can transfer from _src's OP_BIN.
    */
    function allowance(
        address _src,
        address _dst
    )
        public
        view
        returns (uint256)
    {
        return allowance(_src, _dst, OP_BIN);
    }

    /////
    // Internal functions:
    /////

    /**
     * @dev Generates `_amt` of new tokens in `_gal`'s `_bin`.
     * @param _gal Address to mint tokens to
     * @param _amt Amount of tokens to mint
     * @param _bin Bin to mint tokens to
    */
    function _mint(
        address _gal,
        uint256 _amt,
        bytes32 _bin
    )
        internal
    {
        _balances[_gal][_bin] = _balances[_gal][_bin].add(_amt);
        totalSupply = totalSupply.add(_amt);
        emit Mint(msg.sender, _gal, _bin, _amt);
    }

    /**
     * @dev Removes `_amt` of tokens from `_gal`'s `_bin`.
     * @param _gal Addres to burn tokens from
     * @param _amt Amount of tokens to burn
     * @param _bin Bin to burn tokens from
    */
    function _burn(
        address _gal,
        uint256 _amt,
        bytes32 _bin
    )
        internal
    {
        _balances[_gal][_bin] = _balances[_gal][_bin].sub(_amt);
        totalSupply = totalSupply.sub(_amt);
        emit Burn(_gal, _bin, _amt);
    }

    /**
     * @dev Transfers `_amt` of tokens from `_src`'s _bin to `_dst`.
     * @param _src The address to transfer tokens from.
     * @param _dst The address to transfer tokens to.
     * @param _amt The amount of tokens to transfer.
     * @param _bin The bin in which the transfer is executed.
    */
    function _transferFrom(
        address _src,
        address _dst,
        uint256 _amt,
        bytes32 _bin
    )
        internal
        returns (bool)
    {
        _allowances[_src][_dst][_bin] = _allowances[_src][_dst][_bin].sub(_amt);
        return _transfer(_src, _dst, _amt, _bin);
    }

    /**
     * @dev Approves `_gal` to transfer `_amt` of tokens from msg.sender's `_bin`.
     * @param _gal The address that is approved to transfer the tokens.
     * @param _amt The amount of tokens being approved for transfer.
     * @param _bin The bin in which the transfer will be executed.
    */
    function _approve(
        address _gal,
        uint256 _amt,
        bytes32 _bin
    )
        internal
        returns (bool)
    {
        _allowances[msg.sender][_gal][_bin] = _amt;
        emit Approval(msg.sender, _gal, _bin, _amt);
        return true;
    }

    /**
     * @dev Allocates `_amt` of tokens from `_srcBin` to `_dstBin`.
     * @param _amt The amount of tokens to allocate.
     * @param _srcBin The bin to allocate tokens from.
     * @param _dstBin The bin to allocate tokens to,
    */
    function _allocate(
        address _gal,
        uint256 _amt,
        bytes32 _srcBin,
        bytes32 _dstBin
    )
        internal
        returns (bool)
    {
        // Also check that balance > amt to transfer via underflow check.
        _balances[_gal][_srcBin] = _balances[_gal][_srcBin].sub(_amt);
        _balances[_gal][_dstBin] = _balances[_gal][_dstBin].add(_amt);

        emit Allocate(_gal, _srcBin, _dstBin, _amt);
        return true;
    }

    /**
     * @dev Transfers `_amt` of tokens from msg.sender's `_bin` to `_dst`'s `_bin`.
     * @param _dst The recipient of the tokens.
     * @param _amt The amount of tokens to transfer.
     * @param _bin The bin in which the transfer is executed.
    */
    function _transfer(
        address _src,
        address _dst,
        uint256 _amt,
        bytes32 _bin
    )
        internal
        returns (bool)
    {
        // Also check that balance > amt to transfer via underflow check.
        _balances[_src][_bin] = _balances[_src][_bin].sub(_amt);
        _balances[_dst][_bin] = _balances[_dst][_bin].add(_amt);

        emit Transfer(_src, _dst, _bin, _amt);
        return true;
    }

}
