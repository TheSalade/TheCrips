// SPDX-License-Identifier: MIT
// Powered by The Bakery DAO
// Developed by @TRTtheSalad
// https://github.com/TRTtheSalad

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TheCripsNFTCollection is ERC721, Ownable, IERC2981 {
    using Strings for uint256;

    bytes32 public merkleRootOG;
    bytes32 public merkleRootGTD;
    bytes32 public merkleRootFCFS;

    uint256 public MAX_SUPPLY = 3333;
    uint256 public maxMintAllowedOG = 2;
    uint256 public maxMintAllowedGTD = 2;
    uint256 public maxMintAllowedFCFS = 2;
    uint256 public pricePresaleOG = 11 ether; 
    uint256 public pricePresaleGTD = 22 ether;
    uint256 public pricePresaleFCFS = 22 ether;
    uint256 public pricePublic = 22 ether;

    string public baseURI;
    string public baseExtension = ".json";
    bool public paused = false;

    uint256 public royaltyPercentage = 500; // 5%
    address public royaltyReceiver;

    address public paymentReceiver;

    event FundsTransferred(address indexed receiver, uint256 amount);
    event MaxSupplyUpdated(uint256 oldMaxSupply, uint256 newMaxSupply);

    enum Steps {
        Before,
        OG,
        GTD,
        FCFS,
        Public,
        SoldOut
    }
    Steps public sellingStep;

    mapping(address => uint256) public nftsPerWallet;
    mapping(address => uint256) public nftsPerWalletGTD;
    mapping(address => uint256) public nftsPerWalletOG;
    mapping(address => uint256) public nftsPerWalletWL;
    mapping(address => uint256) public nftsPerWalletPublic;

    uint256 private _tokenIdCounter = 1;

    constructor(
        string memory _theBaseURI,
        bytes32 _merkleRootOG,
        bytes32 _merkleRootGTD,
        bytes32 _merkleRootFCFS
    ) ERC721("The Crips", "CRIPS") Ownable() {
        baseURI = _theBaseURI;
        merkleRootOG = _merkleRootOG;
        merkleRootGTD = _merkleRootGTD;
        merkleRootFCFS = _merkleRootFCFS;
        royaltyReceiver = msg.sender;
        paymentReceiver = msg.sender;
        sellingStep = Steps.Before;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal override {
        require(from == address(0) || sellingStep == Steps.SoldOut, "Transfers not allowed until mint is sold out");
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function setMaxSupply(uint256 _newMaxSupply) external onlyOwner {
        require(_newMaxSupply >= _tokenIdCounter - 1, "New max supply too low");
        require(_newMaxSupply > 0, "Max supply must be greater than 0");
        emit MaxSupplyUpdated(MAX_SUPPLY, _newMaxSupply);
        MAX_SUPPLY = _newMaxSupply;
    }

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }

    function setBaseUri(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    function setUpBefore() external onlyOwner {
        sellingStep = Steps.Before;
    }

    function setUpOG() external onlyOwner {
        sellingStep = Steps.OG;
    }

    function setUpGTD() external onlyOwner {
        require(sellingStep == Steps.OG, "OG sale must be active first");
        sellingStep = Steps.GTD;
    }

    function setUpFCFS() external onlyOwner {
        require(sellingStep == Steps.GTD, "GTD sale must be active first");
        sellingStep = Steps.FCFS;
    }

    function setUpPublic() external onlyOwner {
        require(sellingStep == Steps.FCFS, "FCFS sale must be active first");
        sellingStep = Steps.Public;
    }

    function setUpSoldOut() external onlyOwner {
        sellingStep = Steps.SoldOut;
    }

    function setMerkleRootOG(bytes32 _merkleRootOG) external onlyOwner {
        merkleRootOG = _merkleRootOG;
    }

    function setMerkleRootGTD(bytes32 _merkleRootGTD) external onlyOwner {
        merkleRootGTD = _merkleRootGTD;
    }

    function setMerkleRootFCFS(bytes32 _merkleRootFCFS) external onlyOwner {
        merkleRootFCFS = _merkleRootFCFS;
    }

    function setPricePresaleOG(uint256 _price) external onlyOwner {
        pricePresaleOG = _price;
    }

    function setPricePresaleGTD(uint256 _price) external onlyOwner {
        pricePresaleGTD = _price;
    }

    function setPricePresaleFCFS(uint256 _price) external onlyOwner {
        pricePresaleFCFS = _price;
    }

    function setPricePublic(uint256 _price) external onlyOwner {
        pricePublic = _price;
    }

    function setRoyaltyReceiver(address _receiver) external onlyOwner {
        require(_receiver != address(0), "Invalid receiver address");
        royaltyReceiver = _receiver;
    }

    function setRoyaltyPercentage(uint256 _percentage) external onlyOwner {
        require(_percentage <= 10000, "Percentage too high");
        royaltyPercentage = _percentage;
    }

    function setPaymentReceiver(address _newReceiver) external onlyOwner {
        require(_newReceiver != address(0), "Invalid receiver address");
        paymentReceiver = _newReceiver;
    }

    function presaleMintOG(address _account, bytes32[] calldata _proof) external payable {
        require(sellingStep == Steps.OG, "OG sale not active");
        require(!paused, "Contract paused");
        require(nftsPerWalletOG[_account] < maxMintAllowedOG, "Max mint reached for OG");
        require(isWhitelistedOG(_account, _proof), "Not in OG whitelist");
        require(msg.value >= pricePresaleOG, "Insufficient funds");
        require(_tokenIdCounter <= MAX_SUPPLY, "Max supply reached");

        nftsPerWallet[_account]++;
        nftsPerWalletOG[_account]++;
        _safeMint(_account, _tokenIdCounter);
        _tokenIdCounter++;

        (bool success, ) = paymentReceiver.call{value: msg.value}("");
        require(success, "Transfer failed");
        emit FundsTransferred(paymentReceiver, msg.value);
    }

    function presaleMintGTD(address _account, bytes32[] calldata _proof) external payable {
        require(sellingStep == Steps.GTD, "GTD sale not active");
        require(!paused, "Contract paused");
        require(nftsPerWalletGTD[_account] < maxMintAllowedGTD, "Max mint reached for GTD");
        require(isWhitelistedGTD(_account, _proof), "Not in GTD whitelist");
        require(msg.value >= pricePresaleGTD, "Insufficient funds");
        require(_tokenIdCounter <= MAX_SUPPLY, "Max supply reached");

        nftsPerWallet[_account]++;
        nftsPerWalletGTD[_account]++;
        _safeMint(_account, _tokenIdCounter);
        _tokenIdCounter++;

        (bool success, ) = paymentReceiver.call{value: msg.value}("");
        require(success, "Transfer failed");
        emit FundsTransferred(paymentReceiver, msg.value);
    }

    function presaleMintFCFS(address _account, bytes32[] calldata _proof) external payable {
        require(sellingStep == Steps.FCFS, "FCFS sale not active");
        require(!paused, "Contract paused");
        require(nftsPerWalletWL[_account] < maxMintAllowedFCFS, "Max mint reached for FCFS");
        require(isWhitelistedFCFS(_account, _proof), "Not in FCFS whitelist");
        require(msg.value >= pricePresaleFCFS, "Insufficient funds");
        require(_tokenIdCounter <= MAX_SUPPLY, "Max supply reached");

        nftsPerWallet[_account]++;
        nftsPerWalletWL[_account]++;
        _safeMint(_account, _tokenIdCounter);
        _tokenIdCounter++;

        (bool success, ) = paymentReceiver.call{value: msg.value}("");
        require(success, "Transfer failed");
        emit FundsTransferred(paymentReceiver, msg.value);
    }

    function publicMint(uint256 _amount) external payable {
        require(sellingStep == Steps.Public, "Public sale not active");
        require(!paused, "Contract paused");
        require(msg.value >= pricePublic * _amount, "Insufficient funds");
        require(_tokenIdCounter + _amount - 1 <= MAX_SUPPLY, "Max supply reached");

        for (uint256 i = 0; i < _amount; i++) {
            _safeMint(msg.sender, _tokenIdCounter);
            _tokenIdCounter++;
        }
        if (_tokenIdCounter > MAX_SUPPLY) {
            sellingStep = Steps.SoldOut;
        }

        nftsPerWallet[msg.sender] += _amount;
        nftsPerWalletPublic[msg.sender] += _amount;

        (bool success, ) = paymentReceiver.call{value: msg.value}("");
        require(success, "Transfer failed");
        emit FundsTransferred(paymentReceiver, msg.value);
    }

    function gift(address _account, uint256 _amount) external onlyOwner {
        require(_amount > 0, "Amount must be greater than 0");
        require(_tokenIdCounter + _amount - 1 <= MAX_SUPPLY, "Max supply reached");

        for (uint256 i = 0; i < _amount; i++) {
            _safeMint(_account, _tokenIdCounter);
            _tokenIdCounter++;
        }
    }

    function isWhitelistedOG(address account, bytes32[] calldata proof) internal view returns (bool) {
        return MerkleProof.verify(proof, merkleRootOG, keccak256(abi.encodePacked(account)));
    }

    function isWhitelistedGTD(address account, bytes32[] calldata proof) internal view returns (bool) {
        return MerkleProof.verify(proof, merkleRootGTD, keccak256(abi.encodePacked(account)));
    }

    function isWhitelistedFCFS(address account, bytes32[] calldata proof) internal view returns (bool) {
        return MerkleProof.verify(proof, merkleRootFCFS, keccak256(abi.encodePacked(account)));
    }

    function royaltyInfo(uint256, uint256 _salePrice) external view override returns (address receiver, uint256 royaltyAmount) {
        return (royaltyReceiver, (_salePrice * royaltyPercentage) / 10000);
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(ownerOf(_tokenId) != address(0), "Token does not exist");
        return string(abi.encodePacked(baseURI, _tokenId.toString(), baseExtension));
    }

    function totalSupply() external view returns (uint256) {
        return _tokenIdCounter - 1;
    }

    function getNftsPerWalletInPhase(address _wallet, Steps _phase) external view returns (uint256) {
        if (_phase == Steps.GTD) return nftsPerWalletGTD[_wallet];
        if (_phase == Steps.OG) return nftsPerWalletOG[_wallet];
        if (_phase == Steps.FCFS) return nftsPerWalletWL[_wallet];
        if (_phase == Steps.Public) return nftsPerWalletPublic[_wallet];
        return 0;
    }

    function getTotalNftsPerWallet(address _wallet) external view returns (uint256) {
        return nftsPerWallet[_wallet];
    }
}
