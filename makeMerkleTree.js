import { MerkleTree } from "merkletreejs";
import ethersPkg from "ethers";
const { utils } = ethersPkg;
import fs from "fs";

//hardhat local node addresses from 0 to 3
const address = [
  "0x14cAd55a3FaE4BCcf874397b011a6a18929c108f",
  "0xe6db30dA89E8C6492dA3677fA9B5a7D59124995E"
];

//  Hashing All Leaf Individual
//leaves is an array of hashed addresses (leaves of the Merkle Tree).
const leaves = address.map((leaf) => utils.keccak256(utils.toUtf8Bytes(leaf)));

// Constructing Merkle Tree
const tree = new MerkleTree(leaves, utils.keccak256, {
  sortPairs: true,
});

//  Utility Function to Convert From Buffer to Hex
const bufferToHex = (x) => "0x" + x.toString("hex");

// Get Root of Merkle Tree
console.log(`Here is Root Hash: ${bufferToHex(tree.getRoot())}`);

let data = [];

// Pushing all the proof and leaf in data array
address.forEach((address) => {
  const leaf = utils.keccak256(utils.toUtf8Bytes(address));

  const proof = tree.getProof(leaf);

  let tempData = [];

  proof.map((x) => tempData.push(bufferToHex(x.data)));

  data.push({
    address: address,
    leaf: bufferToHex(leaf),
    proof: tempData,
  });
});

// Create WhiteList Object to write JSON file
let whiteList = {
  whiteList: data,
};

//  Stringify whiteList object and formating
const metadata = JSON.stringify(whiteList, null, 2);

// Write whiteList.json file in root dir
fs.writeFile(`whiteList.json`, metadata, (err) => {
  if (err) {
    throw err;
  }
  console.log("WhiteList.json has been created successfully!");
});
