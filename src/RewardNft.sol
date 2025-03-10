// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/**
 * @title RewardNft- Simplified ERC721
 * @dev Basic NFT for top contributors in the crowdfunding platform
 */
contract RewardNft {
    string public name = "RewardNft";
    string public symbol = "RNFT";

    // Owner of the contract
    address public owner;
    // Only the crowdfunding contract can mint NFTs
    address public crowdfundingContract;

    // Token ID to owner address
    mapping(uint256 => address) private _owners;
    // Owner address to token count
    mapping(address => uint256) private _balances;

    // Counter for token IDs
    uint256 private _tokenIdCounter;

    // Events
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    // Modifier to restrict functions to owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setCrowdfundingContract(
        address _crowdfundingContract
    ) external onlyOwner {
        crowdfundingContract = _crowdfundingContract;
    }

    function mintNFT(address to) external returns (uint256) {
        require(
            msg.sender == crowdfundingContract,
            "Only crowdfunding contract can mint"
        );
        require(to != address(0), "Mint to the zero address");

        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        return tokenId;
    }

    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), "Balance query for zero address");
        return _balances[_owner];
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        address _owner = _owners[tokenId];
        require(_owner != address(0), "Owner query for nonexistent token");
        return _owner;
    }
}
