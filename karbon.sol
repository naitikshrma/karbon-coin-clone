// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * PLEASE DO NOT USE THIS CODE IN PRODUCTION.
 */

 library SafeMath {

        function add(uint256 a, uint256 b) internal pure returns (uint256) {
            uint256 c = a + b;
            require(c >= a, "SafeMath: addition overflow");

            return c;
        }

        function sub(uint256 a, uint256 b) internal pure returns (uint256) {
            return sub(a, b, "SafeMath: subtraction overflow");
        }

        function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
            require(b <= a, errorMessage);
            uint256 c = a - b;

            return c;
        }

        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            if (a == 0) {
                return 0;
            }

            uint256 c = a * b;
            require(c / a == b, "SafeMath: multiplication overflow");

            return c;
        }

        function div(uint256 a, uint256 b) internal pure returns (uint256) {
            return div(a, b, "SafeMath: division by zero");
        }

        function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
            require(b > 0, errorMessage);
            uint256 c = a / b;
            // assert(a == b * c + a % b); // There is no case in which this doesn't hold
            return c;
        }

        function mod(uint256 a, uint256 b) internal pure returns (uint256) {
            return mod(a, b, "SafeMath: modulo by zero");
        }

        function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
            require(b != 0, errorMessage);
            return a % b;
        }
    }

     interface IERC20 {

        function totalSupply() external view returns (uint256);
        function balanceOf(address account) external view returns (uint256);
        function transfer(address recipient, uint256 amount) external returns (bool);
        function allowance(address owner, address spender) external view returns (uint256);
        function approve(address spender, uint256 amount) external returns (bool);
        function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
        
    }



contract APIConsumer  {
     using SafeMath for int56;
     using SafeMath for uint256;

    AggregatorV3Interface internal USDpriceFeed;
    AggregatorV3Interface internal ETHpriceFeed;
    AggregatorV3Interface internal BNBpriceFeed;
    AggregatorV3Interface internal BTCpriceFeed;
    AggregatorV3Interface internal  MaticpriceFeed;
    

    uint256 usdPrice = 18;
    uint256 tokenDecimal = 18;
    address payable wallet;
    address _BNB = 0xD9AB77834aC5D8d1f4FDAF26E314496A2E19cA8D;
    address token = 0x8A583aacB750344A4B278D6AE25bC744F8911BA8 ;

    constructor() {
        ETHpriceFeed = AggregatorV3Interface(0x0715A7794a1dc8e42615F059dD6e406A6594651A);
        // polygon test - DAI/USD
        BNBpriceFeed = AggregatorV3Interface(0x0FCAa9c899EC5A91eBc3D5Dd869De833b06fB046);
        BTCpriceFeed = AggregatorV3Interface(0x007A22900a3B98143368Bd5906f8E17e9867581b);
        MaticpriceFeed=AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada);
        
        wallet = payable(msg.sender);
    }


    modifier onlyOwner() {
        require(msg.sender == wallet,"Sender is not the Owner");
        _;
    }

    function getMaticLatestPrice() public view returns (uint256) {
    (
        uint80 roundID, 
        int price,
        uint startedAt,
        uint timeStamp,
        uint80 answeredInRound
    ) = MaticpriceFeed.latestRoundData();
        return uint256(price);
    }
   
   function getETHLatestPrice() public view returns (uint256) {
    (
        uint80 roundID, 
        int price,
        uint startedAt,
        uint timeStamp,
        uint80 answeredInRound
    ) = ETHpriceFeed.latestRoundData();
        return uint256(price);
    }

     function getBNBLatestPrice() public view returns (uint256) {
    (
        uint80 roundID, 
        int price,
        uint startedAt,
        uint timeStamp,
        uint80 answeredInRound
    ) = BNBpriceFeed.latestRoundData();
        return uint256(price);
    }

     function getBTCLatestPrice() public view returns (uint256) {
    (
        uint80 roundID, 
        int price,
        uint startedAt,
        uint timeStamp,
        uint80 answeredInRound
    ) = BTCpriceFeed.latestRoundData();
        return uint256(price);
    }


    function setUsdPrice(uint256 price) public onlyOwner returns(bool) {
        usdPrice = price;
        return true;
    }

    function icoToUSD(uint256 icoToken) public view returns (uint256){
        return icoToken.mul(usdPrice).mul(10**18);
    }
                                                                                                
    function BuyFromBNB(uint256 ico) public returns(uint256){
        uint256 bnbAmount =  (BNBForICO(ico) * 1 gwei) / 10;
        IERC20(_BNB).transferFrom(msg.sender,wallet,bnbAmount);
        IERC20(token).transferFrom(wallet,msg.sender,ico * 1 ether);
    }

    function BuyFromEth(uint256 ico) public returns(uint256){
        uint256 EthAmount =   EthForICO(ico) * 1 gwei / 10;
        IERC20(_BNB).transferFrom(msg.sender,wallet,EthAmount);
        IERC20(token).transferFrom(wallet,msg.sender,ico * 1 ether);
    }

    function BuyFromMatic(uint256 ico) public payable returns(uint256){
        address payable recipient = payable(msg.sender);
        uint256 matic = MaticForICO(ico)* 1 gwei / 10;
        wallet.transfer(matic);
        IERC20(token).transfer(recipient,ico * 1 ether);
    } 

    function ICOForETH(uint bnb) public returns(uint256){
        return (getETHLatestPrice().div(18));
    }

   function BNBForICO(uint256 ico) public  view returns(uint256){
         return (1 ether * calculateDollarForICO(ico) / getBNBLatestPrice() );
    }     


    function MaticForICO(uint256 ico) public view returns(uint256){
          return (1 ether * calculateDollarForICO(ico) / getMaticLatestPrice() );
    }


    function EthForICO(uint256 ico) public  view returns(uint256){
         return (1 ether * calculateDollarForICO(ico) / getETHLatestPrice() );
    }                                                                                                                                 
                                                                                                                            
    function calculateDollarForICO(uint256 ico) public view returns(uint256){
          return (ico*usdPrice);
    }


    function changeOwner(address payable _newOwner) public onlyOwner {
        wallet = _newOwner;
    }

    function changeTokenAddress(address _newaddress) public onlyOwner{
        token = _newaddress;
    }
    function conversion(uint amt) public view returns(uint)
    {
        uint m = getMaticLatestPrice(); // 65751975
        uint usd = 1/m; // 1/65751975 
        uint mat = usd * usdPrice;
        uint total = amt * mat;
    }


    
    
}


