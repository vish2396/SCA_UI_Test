import React, { useEffect, useState } from 'react';
import Web3 from 'web3';
import ExchangeABI from './build/contracts/Exchange.json';
import FactoriesABI from './build/contracts/Factories.json';
import FarmersABI from './build/contracts/Farmers.json';

const App = () => {
  const [web3, setWeb3] = useState(null);
  const [account, setAccount] = useState('');
  const [exchangeContract, setExchangeContract] = useState(null);
  const [factoriesContract, setFactoriesContract] = useState(null);
  const [farmersContract, setFarmersContract] = useState(null);
  const [productId, setProductId] = useState('');
  const [totalSupply, setTotalSupply] = useState('');
  const [produceTag, setProduceTag] = useState('');
  const [price, setPrice] = useState('');
  const [name, setName] = useState('');
  const [farmArea, setFarmArea] = useState('');
  const [farmAddress, setFarmAddress] = useState('');
  const [FARMER_CONTRACT, setFARMER_CONTRACT] = useState('');

  useEffect(() => {
    const init = async () => {
      if (typeof window.ethereum !== 'undefined') {
        try {
          await window.ethereum.enable();
          const web3 = new Web3(window.ethereum);
          setWeb3(web3);
          const accounts = await web3.eth.getAccounts();
          setAccount(accounts[0]);
          const exchangeAddress = '0xdEAF83c15e176B4BE8c1A3A0825fB1AE661343a3';
          const factoriesAddress = '0xfaD6Eb142Bf98c20C961A56FcEba6Be776c5c852';
          const farmersAddress = '0x6f17926FA3934dcDeD5dA4AD7341d4C6A4712c12';
          const FARMER_CONTRACT_ADDRESS = '0x6f17926FA3934dcDeD5dA4AD7341d4C6A4712c12';
          console.log("Exchange Contract ABI:", ExchangeABI);
          console.log("Factories Contract ABI:", FactoriesABI);
          console.log("Farmers Contract ABI:", FarmersABI);
          const exchangeContract = new web3.eth.Contract(ExchangeABI.abi, exchangeAddress);
          const factoriesContract = new web3.eth.Contract(FactoriesABI.abi, factoriesAddress);
          const farmersContract = new web3.eth.Contract(FarmersABI.abi, farmersAddress);
          setExchangeContract(exchangeContract);
          setFactoriesContract(factoriesContract);
          setFarmersContract(farmersContract);
          setFARMER_CONTRACT(FARMER_CONTRACT_ADDRESS);
        } catch (error) {
          console.error('Failed to initialize web3:', error);
        }
      } else {
        console.error('Please install MetaMask to interact with this application!');
      }
    };

    init();
  }, []);

  const handleAddProduct = async () => {
    console.log("Exchange Contract Instance:", exchangeContract);
    try {
      if (isNaN(productId)) {
        alert('Product ID must be a valid number.');
        return;
      }
      if (!exchangeContract) {
        alert('Exchange contract not initialized.');
        return;
      }
      await exchangeContract.methods
        .addProduct(
          web3.utils.asciiToHex(productId.toString()), // Convert the product ID to hex format
          parseInt(totalSupply), // Parse the total supply as an integer
          FARMER_CONTRACT
        )
        .send({ from: account });
      alert('Product added successfully!');
    } catch (error) {
      console.error(error);
      alert('Failed to add product.');
    }
  };
  
  const handleAddProduce = async () => {
    console.log("Factories Contract Instance:", factoriesContract); // Add this to check factories contract instance
    try {
      const priceInWei = web3.utils.toWei(price.toString(), 'ether');
      await factoriesContract.methods
        .produceFertilizerLot(produceTag, [10, 20, 30], '', 0, priceInWei)
        .send({ from: account });
      alert('Produce added successfully!');
    } catch (error) {
      console.error(error);
      alert('Failed to add produce.');
    }
  };

  const handleRegisterFarmer = async () => {
    console.log("Farmers Contract Instance:", farmersContract); // Add this to check farmers contract instance
    try {
      await farmersContract.methods.register(name, parseInt(farmArea), farmAddress).send({ from: account });
      alert('Farmer registered successfully!');
    } catch (error) {
      console.error(error);
      alert('Failed to register farmer.');
    }
  };

  return (
    <div>
      <h1>Supply Chain Agriculture App</h1>
      <p>Connected Account: {account}</p>

      <h2>Exchange Contract</h2>
      <div>
        <div>
          <label htmlFor="productId">Product ID:</label>
          <input type="number" id="productId" value={productId} onChange={e => setProductId(e.target.value)} />
        </div>
        <div>
          <label htmlFor="totalSupply">Total Supply:</label>
          <input type="number" id="totalSupply" value={totalSupply} onChange={e => setTotalSupply(e.target.value)} />
        </div>
        <button onClick={handleAddProduct}>Add Product</button>
      </div>

      <h2>Factories Contract</h2>
      <div>
        <div>
          <label htmlFor="produceTag">Produce Tag:</label>
          <input type="text" id="produceTag" value={produceTag} onChange={e => setProduceTag(e.target.value)} />
        </div>
        <div>
          <label htmlFor="price">Price:</label>
          <input type="text" id="price" value={price} onChange={e => setPrice(e.target.value)} />
        </div>
        <button onClick={handleAddProduce}>Add Produce</button>
      </div>

      <h2>Farmers Contract</h2>
      <div>
        <div>
          <label htmlFor="name">Name:</label>
          <input type="text" id="name" value={name} onChange={e => setName(e.target.value)} />
        </div>
        <div>
          <label htmlFor="farmArea">Farm Area:</label>
          <input type="number" id="farmArea" value={farmArea} onChange={e => setFarmArea(e.target.value)} />
        </div>
        <div>
          <label htmlFor="farmAddress">Farm Address:</label>
          <input type="text" id="farmAddress" value={farmAddress} onChange={e => setFarmAddress(e.target.value)} />
        </div>
        <button onClick={handleRegisterFarmer}>Register Farmer</button>
      </div>
    </div>
  );
};

export default App;
