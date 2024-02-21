// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {Test, console2} from "forge-std/Test.sol";
import {Mmr} from "../src/Mmr.sol";
import {Math} from "src/libraries/Math.sol";

contract MmrTest is Test {
    Mmr public mmr;

    function setUp() public {
        mmr = new Mmr();
    }

    /// @dev generates and returns an arbitrary bytes32 array of length 8.
    function _getBytesArray(uint256 size) internal pure returns (bytes32[] memory) {
        bytes32[] memory bytesArray = new bytes32[](size);

        for (uint256 i = 0; i < bytesArray.length; i++) {
            bytesArray[i] = bytes32(i + 1);
        }

        return bytesArray;
    }

    function test_AddLeavesSingle() public {
        // setup:
        bytes32[] memory bytesArray = _getBytesArray(8);

        // expectations
        uint256 size = bytesArray.length;
        uint256 log2OfSize = Math._log2(size);
        uint256 expectedTreeHeight = log2OfSize;
        uint256 expectedPeakIndex = 2 ** (expectedTreeHeight + 1) - 1;

        // act: call 8 times
        for (uint256 i = 0; i < bytesArray.length; i++) {
            bytes32[] memory singleValueArray = new bytes32[](1);
            singleValueArray[0] = bytesArray[i];
            mmr.addLeaves(singleValueArray);
        }

        // results:
        Mmr.Node[] memory mmrResult = mmr.getMmr();
        uint256 sizeResult = mmr.size();

        // process:
        Mmr.Node memory peakNode;
        uint256 peakNodeIndex;
        for (uint256 i; i < mmrResult.length; i++) {
            if (mmrResult[i].height > peakNode.height) {
                peakNode = mmrResult[i];
                peakNodeIndex = i + 1;
            }
        }

        // assertions:
        assertEq(expectedTreeHeight, peakNode.height);
        assertEq(expectedPeakIndex, peakNodeIndex);
        assertEq(sizeResult, bytesArray.length);
    }

    function test_AddLeavesBatch() public {
        // setup:
        bytes32[] memory bytesArray = _getBytesArray(8);

        // expectations
        uint256 size = bytesArray.length;
        uint256 log2OfSize = Math._log2(size);
        uint256 expectedTreeHeight = log2OfSize;
        uint256 expectedPeakIndex = 2 ** (expectedTreeHeight + 1) - 1;

        // act: call once with batch
        mmr.addLeaves(bytesArray);

        // results:
        Mmr.Node[] memory mmrResult = mmr.getMmr();
        uint256 sizeResult = mmr.size();

        // process:
        Mmr.Node memory peakNode;
        uint256 peakNodeIndex;
        for (uint256 i; i < mmrResult.length; i++) {
            if (mmrResult[i].height > peakNode.height) {
                peakNode = mmrResult[i];
                peakNodeIndex = i + 1;
            }
        }

        // assertions:
        assertEq(expectedTreeHeight, peakNode.height);
        assertEq(expectedPeakIndex, peakNodeIndex);
        assertEq(sizeResult, bytesArray.length);
    }

    function test_GetPeaks() public {
        // setup: build tree
        bytes32[] memory bytesArray = _getBytesArray(11);
        mmr.addLeaves(bytesArray);

        // expectation:
        uint256[] memory expectedPeaks = new uint256[](3);
        expectedPeaks[0] = 14;
        expectedPeaks[1] = 17;
        expectedPeaks[2] = 18;

        // act: get peaks
        uint256[] memory peakIndexes = mmr.getPeaks();

        // assertions:
        for (uint256 i; i < peakIndexes.length; i++) {
            assertEq(peakIndexes[i], expectedPeaks[i]);
        }
    }
}
