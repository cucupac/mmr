// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {Math} from "src/libraries/Math.sol";

import "forge-std/console.sol";

contract Mmr {
    // Node definition
    struct Node {
        uint256 height;
        bytes32 hash;
    }

    // Storage
    Node[] public mmr;
    Node[] public mergeQueue;
    uint256[] public peaks;
    uint256 public size;

    function addLeaves(bytes32[] memory leaves) public returns (bool) {
        for (uint256 i; i < leaves.length; i++) {
            // push leaf node and add to merge queue
            bytes32 leafHash = keccak256(abi.encodePacked(leaves[i]));
            Node memory node = Node({height: 0, hash: leafHash});
            mmr.push(node);
            mergeQueue.push(node);

            // check merge queue for potential merges
            _checkMergeQueue();

            // increment size
            size++;
        }

        return true;
    }

    function _checkMergeQueue() internal {
        uint256 n = mergeQueue.length;

        if (n > 1) {
            Node memory leftNode = mergeQueue[n - 2];
            Node memory rightNode = mergeQueue[n - 1];

            while (rightNode.height == leftNode.height) {
                // merge hashes
                bytes32 parentHash = _merge(leftNode.hash, rightNode.hash);

                // remove last 2 from merge queue
                mergeQueue.pop();
                mergeQueue.pop();

                // add parent node to mmr and merge que
                Node memory parent = Node({height: rightNode.height + 1, hash: parentHash});
                mmr.push(parent);
                mergeQueue.push(parent);

                // update: n after removal and additon (n -= 1)
                // update: last 2 nodes after merge
                n = mergeQueue.length;
                if (n > 1) {
                    leftNode = mergeQueue[n - 2];
                    rightNode = mergeQueue[n - 1];
                } else {
                    break;
                }
            }
        }
    }

    function _merge(bytes32 leftHash, bytes32 rightHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(leftHash, rightHash));
    }

    function getMmr() public view returns (Node[] memory) {
        return mmr;
    }

    function getPeaks() public returns (uint256[] memory) {
        // deal with 0 size case
        if (size == 0) {
            return new uint256[](0);
        }

        // initialize to empty array
        peaks = new uint256[](0);

        // get first peak node
        uint256 index = 2 ** (Math._log2(size) + 1) - 1; // 1-indexed
        Node memory node = mmr[index - 1]; // 0 indexed
        peaks.push(index - 1);

        // find other peaks
        uint256 h = node.height; // initialize h to first peak
        while (true) {
            index += (2 ** (h + 1) - 1);

            while (index > mmr.length) {
                // decrement index by 2^h
                index -= (2 ** h);

                // decrement h
                if (h > 0) {
                    h--;
                }
            }

            // we now have an index inside the tree
            // check if it's already been added or not
            bool alreadyAdded = false;
            for (uint256 i; i < peaks.length; i++) {
                if (peaks[i] == index - 1) {
                    alreadyAdded = true;
                }
            }

            // break if you've stumbled upon a peak that's already been added
            if (alreadyAdded) {
                break;
            }

            // a peak was found: add it to array
            peaks.push(index - 1);
        }
        return peaks;
    }

    function getProof(uint256 idx)
        public
        returns (bytes32[] memory merkleProof, bytes32[] memory leftPeaks, bytes32[] memory rightPeaks)
    {
        // 1. get peak indexes

        // 2. get merkle proof for a particular mountain (stop when index is in peaks)

        // 3. get left-hand peaks and right-hand peaks

        // 4. return all: from this, root hash can be constructed
        // - proves membership in mountain
        // - proves mountains membership in full data set
    }
}
