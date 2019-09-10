pragma solidity ^0.5.10;

import "./libraries/Ownable.sol";
/**
 * @title ExchangeLogger
 * @author Disberse LTD
 * @notice Contract for logging exchange rates for particular burn events
 * asynchronously
 */
contract ExchangeLogger is Ownable {

    event LogExchange(
        bytes32 indexed burnHash,
        bytes32 indexed dstCurrency,
        uint256 dstValue
    );

    /**
     * @dev Logs data related to an external currency conversion after a redeem
     * @param _burnHash The identifier of the specific burn event correlated
     * with the currency conversion
     * @param _dstCurrency The currency that the funds were converted into
     * @param _dstValue The value of the transferred funds, denominated in dstCurrency
     */
    function logExchange(
        bytes32 _burnHash,
        bytes32 _dstCurrency,
        uint256 _dstValue
    )
        external
        onlyOwner
    {
        emit LogExchange(_burnHash, _dstCurrency, _dstValue);
    }
}
