// SPDX-License-Identifier: MIT
// CC0: No Rights Reserved and Public Domain
// Created by Stanksy
/**
                         d8b                                d8b                           d8b 
                         88P                                88P                           88P 
                        d88                                d88                           d88  
  88bd8b,d88b  d888b8b  888   d888b8b  ?88   d8P  d888b8b  888   d888b8b    88bd88b  d888888  
  88P'`?8P'?8bd8P' ?88  ?88  d8P' ?88  d88   88  d8P' ?88  ?88  d8P' ?88    88P' ?8bd8P' ?88  
 d88  d88  88P88b  ,88b  88b 88b  ,88b ?8(  d88  88b  ,88b  88b 88b  ,88b  d88   88P88b  ,88b 
d88' d88'  88b`?88P'`88b  88b`?88P'`88b`?88P'?8b `?88P'`88b  88b`?88P'`88bd88'   88b`?88P'`88b
                                              )88                                             
                                             ,d8P                                             
                                          `?888P'                                                                                    
*/

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "https://github.com/Brechtpd/base64/blob/main/base64.sol";

contract Malayaglyphs is ERC721Enumerable, Ownable {
  using Strings for uint256;
  
  string[] public traitsValues = ["We are all born free and equal.", "Do not discriminate.", "The right to life.", "No slavery.", "No torture.", "You have rights no matter where you go.", "We're all equal before the law.", "Your human rights are protected by law.", "No unfair detainment.", "The right to trial.", "We are always innocent till proven guilty.", "The right to privacy.", "Freedom to move.", "The right to seek a safe place to live.", "Right tp a nationality."];
  string[] public socialValues = ["Poverty and Homelessness", "Climate Change", "Overpopulation", "Immigration Stresses", "Civil Rights and Racial Discrimination", "Gender Inequality", "Health Care Availability", "Childhood Obesity", "Bullying"];
  string[] public sdgValues = ["No poverty", "Zero hunger", "Good health and well-being", "Quality education", "Gender equality", "Clean water and sanitation", "Affordable and clean energy", "Decent work and economic growth", "Industry, innovation and infrastructure", "Reduced inequalities", "Sustainable cities and communities", "Responsible consumption and production", "Climate action", "Life below water", "Life on land", "Peace, justice and strong institutions", "Partnerships for the goals"];

  bool public dynamicCost = true;
  uint256 public cost = 0.00001 ether;
  
  // struct
   struct Traits { 
      string name;
      string description;
      string bgHue;
      string value;
      string social;
      string sdg;
   }
   
   mapping (uint256 => Traits) public traits;
  
  constructor() ERC721("MalayaLand", "||||") {}

  // internal
  function needToUpdateCost(uint256 supply) internal pure returns (uint256 _cost) {
      if(supply <= 2000) {
          return 0.00001 ether;
      }
      if(supply <= 1900) {
          return 0.00002 ether;
      }
      if(supply <= 1800) {
          return 0.00003 ether;
      }
      if(supply <= 1700) {
          return 0.00005 ether;
      }
      if(supply <= 1600) {
          return 0.00008 ether;
      }
      if(supply <= 1500) {
          return 0.00013 ether;
      }
      if(supply <= 1400) {
          return 0.00021 ether;
      }
      if(supply <= 1300) {
          return 0.00034 ether;
      }
      if(supply <= 1200) {
          return 0.00055 ether;
      }
      if(supply <= 1100) {
          return 0.00089 ether;
      }
      if(supply <= 1000) {
          return 0.00144 ether;
      }
      if(supply <= 900) {
          return 0.00233 ether;
      }
      if(supply <= 800) {
          return 0.00377 ether;
      }
      if(supply <= 700) {
          return 0.0061 ether;
      }
      if(supply <= 600) {
          return 0.00987 ether;
      }
      if(supply <= 500) {
          return 0.01597 ether;
      }
      if(supply <= 250) {
          return 0.02584 ether;
      }
  }

  // public
  function mint(uint256 _mintAmount, uint256 _maxMintAmount) public payable {
    uint256 supply = totalSupply();
    require(supply + 1 <= 2000);
    require(_mintAmount > 0);
    require(_maxMintAmount <= 50);
    require(_mintAmount <= _maxMintAmount);

    address payable giftAddress = payable(msg.sender);
    uint256 giftValue = 0;

    if (supply > 0) {
        giftAddress = payable(ownerOf(randomNum(supply, block.timestamp, supply + 1) + 1));
        giftValue = supply + 1 == 2000 ? address(this).balance * 2 / 100 : msg.value * 1 / 100;
    }
    
    Traits memory newTraits = Traits(
        string(abi.encodePacked('|||| #', uint256(supply + 1).toString())), 
        "Onchain social commentary work and access to Kingdom of Malaya. Remember to think broadly.",
        randomNum(361, block.timestamp, supply).toString(),
        traitsValues[randomNum(traitsValues.length, block.difficulty, supply)],
        socialValues[randomNum(socialValues.length, block.timestamp, supply)],
        sdgValues[randomNum(sdgValues.length, block.difficulty, supply)]);
    
    if (msg.sender != owner()) {
      require(msg.value >= needToUpdateCost(supply) * _mintAmount, "Not enough funds, hobz.");
    }

    traits[supply + 1] = newTraits;
    _safeMint(msg.sender, supply + 1);

    if (supply > 0) {
        (bool success, ) = payable(giftAddress).call{value: giftValue}("");
        require(success);
    }
  }
        
  function randomNum(uint256 _mod, uint256 _seed, uint _salt) public view returns(uint256) {
      uint256 num = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed, _salt))) % _mod;
      return num;
  }
  
  function buildImage(uint256 _tokenId) public view returns(string memory) {
      Traits memory currentTraits = traits[_tokenId];
      return Base64.encode(bytes(
          abi.encodePacked(
              '<svg width="1" height="1" xmlns="http://www.w3.org/2000/svg">',
              '<rect height="1" width="1" fill="hsl(',currentTraits.bgHue,', 50%, 25%)"/>',
              '</svg>'
          )
      ));
  }
  
  function buildMetadata(uint256 _tokenId) public view returns(string memory) {
      Traits memory currentTraits = traits[_tokenId];
      return string(abi.encodePacked(
              'data:application/json;base64,', Base64.encode(bytes(abi.encodePacked(
                          '{"name":"', 
                          currentTraits.name,
                          '", "description":"', 
                          currentTraits.description,
                          '", "bgHue":"',
                          currentTraits.bgHue,
                          '", "value":"',
                          currentTraits.value,
                          '", "social":"',
                          currentTraits.social,
                          '", "sdg":"',
                          currentTraits.sdg,
                          '", "image": "', 
                          'data:image/svg+xml;base64,', 
                          buildImage(_tokenId),
                          '"}')))));
  }

  function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
      require(_exists(_tokenId),"ERC721Metadata: URI query for nonexistent token");
      return buildMetadata(_tokenId);
  }

  function withdraw() public payable onlyOwner {
    // =============================================================================
    // This will pay The Giving Block Children and Youth Impact Index Fund: 2% of the initial sale.
    // =============================================================================
    (bool a, ) = payable(0x4B0E64438DD3878365A110c4D9F2358cFDB2B05F).call{value: address(this).balance * 2 / 100}("");
    require(a);
    // =============================================================================
    // This will pay The Giving Block LGBTQIA+ Impact Index Fund: 2% of the initial sale.
    // =============================================================================
    (bool b, ) = payable(0x382956C3f391B7EfdDE9Ba9D703cF5F6C68244f2).call{value: address(this).balance * 2 / 100}("");
    require(b);
    // =============================================================================
    // This will pay The Giving Block Technology and Science Impact Index Fund: 2% of the initial sale.
    // =============================================================================
    (bool c, ) = payable(0x8DF62638c0961f67bA6a7bE663163e2cF7AC8b05).call{value: address(this).balance * 2 / 100}("");
    require(c);
    // =============================================================================
    // This will pay The Giving Block Civil and Human Rights Impact Index Fund: 2% of the initial sale.
    // =============================================================================
    (bool d, ) = payable(0xa77D19eB8E28e82364800eD4F6f3677b2Cc0ce88).call{value: address(this).balance * 2 / 100}("");
    require(d);
    // =============================================================================
    // This will pay The Giving Block Environment Impact Index Fund: 2% of the initial sale.
    // =============================================================================
    (bool e, ) = payable(0x0CD65732E1A7A4EbEe033547Cd832E3E647adAaA).call{value: address(this).balance * 2 / 100}("");
    require(e);
    // =============================================================================
    // This will payout the owner 90% of the contract balance.
    // =============================================================================
    (bool f, ) = payable(owner()).call{value: address(this).balance}("");
    require(f);
    // =============================================================================
  }
}
