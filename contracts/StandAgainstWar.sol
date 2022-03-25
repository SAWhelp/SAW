// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract StandAgainstWar is Ownable, ERC1155Supply {
    using Strings for uint256;

    string ipfsURLFormat;
    string public notRevealedUri;
    uint256 public cost;
    uint256 public maxSupply;
    bool public isPaused = false;
    string public name = "Peace Nightingales";
    address[] public charity;
    bool public revealed=false;
    bool public mintingAllowed;
    uint256 public count=0;
    

    constructor(
        uint256 _cost,
        uint256 _maxSupply,
        address[] memory _charity,
        string memory ipfsURL,
        string memory _ipfsURLFormat
    ) ERC1155(ipfsURL) {
        cost = _cost;
        maxSupply = _maxSupply;
        charity = _charity;     
        ipfsURLFormat= _ipfsURLFormat;
    }


    function _payCharity(uint256 _charityAmount) internal {
        bool success1;
        for(uint i=0;i<charity.length;i++){
            (success1, ) = payable(charity[i]).call{value: _charityAmount/charity.length}("");
        }
        require(success1);
    }

    function mintBatch(uint256 length) public payable {
        require(mintingAllowed == true, "Minting not allowed yet");
        uint256[] memory amounts=new uint256[](length);
        uint256[] memory ids=new uint256[](length);
        for(uint i=1;i<=length;i++){
            amounts[i-1]=1;
            ids[i-1]=count+i;
        }
        require(count + length <= maxSupply);
        count+=length;
        require(!isPaused);
        require(length > 0);

        if (msg.sender != owner()) {
            require(msg.value >= cost * length);
        // pay 90% of the value to charity and the rest to the deployer
            
        }
        _mintBatch(msg.sender, ids, amounts, "");
    }

    function distributeAmount() public payable onlyOwner{

        uint amount = getBalance();

        uint256 _charity = (amount * 90) / 100 ;
        _payCharity(_charity);

        (bool success2, ) = payable(owner()).call{value: (amount - _charity)}("") ;
        require(success2);
        
    }

    function getBalance() public view returns(uint)  {
        return address(this).balance;
    }

    function beginMinting() public onlyOwner {
		mintingAllowed = true;
	}

	function pauseMinting() public onlyOwner {
		mintingAllowed = false;
	}


    function uri(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (revealed == false) {
            return notRevealedUri;
        }

        return string(abi.encodePacked(ipfsURLFormat,Strings.toString(tokenId),".json"));
    }



    function setNotReveledUrl(string memory _notRevealedUrl) public onlyOwner{
        notRevealedUri=_notRevealedUrl;
    }

    // Only Owner Functions
    function setIsRevealed(bool _state) public onlyOwner {
         revealed = _state;
    }

    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        // baseExtension = _newBaseExtension;
    }

    function setIsPaused(bool _state) public onlyOwner {
        isPaused = _state;
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }
}
