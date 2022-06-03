// SPDX-License-Identifier: MIT
// Creator: Chiru Labs
// Amended by: KronicLabz

/************************************************
*             Ded Teddiez Remix!                *
*       Cute as hell, but Ded as well           *
* Created by: Dutch guardian of the Angles Blue *
*************************************************/
pragma solidity ^0.8.0;

import "./ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DedTedz is ERC721A, Ownable{
    using Strings for uint256;

    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public constant MAX_PUBLIC_MINT = 10;
    uint256 public constant PUBLIC_SALE_PRICE = .02 ether;

    string private  baseTokenUri;
    string public   placeholderTokenUri;

    //deploy smart contract, toggle WL, toggle WL when done, toggle publicSale 
    //2 days later toggle reveal
    bool public isRevealed;
    bool public publicSale;
    bool public pause;
    bool public teamMinted;

    mapping(address => uint256) public totalPublicMint;

    constructor() ERC721A("Ded Teddiez Remix", "TED"){

    }

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "Ded Teddiez Remix :: Cannot be called by a contract");
        _;
    }

    function mint(uint256 _quantity) external payable callerIsUser{
        require(publicSale, "Ded Teddiez Remix :: Slow down, its not time yet.");
        require((totalSupply() + _quantity) <= MAX_SUPPLY, "Ded Teddiez Remix :: There's not enough there Ted");
        require((totalPublicMint[msg.sender] +_quantity) <= MAX_PUBLIC_MINT, "Ded Teddiez Remix :: Already minted 10 times!");
        require(msg.value >= (PUBLIC_SALE_PRICE * _quantity), "Ded Teddiez Remix :: Below ");

        totalPublicMint[msg.sender] += _quantity;
        _safeMint(msg.sender, _quantity);
    }

    function teamMint() external onlyOwner{
        require(!teamMinted, "Ded Teddiez Remix :: None more here");
        teamMinted = true;
        _safeMint(msg.sender, 250);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenUri;
    }

    //return uri for certain token
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        uint256 trueId = tokenId + 1;

        if(!isRevealed){
            return placeholderTokenUri;
        }
        //string memory baseURI = _baseURI();
        return bytes(baseTokenUri).length > 0 ? string(abi.encodePacked(baseTokenUri, trueId.toString(), ".json")) : "";
    }

    // @dev walletOf() function shouldn't be called on-chain due to gas consumption
    function walletOf() external view returns(uint256[] memory){
        address _owner = msg.sender;
        uint256 numberOfOwnedNFT = balanceOf(_owner);
        uint256[] memory ownerIds = new uint256[](numberOfOwnedNFT);

        for(uint256 index = 0; index < numberOfOwnedNFT; index++){}

        return ownerIds;
    }
    function setTokenUri(string memory _baseTokenUri) external onlyOwner{
        baseTokenUri = _baseTokenUri;
    }
    function setPlaceHolderUri(string memory _placeholderTokenUri) external onlyOwner{
        placeholderTokenUri = _placeholderTokenUri;
    }

    function togglePause() external onlyOwner{
        pause = !pause;
    }

    function togglePublicSale() external onlyOwner{
        publicSale = !publicSale;
    }

    function toggleReveal() external onlyOwner{
        isRevealed = !isRevealed;
    }
      function withdraw() external onlyOwner{
        //95% to Project owner wallet
        uint256 withdrawAmount_95 = address(this).balance * 95/100;
        //5% to KronicLabz / KronicKatz as a donation to help continue classes 
        //and contracts for its holders. 
        uint256 withdrawAmount_5 = address(this).balance * 5/100;
        payable(0xd325AD5b27519709089b39745748fc5a84571F18).transfer(withdrawAmount_95);
        payable(0x86f2aD57b59bb5BE8091A0a5fDBecb168b63cA17).transfer(withdrawAmount_5);
        payable(msg.sender).transfer(address(this).balance);
    }
}
