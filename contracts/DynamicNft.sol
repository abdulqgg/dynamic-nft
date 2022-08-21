// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

contract BullBear is VRFConsumerBase, ERC721, ERC721Enumerable, ERC721URIStorage, Ownable, KeeperCompatibleInterface {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint public /*immutable*/ interval;
    uint public lastTimeStamp;

    AggregatorV3Interface public priceFeed;
    int256 public currentPrice;

    string[] bullUrisIpfs = [
        "https://ipfs.io/ipfs/QmRXyfi3oNZCubDxiVFre3kLZ8XeGt6pQsnAQRZ7akhSNs?filename=gamer_bull.json",
        "https://ipfs.io/ipfs/QmRJVFeMrtYS2CUVUM2cHJpBV5aX2xurpnsfZxLTTQbiD3?filename=party_bull.json",
        "https://ipfs.io/ipfs/QmdcURmN1kEEtKgnbkVJJ8hrmsSWHpZvLkRgsKKoiWvW9g?filename=simple_bull.json"
    ];

    string[] bearUrisIpfs = [
        "https://ipfs.io/ipfs/Qmdx9Hx7FCDZGExyjLR6vYcnutUR8KhBZBnZfAPHiUommN?filename=beanie_bear.json",
        "https://ipfs.io/ipfs/QmTVLyTSuiKGUEmb88BgXG3qNC8YgpHZiFbjHrXKH3QHEu?filename=coolio_bear.json",
        "https://ipfs.io/ipfs/QmbKhBXVWmwrYsTPFYfroR2N7NAekAMxHUVg2CWks7i9qj?filename=simple_bear.json"

    ];

    uint256 public fee;
    bytes32 public keyHash;
    uint256 public randomness;

    event TokensUpdated(string marketTrend);

    constructor(uint256 updateInterval, address _priceFeed, address _vrfCoordinator, address _link, uint256 _fee, bytes32 _keyhash) 
        ERC721("Bull&Bear", "BBTK")
        VRFConsumerBase(
            _vrfCoordinator,
            _link 
        ){
        interval = updateInterval;
        lastTimeStamp = block.timestamp;

        priceFeed = AggregatorV3Interface(_priceFeed);

        currentPrice = getLatestPrice();  

        fee = _fee;
        keyHash = _keyhash;
    }

    function getRandomNumber() public returns (bytes32 requestId) {
        return requestRandomness(keyHash, fee);
    }


    function fulfillRandomness(bytes32 _requestId, uint256 _randomness) internal override {
        require(_randomness > 0, "random-not-found");
        uint256 indexNft = _randomness % bullUrisIpfs.length;
        randomness = _randomness;
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        string memory defaultUri = bullUrisIpfs[0];
        _setTokenURI(tokenId, defaultUri);
    }

    function checkUpkeep(bytes calldata /*checkData*/) external view override returns(bool upkeepNeeded, bytes memory /*performData*/) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
    }

    function performUpkeep(bytes calldata /*perfromData*/) external override {
        if ((block.timestamp - lastTimeStamp) > interval) {
            lastTimeStamp = block.timestamp;
            int latestPrice = getLatestPrice();

            if(latestPrice == currentPrice) {
                return;
            }
            if(latestPrice < currentPrice) {
                // bear
                updateAllTokensUris("bear");
            } else {
                // bull
                updateAllTokensUris("bull");
            }
            currentPrice = latestPrice;
        }
    }

    function getLatestPrice() public view returns (int256) {
        (,int price,,,)=priceFeed.latestRoundData();

        return price;
    }

    function updateAllTokensUris(string memory trend) internal {
        if (compareStrings("bear", trend)) {
            for(uint256 i =0; i < _tokenIdCounter.current(); i++){
                _setTokenURI(i, bearUrisIpfs[0]);
            }
        } else {
            for(uint256 i =0; i < _tokenIdCounter.current(); i++){
                _setTokenURI(i, bullUrisIpfs[0]);
            }
        }

        emit TokensUpdated(trend);
    }

    function setInterval(uint256 newInterval) public onlyOwner {
        interval = newInterval;
    }

    function setPriceFeed(address newFeed) public onlyOwner {
        priceFeed = AggregatorV3Interface(newFeed);
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)));
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}