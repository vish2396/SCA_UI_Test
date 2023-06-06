// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Factories {
    //This enum represents factory's status
    enum Status { Unregister, Registered, Banned }

    //This struct represents identity of factory
    //name   : factory's name
    //wallet : factory's address
    //id     : factory's id that is acquire when register
    //facAddress    : Real address of factory
    //fertilizerId  : Array for record all factory product
    //fertilizerInfo: Detail of fertilizerId
    struct FactoryIdentity {
        string name;
        address wallet;
        bytes32 id;
        string facAddress;
        bytes32[] fertilizerId;
    }

    //This struct represents infomation of product(fertilizer)
    //fertilizerId: Product's id
    //npk         : Product npk;
    //detail      : Other product detail
    //price       : The price of this product
    struct FertilizerInfo {
        bytes32 fertilizerId;
        int[3] npk;
        string detail;
        uint price;
    }

    //This struct represents fertilizerLot status
    //ownerWallet : address of the owner of this product lot
    //date        : produced time
    //quantity    : The quantity of this product lot
    //price       : The price of this product lot
    //status      : The status of this product lot
    struct FertilizerLot {
        address ownerWallet;
        uint date;
        uint quantity;
        uint price;
        Status status;
    }
    mapping(bytes32 => address payable) public produceTagToWallet;

    //This mapping maintains all factories' identity
    mapping(address => FactoryIdentity) public factories;
    
    //This mapping maintains all factories' fertilizer info
    mapping(address => mapping(bytes32 => FertilizerInfo)) public factoriesFertilizerInfo;

    //This mapping maintains all factories' fertilizer lots
    mapping(address => mapping(bytes32 => bytes32[])) public factoriesFertilizerLot;

    //This mapping maintains all fertilizers' status
    mapping(bytes32 => FertilizerLot) public fertilizerLot;

    //This event will be emitted when a factory is registered
    event FactoryRegistered(bytes32 indexed id, string name, address wallet);

    //This event will be emitted when a fertilizer lot is produced
    event FertilizerProduced(bytes32 indexed id, bytes32 lotId, int[3] npk, string detail);

    //This modifier checks if the caller is registered as a factory
    modifier isRegistered {
        require(factories[msg.sender].wallet != address(0), "Factory not found!");
        _;
    }

    //This function registers a new factory
    function registerFactory(string memory _name, string memory _facAddress) public {
        bytes32 id = keccak256(abi.encodePacked(block.number, block.timestamp, msg.sender, _name));
        factories[msg.sender] = FactoryIdentity(_name, msg.sender, id, _facAddress, new bytes32[](0));
        emit FactoryRegistered(id, _name, msg.sender);
    }

    //This function produces a new fertilizer lot
    function produceFertilizerLot(bytes32 _id, int[3] memory _npk, string memory _detail, uint _quantity, uint _price) public isRegistered {
        bytes32 lotId = keccak256(abi.encodePacked(_id, block.number, block.timestamp, msg.sender));
        fertilizerLot[lotId] = FertilizerLot(msg.sender, block.timestamp, _quantity, _price, Status.Registered);
        factories[msg.sender].fertilizerId.push(_id);
        factoriesFertilizerInfo[msg.sender][_id] = FertilizerInfo(_id, _npk, _detail, _price);
        factoriesFertilizerLot[msg.sender][_id].push(lotId);
        emit FertilizerProduced(_id, lotId, _npk, _detail);
    }

    //This function gets all fertilizer lots produced by a factory
    function getFertilizerLots(bytes32 _id) public view returns(bytes32[] memory) {
        return factoriesFertilizerLot[msg.sender][_id];
    }

    //This function gets the price of a given fertilizer based on its ID
    function getPrice(bytes32 _produceTag) public view returns(uint) {
        return factoriesFertilizerInfo[msg.sender][_produceTag].price;
    }

    //This function allows farmers to buy fertilizer lots from factories
    function sellFert(bytes32 _fertilizerId, bytes32 _produceTag, uint _buyAmount) public payable {
        uint totalPrice = getPrice(_fertilizerId) * _buyAmount;
        require(msg.value == totalPrice, "Insufficient funds");
        address payable factoryWallet = payable(getWallet(_produceTag));
        require(factoryWallet != address(0), "Factory not found");
        factoryWallet.transfer(msg.value);
        bytes32[] storage lots = factoriesFertilizerLot[msg.sender][_fertilizerId];
        uint remainingAmount = _buyAmount;
        for (uint i = 0; i < lots.length && remainingAmount > 0; i++) {
            FertilizerLot storage lot = fertilizerLot[lots[i]];
            if (lot.status == Status.Registered && lot.quantity > 0 && lot.price == getPrice(_fertilizerId)) {
                uint amountToBuy = lot.quantity < remainingAmount ? lot.quantity : remainingAmount;
                lot.quantity -= amountToBuy;
                remainingAmount -= amountToBuy;
                if (lot.quantity == 0) {
                    lot.status = Status.Unregister;
                }
                payable(msg.sender).transfer(amountToBuy * lot.price);
            }
        }
        require(remainingAmount == 0, "Not enough fertilizer lots available");
    }
    
    //This function retrieves the wallet address of a factory based on its produce tag
    function getWallet(bytes32 _produceTag) public view returns(address) {
        for (uint i = 0; i < factories[msg.sender].fertilizerId.length; i++) {
            bytes32 fertilizerId = factories[msg.sender].fertilizerId[i];
            if (keccak256(abi.encodePacked(factoriesFertilizerInfo[msg.sender][fertilizerId].fertilizerId)) == keccak256(abi.encodePacked(_produceTag))) {
                return factories[msg.sender].wallet;
            }
        }
        return address(0);
    }
}