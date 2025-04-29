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

        address contractAddress = 0x56F0EF87bC332D1211fd9a2110d06981c985863e;
        ContractName contractName = ContractName(contractAddress);

        contractName.setUpOG();

        bytes32[] memory vipProof = new bytes32[](1);
        vipProof[0] = bytes32(0x51b8ecf1b1fc7312cc2d62d26180fd98c23ffe3b30aff43c64a61951231bb787);
        // Ajoute plus de proofs si nécessaire
        address account = 0x14cAd55a3FaE4BCcf874397b011a6a18929c108f;

        contractName.presaleMintOG{value: 0.00002 ether}(account, vipProof);
        contractName.presaleMintOG{value: 0.00002 ether}(account, vipProof);
        contractName.presaleMintOG{value: 0.00002 ether}(account, vipProof);
        contractName.presaleMintOG{value: 0.00002 ether}(account, vipProof);
        contractName.presaleMintOG{value: 0.00002 ether}(account, vipProof);

        uint256 tokenId = contractName.totalSupply();

        address ipId = IP_ASSET_REGISTRY.register(block.chainid, contractAddress, tokenId);
        address ipId = IP_ASSET_REGISTRY.register(block.chainid, contractAddress, tokenId);
        address ipId = IP_ASSET_REGISTRY.register(block.chainid, contractAddress, tokenId);
        address ipId = IP_ASSET_REGISTRY.register(block.chainid, contractAddress, tokenId);

        console.log("NFT minted with tokenId:", tokenId);
        console.log("IP Asset registered with ipId:", ipId);

        vm.stopBroadcast();
    }
}