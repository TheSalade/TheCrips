// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Script.sol";
import "../src/sm.sol";
import "@storyprotocol/core/interfaces/registries/IIPAssetRegistry.sol";

contract MintAndRegister is Script {
    IIPAssetRegistry internal IP_ASSET_REGISTRY = IIPAssetRegistry(0x77319B4031e6eF1250907aa00018B8B1c67a244b);

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address contractAddress = 0xe9e2E9f81Cde64D3e9F6B82FA5d387b390f1AAEa;
        ContractName contractName = ContractName(contractAddress);

        contractName.setUpPresale();

        bytes32[] memory vipProof = new bytes32[](1);
        vipProof[0] = bytes32(0xd8cc45e791c50ade5ca76d1845ce9e00cfbc01600d3da0d8427f4701b24dd09b);
        // Ajoute plus de proofs si nécessaire
        address account = 0x14cAd55a3FaE4BCcf874397b011a6a18929c108f;

        contractName.presaleMintVIP{value: 0.0002 ether}(account, vipProof);

        uint256 tokenId = contractName.totalSupply();

        address ipId = IP_ASSET_REGISTRY.register(block.chainid, contractAddress, tokenId);

        console.log("NFT minted with tokenId:", tokenId);
        console.log("IP Asset registered with ipId:", ipId);

        vm.stopBroadcast();
    }
}