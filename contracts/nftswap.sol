// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interface/IERC721.sol";
import "../interface/IERC721Receiver.sol";

contract nftswap is IERC721Receiver{
    event List(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price);

    event Purchase(
        address indexed buyer,
        address indexed seller,
        address indexed nftAddress,
        uint256 tokenId,
        uint256 price
    );

    event Revoke(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    );

    event Update(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 newPrice
    );

    struct Order {
        address owner;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Order)) nftList;

    function list(address _nftAddr, uint256 _tokenId, uint256 _price) public {
        IERC721 nft = IERC721(_nftAddr);
        require(nft.getApproved(_tokenId) == address(this), "Need Approval");
        require(_price > 0);

        Order storage _order = nftList[_nftAddr][_tokenId];
        _order.owner = msg.sender;
        _order.price = _price;

        nft.safeTransferFrom(msg.sender, address(this), _tokenId);

        emit List(msg.sender, _nftAddr, _tokenId, _price);
    }

    // cancle the list
    function revoke(address _nftAddr, uint256 _tokenId) public {
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.owner == msg.sender, "Not Owner");
        IERC721 nft = IERC721(_nftAddr);
        require(nft.ownerOf(_tokenId) == address(this), "Not Owner");

        nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete nftList[_nftAddr][_tokenId];

        emit Revoke(msg.sender, _nftAddr, _tokenId);
    }

    function purchase(address _nftAddr, uint256 _tokenId) public payable {
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.price > 0, "Invalid Price");
        require(msg.value > _order.price, "Balance Not Enough!");

        // nft is in the contract address
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Not In Swap");

        // Transfer NFT to buyer
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        // Transfer ETH to seller, Transfer left ETH to buyer
        payable(_order.owner).transfer(_order.price);
        payable(msg.sender).transfer(msg.value - _order.price);

        delete nftList[_nftAddr][_tokenId];

        emit Purchase(msg.sender, _order.owner, _nftAddr, _tokenId, _order.price);
    }

    function update(address _nftAddr, uint256 _tokenId, uint256 _newPrice) public {
        require(_newPrice > 0);
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.owner == msg.sender, "Not Owner");

        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order");

        _order.price = _newPrice;

        emit Update(msg.sender, _nftAddr, _tokenId, _newPrice);
    }

    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}