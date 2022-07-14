// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.13;

// interface
import {IERC20Metadata as IERC20} from "@openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @title Settlement
 * @author Haythem Sellami
 */
contract Settlement {
    error InvalidMinBidSize();
    error InvalidMinPrice();
    error InvalidMaxBidSize();
    error InvalidMaxPrice();

    struct SellOffer {
        address seller;
        address assetToSell;
        address assetToBuy;
        uint256 totalSize;
        uint256 availableSize;
        uint256 minBidSize;
        uint256 minPrice;
        uint256 assetToSellDecimals;
    }

    struct BuyOffer {
        address buyer;
        address assetToSell;
        address assetToBuy;
        uint256 totalSize;
        uint256 remainingSize;
        uint256 maxBidSize;
        uint256 maxPrice;
        uint256 assetToBuyDecimals;
    }

    struct bidOrder {
        uint256 offerId;
        uint256 bidId;
        address assetToSell;
        address assetToBuy;
        uint256 bidAmount;
        uint256 offerAmountToTrade;
        uint8 v;
        bytes32 r;
        bytes32 s;
        address[] moduleAddresses;
        bytes32[] moduleActions;
    }

    uint256 public sellOffersCounter;
    uint256 public buyOffersCounter;

    mapping(uint256 => SellOffer) public sellOffers;
    mapping(uint256 => BuyOffer) public buyOffers;

    event CreateSellOffer(
        address indexed seller,
        uint256 offerId,
        address indexed assetToSell,
        address indexed assetToBuy,
        uint256 totalSize,
        uint256 minBidSize,
        uint256 minPrice
    );

    event CreateBuyOffer(
        address indexed buyer,
        uint256 offerId,
        address indexed assetToSell,
        address indexed assetToBuy,
        uint256 totalSize,
        uint256 maxBidSize,
        uint256 maxPrice
    );

    modifier checkSellOfferToCreate(uint256 _minBidSize, uint256 _minPrice) {
        if (_minBidSize == 0) {
            revert InvalidMinBidSize();
        } else if (_minPrice == 0) {
            revert InvalidMinPrice();
        }

        _;
    }

    modifier checkBuyOfferToCreate(uint256 _maxBidSize, uint256 _maxPrice) {
        if (_maxBidSize == 0) {
            revert InvalidMaxBidSize();
        } else if (_maxPrice == 0) {
            revert InvalidMaxPrice();
        }

        _;
    }

    function createSellOffer(address _assetToSell, address _assetToBuy, uint256 _totalSize, uint256 _minBidSize, uint256 _minPrice)
        external
        checkSellOfferToCreate(_minBidSize, _minPrice)
        returns (uint256)
    {
        uint256 offerId = sellOffersCounter += 1;

        sellOffers[offerId].seller = msg.sender;
        sellOffers[offerId].assetToSell = _assetToSell;
        sellOffers[offerId].assetToBuy = _assetToBuy;
        sellOffers[offerId].totalSize = _totalSize;
        sellOffers[offerId].availableSize = _totalSize;
        sellOffers[offerId].minBidSize = _minBidSize;
        sellOffers[offerId].minPrice = _minPrice;
        sellOffers[offerId].assetToSellDecimals = IERC20(_assetToSell).decimals();

        emit CreateSellOffer(
            msg.sender,
            offerId,
            _assetToSell,
            _assetToBuy,
            _totalSize,
            _minBidSize,
            _minPrice
        );

        return offerId;
    }

    function createBuyOffer(address _assetToSell, address _assetToBuy, uint256 _totalSize, uint256 _maxBidSize, uint256 _maxPrice)
        external
        checkBuyOfferToCreate(_maxBidSize, _maxPrice)
        returns (uint256)
    {
        uint256 offerId = buyOffersCounter += 1;

        buyOffers[offerId].buyer = msg.sender;
        buyOffers[offerId].assetToSell = _assetToSell;
        buyOffers[offerId].assetToBuy = _assetToBuy;
        buyOffers[offerId].totalSize = _totalSize;
        buyOffers[offerId].remainingSize = _totalSize;
        buyOffers[offerId].maxBidSize = _maxBidSize;
        buyOffers[offerId].maxPrice = _maxPrice;
        buyOffers[offerId].assetToBuyDecimals = IERC20(_assetToBuy).decimals();

        emit CreateBuyOffer(
            msg.sender,
            offerId,
            _assetToSell,
            _assetToBuy,
            _totalSize,
            _maxBidSize,
            _maxPrice
        );

        return offerId;
    }

}
