// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Script.sol";
import "../src/sm.sol";

contract DeployContractName is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        string memory baseURI = "ipfs://CID/";
        string memory notRevealedURI = "ipfs://CID";
        bytes32 merkleRootVIP = bytes32(vm.envBytes32("MERKLE_ROOT_VIP"));
        bytes32 merkleRootPartners = bytes32(vm.envBytes32("MERKLE_ROOT_PARTNERS"));
        bytes32 merkleRootPublic = bytes32(vm.envBytes32("MERKLE_ROOT_PUBLIC"));

        ContractName contractName = new ContractName(
            baseURI,
            notRevealedURI,
            merkleRootVIP,
            merkleRootPartners,
            merkleRootPublic
        );

        console.log("ContractName deployed to:", address(contractName));

        vm.stopBroadcast();
    }
}