// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Script.sol";
import "../src/sm2.sol"; 

contract DeployContractName is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        string memory cid = vm.envString("CID");
        string memory baseURI = string(abi.encodePacked("ipfs://", cid, "/"));
        bytes32 merkleRootOG = bytes32(vm.envBytes32("MERKLE_ROOT_OG"));
        bytes32 merkleRootGTD = bytes32(vm.envBytes32("MERKLE_ROOT_GTD"));
        bytes32 merkleRootFCFS = bytes32(vm.envBytes32("MERKLE_ROOT_FCFS"));

        ContractName contractName = new ContractName(
            baseURI,
            merkleRootOG,
            merkleRootGTD,
            merkleRootFCFS
        );

        console.log("ContractName deployed to:", address(contractName));

        vm.stopBroadcast();
    }
}