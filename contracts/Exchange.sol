// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Exchange {

    struct FarmProduct {
        bytes32 farmProductId;
        bytes32 farmProductTag;
        address payable owner;
        uint totalSupply;
        uint currentSupply;
        bytes32 parentFarmProduct;
        bytes32[] childFarmProduct;
    }
    
    address FARMER_CONTRACT;
    mapping(bytes32 => FarmProduct) farmProduct;
    mapping(address => bytes32[]) distributorFarmProductOwn;

    constructor() {}

    function initFARMERCONTRACT(address _FARMER_CONTRACT) public {
        require(FARMER_CONTRACT == address(0), "FARMER_CONTRACT already initialized");
        FARMER_CONTRACT = _FARMER_CONTRACT;
    }

    function addProduct(bytes32 _farmProductId, uint _totalSupply, address _FARMER_CONTRACT) public {
        require(_FARMER_CONTRACT == FARMER_CONTRACT, "Invalid FARMER_CONTRACT address");
        require(farmProduct[_farmProductId].owner == address(0), "Farm product already exists");
        farmProduct[_farmProductId] = FarmProduct({
            farmProductId: _farmProductId,
            farmProductTag: _farmProductId,
            owner: payable(msg.sender),
            totalSupply: _totalSupply,
            currentSupply: _totalSupply,
            parentFarmProduct: bytes32(0),
            childFarmProduct: new bytes32[](0)
        });
    }

    function divideProduct(bytes32 _farmProductId, uint _amount) private returns(bytes32) {
        bytes32 _newFarmProductId = keccak256(abi.encodePacked(_farmProductId, msg.sender, _amount, block.timestamp));
        require(farmProduct[_newFarmProductId].owner == address(0), "New farm product already exists");
        require(farmProduct[_farmProductId].currentSupply >= _amount, "Insufficient farm product supply");

        farmProduct[_newFarmProductId] = FarmProduct({
            farmProductId: _newFarmProductId,
            farmProductTag: farmProduct[_farmProductId].farmProductTag,
            owner: payable(msg.sender),
            totalSupply: _amount,
            currentSupply: _amount,
            parentFarmProduct: _farmProductId,
            childFarmProduct: new bytes32[](0)
        });

        farmProduct[_farmProductId].currentSupply -= _amount;
        farmProduct[_farmProductId].childFarmProduct.push(_newFarmProductId);

        return _newFarmProductId;
    }

    function buyFarmProduct(bytes32 _farmProductId, uint _amount) public payable {
        require(farmProduct[_farmProductId].currentSupply >= _amount, "Insufficient farm product supply");
        distributorFarmProductOwn[msg.sender].push(divideProduct(_farmProductId, _amount));
        farmProduct[_farmProductId].owner.transfer(msg.value);
    }

    function retailStore(bytes32 _farmProductId, uint _amount) public {
        require(farmProduct[_farmProductId].currentSupply >= _amount, "Insufficient farm product supply");
        farmProduct[_farmProductId].currentSupply -= _amount;
    }
}