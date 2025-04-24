// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ContractName is ERC721, Ownable, IERC2981 {
    using Strings for uint256;

    // Merkle Roots pour les trois whitelists
    bytes32 public merkleRootVIP;
    bytes32 public merkleRootPartners;
    bytes32 public merkleRootPublic;

    // Paramètres de minting
    uint256 public constant MAX_SUPPLY = 7777;
    uint256 public maxMintAllowedVIP = 3;
    uint256 public maxMintAllowedPartners = 2;
    uint256 public maxMintAllowedPublic = 1;
    uint256 public pricePresaleVIP = 0.0002 ether;
    uint256 public pricePresalePartners = 0.00025 ether;
    uint256 public pricePresalePublic = 0.0003 ether;
    uint256 public priceSale = 0.0003 ether;

    // Metadata
    string public baseURI;
    string public notRevealedURI;
    string public baseExtension = ".json";
    bool public revealed = false;
    bool public paused = false;

    // Royalties
    uint256 public royaltyPercentage = 500; // 5%
    address public royaltyReceiver;

    // Phases de vente
    enum Steps {
        Before,
        Presale,
        Sale,
        SoldOut,
        Reveal
    }
    Steps public sellingStep;

    // Suivi des mints par wallet
    mapping(address => uint256) public nftsPerWalletVIP;
    mapping(address => uint256) public nftsPerWalletPartners;
    mapping(address => uint256) public nftsPerWalletPublic;

    // Compteur pour les token IDs
    uint256 private _tokenIdCounter = 1;

    constructor(
        string memory _theBaseURI,
        string memory _notRevealedURI,
        bytes32 _merkleRootVIP,
        bytes32 _merkleRootPartners,
        bytes32 _merkleRootPublic
    ) ERC721("CollectName", "CollectTicker") Ownable() {
        baseURI = _theBaseURI;
        notRevealedURI = _notRevealedURI;
        merkleRootVIP = _merkleRootVIP;
        merkleRootPartners = _merkleRootPartners;
        merkleRootPublic = _merkleRootPublic;
        royaltyReceiver = msg.sender;
        sellingStep = Steps.Before;
    }

    // Fonctions de configuration (owner seulement)
    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }

    function setBaseUri(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    function setNotRevealURI(string memory _notRevealedURI) external onlyOwner {
        notRevealedURI = _notRevealedURI;
    }

    function reveal() external onlyOwner {
        revealed = true;
    }

    function setUpPresale() external onlyOwner {
        sellingStep = Steps.Presale;
    }

    function setUpSale() external onlyOwner {
        require(sellingStep == Steps.Presale, "Presale must be active");
        sellingStep = Steps.Sale;
    }

    // Fonctions de minting
    function presaleMintVIP(address _account, bytes32[] calldata _proof) external payable {
        require(sellingStep == Steps.Presale, "Presale not active");
        require(!paused, "Contract paused");
        require(nftsPerWalletVIP[_account] < maxMintAllowedVIP, "Max mint reached for VIP");
        require(isWhitelistedVIP(_account, _proof), "Not in VIP whitelist");
        require(msg.value >= pricePresaleVIP, "Insufficient funds");
        require(_tokenIdCounter <= MAX_SUPPLY, "Max supply reached");

        nftsPerWalletVIP[_account]++;
        _safeMint(_account, _tokenIdCounter);
        _tokenIdCounter++;
    }

    function presaleMintPartners(address _account, bytes32[] calldata _proof) external payable {
        require(sellingStep == Steps.Presale, "Presale not active");
        require(!paused, "Contract paused");
        require(nftsPerWalletPartners[_account] < maxMintAllowedPartners, "Max mint reached for Partners");
        require(isWhitelistedPartners(_account, _proof), "Not in Partners whitelist");
        require(msg.value >= pricePresalePartners, "Insufficient funds");
        require(_tokenIdCounter <= MAX_SUPPLY, "Max supply reached");

        nftsPerWalletPartners[_account]++;
        _safeMint(_account, _tokenIdCounter);
        _tokenIdCounter++;
    }

    function presaleMintPublic(address _account, bytes32[] calldata _proof) external payable {
        require(sellingStep == Steps.Presale, "Presale not active");
        require(!paused, "Contract paused");
        require(nftsPerWalletPublic[_account] < maxMintAllowedPublic, "Max mint reached for Public");
        require(isWhitelistedPublic(_account, _proof), "Not in Public whitelist");
        require(msg.value >= pricePresalePublic, "Insufficient funds");
        require(_tokenIdCounter <= MAX_SUPPLY, "Max supply reached");

        nftsPerWalletPublic[_account]++;
        _safeMint(_account, _tokenIdCounter);
        _tokenIdCounter++;
    }

    function saleMint(uint256 _amount) external payable {
        require(sellingStep == Steps.Sale, "Sale not active");
        require(!paused, "Contract paused");
        require(_amount <= maxMintAllowedPublic, "Cannot mint more than allowed");
        require(msg.value >= priceSale * _amount, "Insufficient funds");
        require(_tokenIdCounter + _amount - 1 <= MAX_SUPPLY, "Max supply reached");

        nftsPerWalletPublic[msg.sender] += _amount;
        for (uint256 i = 0; i < _amount; i++) {
            _safeMint(msg.sender, _tokenIdCounter);
            _tokenIdCounter++;
        }
        if (_tokenIdCounter > MAX_SUPPLY) {
            sellingStep = Steps.SoldOut;
        }
    }

    function gift(address _account) external onlyOwner {
        require(_tokenIdCounter <= MAX_SUPPLY, "Max supply reached");
        _safeMint(_account, _tokenIdCounter);
        _tokenIdCounter++;
    }

    // Vérification des whitelists
    function isWhitelistedVIP(address account, bytes32[] calldata proof) internal view returns (bool) {
        return MerkleProof.verify(proof, merkleRootVIP, keccak256(abi.encodePacked(account)));
    }

    function isWhitelistedPartners(address account, bytes32[] calldata proof) internal view returns (bool) {
        return MerkleProof.verify(proof, merkleRootPartners, keccak256(abi.encodePacked(account)));
    }

    function isWhitelistedPublic(address account, bytes32[] calldata proof) internal view returns (bool) {
        return MerkleProof.verify(proof, merkleRootPublic, keccak256(abi.encodePacked(account)));
    }

    // Royalties ERC-2981
    function royaltyInfo(uint256, uint256 _salePrice) external view override returns (address receiver, uint256 royaltyAmount) {
        return (royaltyReceiver, (_salePrice * royaltyPercentage) / 10000);
    }

    function setRoyaltyPercentage(uint256 _percentage) external onlyOwner {
        royaltyPercentage = _percentage;
    }

    // Metadata
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        // Vérifie si le token existe en utilisant ownerOf
        require(ownerOf(_tokenId) != address(0), "Token does not exist");
        if (!revealed) {
            return notRevealedURI;
        }
        return string(abi.encodePacked(baseURI, _tokenId.toString(), baseExtension));
    }

    // Fonction pour récupérer le totalSupply
    function totalSupply() external view returns (uint256) {
        return _tokenIdCounter - 1;
    }
}