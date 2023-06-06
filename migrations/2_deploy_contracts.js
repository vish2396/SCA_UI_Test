var Exchange = artifacts.require("./Exchange.sol");
var Factories = artifacts.require("./Factories.sol");
var Farmers = artifacts.require("./Farmers.sol");

module.exports = function(deployer) {
    deployer.deploy(Exchange);
    deployer.deploy(Factories);
    deployer.deploy(Farmers, "0x0CE756545B077eB6F9a4612194430E995C5bEFD2", "0x122f04d071C530B4a7Ed39EE6c83f903c6EF8A8A");
}