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
    event AuctionEnded(uint index, uint finalPrice, address winner);

    constructor() {
        owner = msg.sender;
    }

    function createAuction(uint _startingPrice, uint _discountRate, string calldata _item, uint _duration) external {
        uint duration = _duration == 0 ? DURATION : _duration;
        
         /* другая форма записи, if (_duration == 0) {   
            DURATION
        } else {
            _duration
        }
         */ 

        require(_startingPrice >= _discountRate * duration, "Incorect starting price"); // коректное значение startingPrice, что не получилось что стартевая цена уходит в минус

        Auction memory newAuction = Auction({
            seller: payable(msg.sender),
            startingPrice: _startingPrice,
            finalPrice: _startingPrice,
            discountRate: _discountRate,
            startAt: block.timestamp,
            endsAt: block.timestamp + duration,
            item: _item,
            stopped: false
        });

        auctions.push(newAuction); // динамический массив

        emit AuctionCreated(auctions.length -1, _item, _startingPrice, duration);
    }

    function getPriceFor(uint index) public view returns(uint) { //брать цену за определеный аукцион
        Auction memory cAuction = auctions[index];
        require(!cAuction.stopped, "stopped");
        uint elapsed = block.timestamp - cAuction.startAt; // сколько прошло времени
        uint discount = cAuction.discountRate * elapsed; // чем больше прошло времени, тем больше скидка
        return cAuction.startingPrice - discount;
    }

    function buy(uint index) external payable {
        Auction memory cAuction = auctions[index];
        require(!cAuction.stopped, "stopped");
        require(block.timestamp < cAuction.endsAt, "ended");
        uint cPrice = getPriceFor(index);
        require(msg.value >= cPrice, "not enough funds");
        cAuction.stopped = true;
        cAuction.finalPrice = cPrice;
        uint refund = msg.value - cPrice; // возврат средств, если сума пришла больше, разница то что нам прислали и ценой в действительности
        if(refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        cAuction.seller.transfer(
            cPrice - ((cPrice * FEE) / 100)
        );// 500
        // 500 - ((500 * 10) / 100) = 500 - 50 = 450
        // Math.floor --> JS

        emit AuctionEnded(index, cPrice, msg.sender); // что за акцион и за какую сумму ушел товар
    }
} 