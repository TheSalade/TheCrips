// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Script.sol";
import "../src/sm.sol";

contract DeployNFT is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        string memory baseURI = "ipfs://<TON_CID>/";
        string memory notRevealedURI = "ipfs://<TON_CID_NOT_REVEALED>";
        bytes32 merkleRootVIP = bytes32(vm.envBytes32("MERKLE_ROOT_VIP"));
        bytes32 merkleRootPartners = bytes32(vm.envBytes32("MERKLE_ROOT_PARTNERS"));
        bytes32 merkleRootPublic = bytes32(vm.envBytes32("MERKLE_ROOT_PUBLIC"));

        MonsterNFT monsterNFT = new MonsterNFT(
            baseURI,
            notRevealedURI,
            merkleRootVIP,
            merkleRootPartners,
            merkleRootPublic
        );

        console.log("MonsterNFT deployed to:", address(monsterNFT));

        vm.stopBroadcast();
    }
}