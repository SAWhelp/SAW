// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;
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
    bool public revealed=false;
    bool public mintingAllowed;
    uint256 public count=0;

    address[] public charity = [
    //    //Food for life-
        0xe26F250ea4d5c20d310910C3e0510156a18c1aFb,

    //    //Care-
        0xE72b48A4a28Fc2d5e25844e0f73Fe78999BFf997,

    //    //Save the children-
        0xe40c0E6Afce8B7e2f84671513D9180f2fe016F50,

    //    //Project Hope-
        0xE842B86Be7105B53432fCce827c265931f2e6074,

    //    //World Central Kitchen-
        0x488f853bEFdFEe83182a962B1CFA9500Fb2450Df,

    //    //Global Fund for Children-
        0x8FD49F6Fe537f89D33d1263cfA8210d74A0F8824,

    //    //Danish Refugee Council
        0x7c37D818cfCC9e57BeA6744F0F584b3f7d937c42,

    //    //Direct Relief-
        0x7953f82CE89433AaE365BdDdb856fb00C7a1e92C,

    //    //United Way Worldwide-
        0xcc4E314ce612e6515b2522A11C8ccA1A13d6F177,

    //    //SOS Childrens Villages-
        0xcB71ae824D5e86B56D2c0aF15f086f3ada93cc22,

    //    //Action AID USA-
        0x1fcE2A7E198860f34629BcbCaaaA8f2647f8f0D9,

    //    //Alight-
        0xA622f2e4e47F8d4313Bf9eeB122e3B0010958d12,

    //    //Good360-
        0x3538AB1D347B7bCe1E55D8FAdC0Afa72489de24A,

    //    //Mercy Corps-
        0x7A6b6d52244c7dabe860E8CFb79970Eb84260c79,

    //    //Internationasl FUnd For Animal Welfare-
        0xaa9896b8189f19489B13A80A3C453B705c721209,

    //     //Wonder Foundation-
        0x33aF47e8315d4Fc2ced3590455CE545ab49f0d8E,

    //  //Committee to Protect Jounalists    
        0x1Af66BB70d15dbb27928cF1Bd9EF05aD7A21F73B
    ];
    

    constructor(
        uint256 _cost,
        uint256 _maxSupply,
        string memory ipfsURL,
        string memory _ipfsURLFormat,
        address _multisigdevWallet
    ) ERC1155(ipfsURL) {
        cost = _cost;
        maxSupply = _maxSupply;     
        ipfsURLFormat= _ipfsURLFormat;
        devWallet = _multisigdevWallet;
    }

    // multisig dev wallet address
    address public devWallet;

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
            require(msg.value == cost * length);            
        }
        _mintBatch(msg.sender, ids, amounts, "");
    }

    function distributeAmount() public payable onlyOwner{

        uint amount = getBalance();

        uint256 _charity = (amount * 90) / 100 ;
        _payCharity(_charity);

        (bool success2, ) = payable(devWallet).call{value: (amount - _charity)}("") ;
        require(success2);
        
    }

    function getBalance() public view returns(uint)  {
        return address(this).balance;
    }

    event mintStatus(bool from, bool changedTo, uint256 timestamp);
    
    event priceChanged(uint256 newPrice, uint256 timestamp);

    event setRevealed(bool revealed , uint256 timestamp);

    event setPaused(bool paused, uint256 timestamp);


    function beginMinting() public onlyOwner {
        mintingAllowed = true;
        emit mintStatus(false, true, block.timestamp);
    }

    function pauseMinting() public onlyOwner {
        mintingAllowed = false;
        emit mintStatus(true, false, block.timestamp);
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
         emit setRevealed(_state, block.timestamp);
    }

    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
        emit priceChanged(cost, block.timestamp);
    }

    function setIsPaused(bool _state) public onlyOwner {
        isPaused = _state;
        emit setPaused(_state, block.timestamp);
    }

}
