// SPDX-License-Identifier:GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;
pragma experimental ABIEncoderV2;

// Land Registration Contract

contract Project
{
    /*
    State variable of type address for owner of Contract
    */
    address private owner;


    /*
    State variable of type uint for Lands count
    */
    uint public landsCount;


    /*
    Constructor to make deployer of the contract Land Inspector
    */
    constructor ()
    {
        owner = msg.sender;
    }

    
    
    /*
    Event for registerOrUpdateLandInspector Function
    */
    event inspectorRegister
    (
        string status,
        address id,
        string Name,
        uint Age,
        string Designation
    );



    /*
    Event for registerOrUpdateSeller Function
    */
    event sellerRegister
    (
        string status,
        string Name,
        uint Age,
        string City,
        uint CNIC,
        string Email
    );



    /*
    Event for registerOrUpdateLandBuyer Function
    */
    event buyerRegister
    (   string status,
        string Name,
        uint Age,
        string City,
        uint CNIC,
        string Email
    );



    /*
    Event for registerLand Function
    */
    event landRegister
    (
        string status,
        uint landId,
        address seller
    );



    /*
    Event for BuyLand Function
    */
    event buyingLand
    (
        string status,
        uint landId,
        uint price,
        address seller,
        address buyer
    );



    /*
    Event for transferOwnership Function
    */
    event ownershipTransfer
    (
        address oldOwner,
        uint landId,
        address newOwner
    );


    
    /*
    Struct to store Seller data
    */
    struct sellerStruct
    {
        string Name;
        uint Age;
        string City;
        uint CNIC;
        string Email;
        bool isVerified;
        uint flag;
    }
    

    

    /*
    Struct to store Buyer data
    */
    struct buyerStruct
    {
        string Name;
        uint Age;
        string City;
        uint CNIC;
        string Email;
        bool isVerified;
        uint flag;
    }
    

    

    /*
    Struct to store Seller data
    */
    struct landInspectorStruct
    {
        address id;
        string Name;
        uint Age;
        string Designation;
    }
    


    
    /*
    Struct to store Land data
    */
    struct landStruct
    {
        uint LandId;
        uint Area;
        string City;
        string State;
        uint LandPrice;
        string PropertyPID;
        bool isVerified;
        uint flag;
    }



    /*

    Mappings

    1. Mapping for seller to map seller address to its struct
    2. Mapping for buyer to map buyer address to its struct
    3. Mapping for Lands to map Land id to its struct
    4. Mapping for Land Owner to map its owner's address to its struct
    5. Mapping for Land Owner to map seller's address to its lad's id

    */

    mapping(address => sellerStruct) private SellerMapping;
    mapping(address => buyerStruct) private BuyerMapping;
    mapping(uint => landStruct) public Lands;
    mapping(uint => address) private landOwnerMapping;
    mapping(address => uint) private ownerMapping;


    /*
    landInspectorStruct type variable
    */

    landInspectorStruct private Inspector;

    
    
    
    /*
    Function to register or update Land Inspector, only Contract Deployer can call this function
    */
    function registerOrUpdateLandInspector(string memory _name, uint _age, string memory _designation) public
    {
        require(msg.sender == owner, "You are not the owner");
        Inspector = landInspectorStruct(owner, _name, _age, _designation);
        emit inspectorRegister("Land Inspector data is successfully saved", msg.sender, _name, _age, _designation);
    }



    /*
    Modifier to rstrict some functions use for Inspector only
    */
    modifier onlyInspector()
    {
        require(msg.sender == Inspector.id, "You are not the Land Inspector");
        _;
    }

    
    
    /*
    Function to register or update Seller
    A buyer and Inspector can not call this function
    */
    function registerOrUpdateSeller
    (
        string memory _Name,
        uint _Age,
        string memory _City,
        uint _CNIC,
        string memory _Email
    ) public
    {
        require(msg.sender != Inspector.id, "Inspector can not be seller");
        require(BuyerMapping[msg.sender].flag !=1, "This person is registered as Buyer");
        SellerMapping[msg.sender] = sellerStruct(_Name, _Age, _City, _CNIC, _Email, false, 1);
        emit sellerRegister("Seller data is successfully saved", _Name, _Age, _City, _CNIC, _Email);
    }



    /*
    Function to set the verification status of seller
    Only Inspector can call this function
    */
    function verifySeller
    (
        address _address,
        bool _status
    ) public onlyInspector
    {
        SellerMapping[_address].isVerified = _status;
    }

    
    /*
    Function to register Land
    Land should not be registered already
    Caller of the function should not be registered as Buyer
    Only a Seller can call this function
    Seller should be verified
    */
    function registerLand
    (
        uint _area,
        string memory _city,
        string memory _state,
        uint _price,
        string memory _Ppid
    ) public
    {
        require(Lands[ownerMapping[msg.sender]].flag != 1,"Land is already registered");
        require(BuyerMapping[msg.sender].flag != 1, "This person is registered as Buyer");
        require(SellerMapping[msg.sender].isVerified == true, "Seller is not verified");
        landsCount ++;
        Lands[landsCount] = landStruct(landsCount, _area, _city, _state, _price, _Ppid, false, 1);
        landOwnerMapping[landsCount] = msg.sender;
        ownerMapping[msg.sender] = landsCount;
        emit landRegister("Land data successfully saved", landsCount, msg.sender);
    }



    /*
    Function to set verification status of Land
    Only Inspector can call this function
    */
    function verifyLand
    (
        uint _landId,
        bool _status
    ) public onlyInspector
    {
        Lands[_landId].isVerified = _status;
    }

    
    /*
    Function to register or update Buyer
    Caller of the function should not be registered as Seller
    Inspector can not call his function
    Anyone can call this function
    */
    function registerOrUpdateBuyer
    (
        string memory _Name,
        uint _Age,
        string memory _City,
        uint _CNIC,
        string memory _Email
    ) public
    {
        require(msg.sender != Inspector.id, "Inspector can not be Buyer");
        require(SellerMapping[msg.sender].flag !=1, "This person is registered as Seller");
        BuyerMapping[msg.sender] =  buyerStruct(_Name, _Age, _City, _CNIC, _Email, false, 1);
        emit buyerRegister("Buyer data is successfully saved", _Name, _Age, _City, _CNIC, _Email);
    }



    /*
    Function to set verification status of Buyer
    Only Inspector can call this function
    */
    function verifyBuyer
    (
        address _address,
        bool _status
    ) public onlyInspector
    {
        BuyerMapping[_address].isVerified = _status;
    }




    /*
    Function to transfer ownership of Land
    Only land owner can call this function
    */
    function TransferOwnership
    (
        uint _landId,
        address _address
    ) public
    {
        require(keccak256(abi.encode(landOwnerMapping[_landId])) ==
        keccak256(abi.encode(msg.sender)), "You are not the owner of this Land");

        landOwnerMapping[_landId] = _address;
        ownerMapping[msg.sender] = _landId;
        emit ownershipTransfer(msg.sender, _landId, _address);
    }




    /*
    Function to buy Land by its Land Id
    Owner of Land can not buy it
    Caller of function should be a verified Buyer
    Owner of land should be a verified Seller
    Land must be verified
    Price sent by Buyer must be equal to Land Price
    */
    function BuyLand
    (
        uint _landId
    ) public payable
    {
        require(landOwnerMapping[_landId] != msg.sender, "You can not Buy Land because you are the Owner");
        require(BuyerMapping[msg.sender].isVerified == true, "Buyer is not verified");
        require(SellerMapping[landOwnerMapping[_landId]].isVerified == true, "Seller is not verified");
        require(Lands[_landId].isVerified == true, "Land is not verified");

        if (msg.value > Lands[_landId].LandPrice*1000000000000000000)
        {
            payable(msg.sender).transfer(address(this).balance);
            emit buyingLand("Land not bought, sent more Ethers than Land price",
            _landId, Lands[_landId].LandPrice, landOwnerMapping[_landId], msg.sender);
        }

        else if (msg.value < Lands[_landId].LandPrice*1000000000000000000)
        {
            payable(msg.sender).transfer(address(this).balance);
            emit buyingLand("Land not bought, sent less Ethers than Land price",
            _landId, Lands[_landId].LandPrice, landOwnerMapping[_landId], msg.sender);
        }

        else
        {
            payable(landOwnerMapping[_landId]).transfer(msg.value);
            landOwnerMapping[_landId] = msg.sender;
            ownerMapping[msg.sender] = _landId;
            emit buyingLand("Land bought successfully",
            _landId, Lands[_landId].LandPrice, landOwnerMapping[_landId], msg.sender);
        }
    }

    
    
    
    /*
    Function to check Land Owner by Land Id
    Anyone can call this function
    */
    function LandOwner
    (
        uint _landId
    ) public view returns(address _address)
    {
        return landOwnerMapping[_landId];
    }

    
    
    /*
    Function to check either Land is verified or not by Land Id
    Anyone can call this function
    */
    function LandIsVerified
    (
        uint _landId
    ) public view returns(bool)
    {
        return Lands[_landId].isVerified;
    }

    
    
    /*
    Function to check either Seller is verified or not by its Address
    Anyone can call this function
    */
    function SellerIsVerified
    (
        address _address
    ) public view returns(bool)
    {
        return SellerMapping[_address].isVerified;
    }

    
    
    /*
    Function to check either Buyer is verified or not by its Address
    Anyone can call this function
    */
    function BuyerIsverified
    (
        address _address
    ) public view returns(bool)
    {
        return BuyerMapping[_address].isVerified;
    }

    
    
    /*
    Function to check who is the Land Inspector
    Anyone can call this function
    */
    function CheckLandInspector
    (
    
    ) public view returns (landInspectorStruct memory)
    {
        return Inspector;
    }

    
    /*
    Function to check what is the Land City by Land Id
    Anyone can call this function
    */
    function GetLandCity
    (
        uint _landId
    ) public view returns(string memory)
    {
        return Lands[_landId].City;
    }

    
    
    /*
    Function to check what is the Land Price by Land Id
    Anyone can call this function
    */
    function GetLandPrice
    (
        uint _landId
    ) public view returns(uint)
    {
        return Lands[_landId].LandPrice;
    }

    
    
    /*
    Function to check what is the area of Land by Land Id
    Anyone can call this function
    */
    function GetLandArea
    (
        uint _landId
    ) public view returns(uint)
    {
        return Lands[_landId].Area;
    }



    /*
    Function to check is caller of function a Buyer
    Anyone can call this function
    */
    function isBuyer
    (

    ) public view returns(bool)
    {
        if (BuyerMapping[msg.sender].flag == 1)
        {
        return true;
        }

        else
        {
            return false;
        }
    }


    
    /*
    Function to check is caller of function a Selller
    Anyone can call this function
    */
    function isSeller
    (

    ) public view returns(bool)
    {
        if (SellerMapping[msg.sender].flag == 1)
        {
            return true;
        }

        else
        {
            return false;
        }
    }

}
