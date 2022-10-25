// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "https://github.com/transmissions11/solmate/blob/bff24e835192470ed38bf15dbed6084c2d723ace/src/tokens/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MyToken is ERC721, Pausable, Ownable, ERC2981 {

    error AlreadyMinted();
    error NotAllowedToMInt();
    error WrongPrice();
    error SoldOut();
    error NoMetadata();
    error IncorrectInput();
    
    uint96 royaltyFeesInBips;
    uint256 public MAX_SUPPLY = 50;
    uint256 constant public WHITELIST_PRICE = 0 ether;
    uint256 public totalSupply;
    uint256 public maxMintPerWallet = 1;
    string public contractURI;
    string public baseURI;
    string public baseExtension;
    address[] private mintersArray;
    mapping(address => uint) public mintedTokenCount; 
    bool public isRevealed;
    
    constructor(uint96 _royaltyFeesInBips, string memory _contractURI) ERC721("MyToken", "MTK") {
        setRoyaltyInfo(msg.sender, _royaltyFeesInBips);
        contractURI = _contractURI;
        baseExtension = ".json";
        baseURI = "https://ipfs.io/ipfs/QmQrdKei1tMdLEYEXrpUxwd89XS3F7k1h2e7FbtQxmE47n";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return baseURI;
    }

    function assignWhitelist(address[] memory _whitelist) public onlyOwner {
        if(_whitelist.length <= 0) { revert IncorrectInput(); }
        mintersArray = _whitelist;
    }

    function checkWallet(address _walletRequested) internal view returns (bool) {
        for(uint i = 0; i <= mintersArray.length; i++) {
            if(mintersArray[i] == _walletRequested) {
                return true;
            }
        }
        return false;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function reveal(string memory _newBaseURI) public onlyOwner {
        isRevealed = true;
        baseURI = _newBaseURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setRoyaltyInfo(address _receiver, uint96 _royaltyFeesInBips) public onlyOwner {
        _setDefaultRoyalty(_receiver, _royaltyFeesInBips);
    }

    function setContractURI(string calldata _contractURI) public onlyOwner {
        contractURI = _contractURI;
    }

    function mint() public payable {
        if(mintedTokenCount[msg.sender] > maxMintPerWallet) { revert AlreadyMinted(); }
        if(checkWallet(msg.sender) == false) { revert NotAllowedToMInt(); }
        if(msg.value != WHITELIST_PRICE) { revert WrongPrice(); }
        uint256 tokenId = totalSupply + 1;
        if(tokenId > MAX_SUPPLY) { revert SoldOut(); }
        _safeMint(msg.sender, tokenId);
        mintedTokenCount[msg.sender]++;
        totalSupply++;
    }

    /*function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }*/

    // The following functions are overrides required by Solidity.

    function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override(ERC721)
    returns (string memory)
  {
    if(_ownerOf[tokenId] == address(0)) {
        revert NoMetadata();
    }
    
    string memory currentBaseURI = _baseURI();

    if(isRevealed == false) {
        return currentBaseURI;
    }

    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, Strings.toString(tokenId), baseExtension))
        : "";
  }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}