// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract NftMinter {
    uint256 public mintFee = 0.02 ether;
    address public contractOwner;
    uint256 public nextTokenId;

    struct NFT {
        string name;
        string description;
        string ipfsURL;
        address owner;
    }

    mapping(uint256 => NFT) public tokens;
    mapping(address => uint256) public balanceOf;

    event NFTMinted(
        address indexed minter,
        uint256 tokenId,
        string name,
        string ipfsURL
    );
    event PriceSet(uint256 tokenId, uint256 price);

    modifier onlyTokenOwner(uint256 tokenId) {
        require(msg.sender == tokens[tokenId].owner, "Not the NFT owner");
        _;
    }

    constructor() {
        contractOwner = msg.sender;
    }

    function mint(
        string memory _name,
        string memory _description,
        string memory _ipfsURL
    ) external payable {
        require(msg.value == mintFee, "Must send 0.02 ETH to mint");
        uint256 tokenId = nextTokenId++;
        tokens[tokenId] = NFT(_name, _description, _ipfsURL, msg.sender);
        balanceOf[msg.sender] += 1;

        (bool sent, ) = payable(contractOwner).call{value: msg.value}("");
        require(sent, "Failed to send mint fee");

        emit NFTMinted(msg.sender, tokenId, _name, _ipfsURL);
    }

    function getNFTDetails(
        uint256 tokenId
    )
        external
        view
        returns (string memory, string memory, string memory, address)
    {
        NFT memory nft = tokens[tokenId];
        return (nft.name, nft.description, nft.ipfsURL, nft.owner);
    }

    // This allows the contract to receive ETH
    receive() external payable {}
}
