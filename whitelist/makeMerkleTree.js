import { MerkleTree } from "merkletreejs";
import { keccak256 } from "ethers";
import fs from "fs";

const OGAddresses = [
  "0x14cAd55a3FaE4BCcf874397b011a6a18929c108f",
  "0xe6db30dA89E8C6492dA3677fA9B5a7D59124995E"
];
const GTDAddresses = [
  "0x5d2614e0630aa8a556d16bce96e78eaf08098021",
  "0x7dfb98ac2167b16f667ad8ee3730cff849016a0f"
];
const FCFSAddresses = [
  "0x3a2D49d9282227a653c1A92b13E9742ad65Bba54",
  "0x659c1E1D008b174CcE2Cf22632aaB1add333Dc50"
];

// Fonction pour convertir un buffer ou une chaîne hexadécimale en hexadécimal avec un seul "0x"
function toHex(value) {
  // Si c'est déjà une chaîne commençant par "0x", retirer le "0x" et reformater
  if (typeof value === "string" && value.startsWith("0x")) {
    return "0x" + value.slice(2);
  }
  // Si c'est un Buffer, convertir en hexadécimal
  return "0x" + value.toString("hex");
}

function generateMerkleData(addresses, outputFile) {
  // Générer les feuilles en hachant directement l'adresse
  const leaves = addresses.map((address) => keccak256(address));
  const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });
  const root = toHex(tree.getRoot());
  console.log(`Merkle Root for ${outputFile}: ${root}`);

  let data = [];
  addresses.forEach((address) => {
    const leaf = keccak256(address); // Déjà une chaîne hexadécimale avec "0x"
    const proof = tree.getProof(leaf);
    let tempData = [];
    proof.map((x) => tempData.push(toHex(x.data))); // Appliquer toHex aux proofs
    data.push({
      address: address,
      leaf: toHex(leaf), // Appliquer toHex pour uniformiser
      proof: tempData,
    });
  });

  let whiteList = {
    merkleRoot: root,
    whiteList: data,
  };

  const metadata = JSON.stringify(whiteList, null, 2);
  fs.writeFile(outputFile, metadata, (err) => {
    if (err) {
      throw err;
    }
    console.log(`${outputFile} has been created successfully!`);
  });
}

generateMerkleData(OGAddresses, "./whitelist/OGWhiteList.json");
generateMerkleData(GTDAddresses, "./whitelist/GTDWhiteList.json");
generateMerkleData(FCFSAddresses, "./whitelist/FCFSWhiteList.json");