// SPDX-License-Identifier: MIT
// CC0: No Rights Reserved and Public Domain
// A soulbound
// Created by Dexter Bano Jr.
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

  address public operator;

  bool public paused = false;
  bool public revealed = true;
  uint256 public cost = 0.0001 ether;

  event Burn(address _soul);
  event Update(address _soul);
  event SetProfile(address _profiler, address _soul);
  event RemoveProfile(address _profiler, address _soul);
  
  // struct
   struct Traits { 
      string name;
      string description;
      string bgHue;
      string value;
      string social;
      string sdg;
   }

   struct Building {
       string name;
       int8 w;
       int8 h;
       int8 d;
       int8 x;
       int8 y;
       int8 z;
   }

   struct Soul {
       string identity;
       string url;
       uint256 score;
       uint256 timestamp;
   }
   
   mapping (uint256 => Traits) public traits;
   Building[] public buildings;
   mapping (address => Soul) public souls;
   mapping (address => mapping (address => Soul)) soulProfiles;
   mapping (address => address[]) private profiles;
  
  constructor() ERC721("MalayaLand", "||||") {
      buildings.push(Building("Zero", 0, 0, 0, 0, 0, 0));
      buildings.push(Building("House", 2, 4, 3, 3, 0, 4));
      buildings.push(Building("Courtyard", 3, 6, 5, 11, 1, 7));
      buildings.push(Building("Hospital", 1, 1, 2, 3, 5, 8));
      buildings.push(Building("Leisure House", 13, 21, 34, 54, 88, 0));
      buildings.push(Building("Barn", 2, 3, 5, 8, 1, 1));
      buildings.push(Building("Training Hall", 1, 1, 3, 5, 8, 2));
      buildings.push(Building("Place of Worship", 21, 34, 54, 88, 1, 1));
  }

  function getBuildings() public view returns (Building[] memory) {
      return buildings;
  }

  // public
  function mint() public payable {
    uint256 supply = totalSupply();
    require(supply + 1 <= 10000);
    
    Traits memory newTraits = Traits(
        string(abi.encodePacked('|||| ', uint256(supply + 1).toString())), 
        "Onchain soulbound society, identity, social commentary, and access to Kingdom of Malaya.",
        randomNum(361, block.timestamp, supply).toString(),
        traitsValues[randomNum(traitsValues.length, block.difficulty, supply)],
        socialValues[randomNum(socialValues.length, block.timestamp, supply)],
        sdgValues[randomNum(sdgValues.length, block.difficulty, supply)]);
    
    if (msg.sender != owner()) {
      require(msg.value >= 0.0001 ether);
    }

    traits[supply + 1] = newTraits;
    _safeMint(msg.sender, supply + 1);
  }
        
  function randomNum(uint256 _mod, uint256 _seed, uint _salt) public view returns(uint256) {
      uint256 num = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed, _salt))) % _mod;
      return num;
  }

  function burn(address _soul) external {
      require(msg.sender == _soul, "Only users have rights to delete their data");
      delete souls[_soul];
      for (uint i=0; i<profiles[_soul].length; i++) {
        address profiler = profiles[_soul][i];
        delete soulProfiles[profiler][_soul];
      }
      emit Burn(_soul);
  }

  function update(address _soul, Soul memory _soulData) external {
      require(msg.sender == operator, "Only landlords can update soul data");
      souls[_soul] = _soulData;
      emit Update(_soul);
  }

  function getProfile(address _profiler, address _soul) external view returns (Soul memory) {
      return soulProfiles[_profiler][_soul];
  }
  
  function listProfiles(address _soul) external view returns (address[] memory) {
      return profiles[_soul];
  }
  
  function removeProfile(address _profiler, address _soul) external {
      require(msg.sender == _soul, "Only users have rights to delete their profile data");
      delete soulProfiles[_profiler][msg.sender];
      emit RemoveProfile(_profiler, _soul);
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
  
  function buildMetadata(uint256 _tokenId) public view returns (string memory) {
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
      require(_exists(_tokenId), "||||: URI query for nonexistent token");
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
