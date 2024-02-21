// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

library Math {
    function _log2(uint256 size) internal pure returns (uint256) {
        uint256 result;
        while (size > 1) {
            size /= 2;
            result++;
        }
        return result;
    }
}
