pragma solidity =0.8.13;

// test dependency
import {Test} from "@std/Test.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";
// contract
import {Settlement} from "../../src/core/Settlement.sol";


contract SettlementTest is Test {
    MockERC20 internal usdc;
    MockERC20 internal squeeth;
    Settlement internal settlement;

    uint256 internal sellerPrivateKey;
    uint256 internal buyerPrivateKey;
    uint256 internal randomPrivateKey;
    address internal seller;
    address internal buyer;
    address internal random;

    function setUp() public {
        sellerPrivateKey = 0xA11CE;
        buyerPrivateKey = 0xb11CE;
        randomPrivateKey = 0xA11DE;
        seller = vm.addr(sellerPrivateKey);
        buyer = vm.addr(buyerPrivateKey);
        random = vm.addr(randomPrivateKey);

        usdc = new MockERC20("USDC", "USDC", 6);
        squeeth = new MockERC20("SQUEETH", "oSQTH", 18);
        settlement = new Settlement();

        vm.label(seller, "Seller");
        vm.label(buyer, "Buyer");
        vm.label(address(settlement), "Settlement");
        vm.label(address(usdc), "USDC");
        vm.label(address(squeeth), "oSQTH");
    }

    function testCreateSellOffer() public {
        vm.startPrank(seller);
        uint256 offerId = settlement.createSellOffer(address(squeeth), address(usdc), 10e18, 1e18, 1000e6);
        vm.stopPrank();

        (
            address sellerAddr,
            address assetToSell,
            address assetToBuy,
            uint256 totalSize,
            uint256 availableSize,
            uint256 minBidSize,
            uint256 minPrice,
            uint256 assetToSellDecimals
        ) = settlement.sellOffers(offerId);

        assertEq(sellerAddr, seller);
        assertEq(assetToSell, address(squeeth));
        assertEq(assetToBuy, address(usdc));
        assertEq(totalSize, 10e18);
        assertEq(availableSize, 10e18);
        assertEq(minBidSize, 1e18);
        assertEq(minPrice, 1000e6);
        assertEq(assetToSellDecimals, 18);
    }

    function testRevertInvalidMinBidSize() public {
        vm.startPrank(seller);
        vm.expectRevert(Settlement.InvalidMinBidSize.selector);
        settlement.createSellOffer(address(squeeth), address(usdc), 10e18, 0, 1000e6);
        vm.stopPrank();
    }

    function testRevertInvalidMinPrice() public {
        vm.startPrank(seller);
        vm.expectRevert(Settlement.InvalidMinPrice.selector);
        settlement.createSellOffer(address(squeeth), address(usdc), 10e18, 1e18, 0);
        vm.stopPrank();
    }

    function testCreateBuyOffer() public {
        vm.startPrank(buyer);
        uint256 offerId = settlement.createBuyOffer(address(usdc), address(squeeth), 10e18, 1e18, 1000e6);
        vm.stopPrank();

        (
            address buyerAddr,
            address assetToSell,
            address assetToBuy,
            uint256 totalSize,
            uint256 remainingSize,
            uint256 maxBidSize,
            uint256 maxPrice,
            uint256 assetToBuyDecimals
        ) = settlement.buyOffers(offerId);

        assertEq(buyerAddr, buyer);
        assertEq(assetToSell, address(usdc));
        assertEq(assetToBuy, address(squeeth));
        assertEq(totalSize, 10e18);
        assertEq(remainingSize, 10e18);
        assertEq(maxBidSize, 1e18);
        assertEq(maxPrice, 1000e6);
        assertEq(assetToBuyDecimals, 18);
    }

    function testRevertInvalidMaxBidSize() public {
        vm.startPrank(buyer);
        vm.expectRevert(Settlement.InvalidMaxBidSize.selector);
        settlement.createBuyOffer(address(usdc), address(squeeth), 10e18, 0, 1000e6);
        vm.stopPrank();
    }

    function testRevertInvalidMaxPrice() public {
        vm.startPrank(buyer);
        vm.expectRevert(Settlement.InvalidMaxPrice.selector);
        settlement.createBuyOffer(address(usdc), address(squeeth), 10e18, 1e18, 0);
        vm.stopPrank();
    }
}
