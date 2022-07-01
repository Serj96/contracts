// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
// Голланский аукцион (принцип работи по понижению ценны)
contract AucEngine { 
    address public owner; // владелец аукциона
    uint constant DURATION = 2 days; // длительность каждого аукциона, по умолчанию
    uint constant FEE = 10; // 10%

    struct Auction {
        address payable seller; // человек который продает что либо
        uint startingPrice;
        uint finalPrice; 
        uint startAt; // это когда мы начинаем аукцион
        uint endsAt; // это кагда заканчиваем
        uint discountRate; // сколько будем сбрасывать каждую секунду от цены
        string item;
        bool stopped;
    } 

    Auction[] public auctions;

    event AuctionCreated(uint index, string itemName, uint startingRrice, uint duration);

    constructor() {
        owner = msg.sender;
    }

    function createAuction(uint _startingPrice, uint _discountRate, string calldata _item, uint _duration) external {
        if (_duration == 0) {  // другая форма записи, uint duration = _duration == 0 ? DURATION : _duration;
            DURATION
        } else {
            _duration
        }

        require(_startingPrice >= _discountRate * duration, "Incorect starting price"); // коректное значение startingPrice, что не получилось что стартевая цена уходит в минус

        Auction memory newAuction = Auction({
            seller: payable(msg.sender),
            statrtingPrice: _startingPrice,
            finalPrice: _startingPrice,
            discountRate: _discountRate,
            startAt: block.timestampe,
            endsAt: block.timestampe + duration,
            item: _item,
            stopped: false
        });

        auction.push(newAuction); // динамический массив

        emit AuctionCreated(auction.length -1, _item, startingPrice, duration);
    }

    function getPriceFor(uint index) public view returns(uint) { //брать цену за определеный аукцион
        Auction memory cAuction = auctions[index];
        require(!cAuction.stopped, "stopped");
        uint elapsed = block.timestamp - cAuction.startAt; // сколько прошло времени
        uint discount = cAuction.discountRste * elapsed; // чем больше прошло времени, тем больше скидка
        return cAuction.startingPrice - discount;
    }

    

    } 