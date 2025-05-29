# TheCrips NFT Collection - Story Protocol
![image](https://github.com/user-attachments/assets/0ecca8c5-23ec-4268-9330-829fb49ab0eb)

## Overview
**TheCrips** is a high-quality 3D NFT project deployed on the **Story Protocol blockchain**. This collection features **999 unique NFTs**, each registered as an **Intellectual Property (IP) asset**. Every NFT includes a **Profile Picture (PFP)** and a **video loop**, showcasing crocodiles with over **200 unique traits**.

This repository contains the **ERC721 smart contract** powering the TheCrips collection, enabling secure minting, ownership, and transfer of these IP assets on the Story Protocol blockchain.

## Features
- **Collection Size**: 999 unique NFTs
- **NFT Content**: Each NFT includes a 3D crocodile PFP and a video loop
- **Traits**: Over 200 distinct traits for customization and uniqueness
- **Blockchain**: Deployed on Story Protocol, leveraging its IP-focused infrastructure
- **Standard**: ERC721-compliant smart contract for secure and standardized NFT management

## Smart Contract Details
The smart contract is built using the **ERC721 standard**, ensuring compatibility with major NFT marketplaces and wallets. It includes the following key functionalities:
- Minting of TheCrips NFTs
- IP registration on Story Protocol
- Metadata management for PFP and video loop assets
- Transfer and ownership tracking

## Contract Address

The smart contract is deployed at:
[0x2B553ebe0e0bDD914EDa8BFfa22B140552191Fe6](https://www.storyscan.io/address/0x2B553ebe0e0bDD914EDa8BFfa22B140552191Fe6?tab=contract)

## Marketplaces
Explore and trade TheCrips NFTs on the following platforms:
- OKX Marketplace: https://web3.okx.com/fr/nft/collection/story/the-crips-1
- Colormp: https://www.colormp.com/collections/0x2B553ebe0e0bDD914EDa8BFfa22B140552191Fe6/items

## Getting Started
### Prerequisites
- [Node.js](https://nodejs.org/) (for local development and testing)
- [Foundry](https://getfoundry.sh/) (for smart contract development and deployment)

Check version :
```bash
  node --version
  npm --version
  forge --version
  git --version
```
### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/thecrips-nft.git
   cd thecrips-nft
   ```
2. Install Foundry (if not already installed)
  ```bash
  curl -L https://foundry.paradigm.xyz | bash
  source ~/.bashrc 
  foundryup
  ```
3. Verify package.json exist
  ```bash
  ls package.json
  ```
If not
  ```bash
  npm init -y
  ```
4. Install dependencies (e.g., OpenZeppelin contracts)
  ```bash
  forge install
  ```
5. Configure environment variables:
  Create a .env file based on .env.example
  Add your Story Protocol network details (RPC URL, chain ID) and private key

  ```bash
    PRIVATE_KEY=
    PINATA_JWT=
    MERKLE_ROOT_OG=
    MERKLE_ROOT_GTD=
    MERKLE_ROOT_FCFS=
    RPC=https://mainnet.storyrpc.io/
    CID=
    NFT_CONTRACT_ADDRESS=
  ```
6. Compile the smart contract:
  ```bash
  forge build
  ```
7. Load .env variables
  ```bash
  source .env
  ```
7. Deploy to Story Protocol
  ```bash
  forge script script/DeployNFT.s.sol --rpc-url $RPC --private-key $PRIVATE_KEY --broadcast
  ```
8. Verify contract

Testnet
  ```bash
  forge verify-contract \
  --verifier blockscout \
  --verifier-url 'https://aeneid.storyscan.io/api/' \
  --constructor-args $(cast abi-encode "constructor(string,string,bytes32,bytes32,bytes32)" "ipfs://test/" "ipfs://test-not-revealed/" $MERKLE_ROOT_OG $MERKLE_ROOT_GTD $MERKLE_ROOT_FCFS) \
  $NFT_CONTRACT_ADDRESS \
  src/sm.sol:ContractName \
  --rpc-url https://aeneid.storyrpc.io/
  ```
Mainnet
  ```bash
  forge verify-contract \
    --rpc-url https://homer.storyrpc.io \
    --verifier blockscout \
    --verifier-url 'https://www.storyscan.io/api/' \
    $NFT_CONTRACT_ADDRESS\
    src/sm.sol:ContractName
  ```
9. Mint and register as IP Asset
  ```bash
  forge script script/MintAndRegister.s.sol   --rpc-url https://aeneid.storyrpc.io/   --private-key $PRIVATE_KEY   --broadcast
  ```
In case of issue
  ```bash
  forge clean
  rm -rf forge-cache
  rm -rf out
  ```

   
