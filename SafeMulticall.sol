pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";

contract SafeMulticall is Ownable {
    mapping(address => bool) internal authorizedCallers;

    modifier onlyAuthorized() {
        require(authorizedCallers[msg.sender], "SafeMulticall: caller is not authorized");
        _;
    }

    function setCaller(address caller, bool isAuthorized) external onlyOwner {
        authorizedCallers[caller] = isAuthorized;
    }

    function executeCalls(address[] calldata _targetContracts, bytes[] calldata _calldataBytes) external payable onlyAuthorized {
        require(_targetContracts.length == _calldataBytes.length, "SafeMulticall: invalid input");
        uint256 numCalls = _targetContracts.length;
        for (uint256 i = 0; i < numCalls; i++) {
            (bool success,) = _targetContracts[i].call(_calldataBytes[i]);
            require(success, "SafeMulticall: call failed");
        }
    }
}
