// contracts/Pet.sol
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./Pet.sol";
import "./Paw.sol";

contract Store {
  Paw public token;
  Pet public NFT;

  event Sold(uint256 nftId, uint256 price, address buyer);
  event OnSale(uint256 nftId, uint256 price, address seller);

  // TODO: Keep record to track if a token ID is for sale or not.
  mapping (uint => bool) private tokenIdForSale; 
  // TODO: Keep record to linking a token's ID to their buyers.
  mapping (uint => address) private tokenIdToBuyer;

  constructor(Paw pawaddr, Pet petaddr) {
    token = pawaddr;
    NFT = petaddr;
  }

  function isOnSale(uint256 _tokenId) public view returns (bool) {
    return tokenIdForSale[_tokenId];
  }

  function tokenPrice(uint256 tokenId) public view returns (uint256 price) {
    price = NFT.tokenPrice(tokenId);
  }

  // TODO: Create the nftSale function.
  function nftSale(uint256 _tokenId, uint256 price) external {
    // TODO: Require that the person connected to the contract is the NFT owner.
    require(msg.sender == NFT.ownerOf(_tokenId));
    // TODO: Set a boolean in a record to indicate that the NFT is for sale.
    tokenIdForSale[_tokenId] = true;
    // TODO: Set the NFT token price using a function in Pet.sol.
    NFT.setTokenPrice(_tokenId, price);
    // TODO: Emit an onSale Event using the token ID, the price, and the address connected to the contract.
    emit OnSale(
      _tokenId,
      price,
      msg.sender
    );
  }
  
  // TODO: Complete nftMintBuy.
  function nftMintBuy(uint256 price, string memory tokenURI) external {
    // TODO: Require that only the NFT contract owner can call this function.  Use NFT.owner().
    require(msg.sender == NFT.owner(), "You do not have permission to Mint and Buy, Only the owner of the Pet NFT Contract has permission.");
    // TODO: Use require to check for insufficient allowance compared to price.  See allowance() in ERC20.sol.
    // Hint: allowance() asks how much money can a spender spend on behalf of an owner.
    // The "owner" is the person interacting with the contract, and the contract itself is the "spender".
    require(token.allowance(msg.sender, address(this)) >= price, "User does not have sufficient allowance to buy NFT");
    // TODO: Use require to check for insufficient balance compared to price.  See balanceOf() in ERC20.sol.
    require(token.balanceOf(msg.sender) >= price, "User does not have sufficient balance to buy NFT");
    // TODO: Mint a token to the buyer.
    uint tokenId = NFT.currentTokenId();
    NFT.mintTo(msg.sender, tokenURI, price);
    // uint tokenId = Pet.mintTo(msg.sender, tokenURI, price);
    // TODO: Set the price of the token.
    NFT.setTokenPrice(tokenId, price);
    // TODO: Transfer that same number of tokens from the buyer to this contract's address.
    token.transfer(address(this), price);
    // TODO: Set the new owner of the token to be the address connected to the contract.
    tokenIdToBuyer[tokenId] = msg.sender;
    // TODO: Set that the token is no longer for sale.
    tokenIdForSale[tokenId] = false;
    // TODO: Emit a Sold Event using the token ID, price, and the buyer's address.
    emit Sold(tokenId, price, msg.sender);
  }

  // TODO: Complete nftBuy.
  function nftBuy(uint256 tokenId) public {
    // TODO: Require that the tokenId is on sale.
    require(tokenIdForSale[tokenId], "NFT not on sale");
    // TODO: Get the token's current price.
    uint price = tokenPrice(tokenId);
    // TODO: Use require to check for both insufficient allowance or insufficient balance.
    require(token.allowance(msg.sender, address(token)) >= price && token.balanceOf(msg.sender) >= price, "Insufficient Allowance or Balance.");
    // TODO: Transfer Paw tokens from msg.sender to the owner of the NFT based on the token's price.
    // See ownerOf() in ERC721.sol.
    token.transfer(NFT.ownerOf(tokenId), price);
    // TODO: Transfer the NFT from its original owner to the buyer (i.e., msg.sender).
    NFT.safeTransferFrom(NFT.ownerOf(tokenId), msg.sender, tokenId);
    // TODO: Set the new owner of the token to be the address connected to the contract.
    tokenIdToBuyer[tokenId] = msg.sender;
    // TODO: Set that the token is no longer for sale.
    tokenIdForSale[tokenId] = false;
    // TODO: Emit a Sold Event using the token ID, price, and the buyer's address.
    emit Sold(tokenId, price, msg.sender);
  }
}
