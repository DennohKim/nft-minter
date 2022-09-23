// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarketplace {
    struct Listing {
    uint256 price;
    address seller;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;

    function createListing(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) external {
        // Cannot create a listing to sell NFT for < 0 ETH
        require(price > 0, "MRKT: Price must be > 0");

        // If listing already existed, listing.price != 0
        require(
            listings[nftAddress][tokenId].price == 0,
            "MRKT: Already listed"
        );

        // Check caller is owner of NFT, and has approved
        // the marketplace contract to transfer on their behalf
        IERC721 nftContract = IERC721(nftAddress);
        require(nftContract.ownerOf(tokenId) == msg.sender, "MRKT: Not the owner");
        require(
            nftContract.isApprovedForAll(msg.sender, address(this)) ||
                nftContract.getApproved(tokenId) == address(this),
            "MRKT: No approval for NFT"
        );

        // Add the listing to our mapping
        listings[nftAddress][tokenId] = Listing({
            price: price,
            seller: msg.sender
        });
    }
}

