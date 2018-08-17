pragma solidity ^0.4.21;

contract OneMillionToken{
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c &gt;= a);
        return c;
        }
    
    struct PixelToken{
        uint256 price;
        uint24 color;
        address pixelOwner;
    }
    
    struct pixelWallet{
        mapping (uint24 =&gt; uint) indexList;
        uint24[] pixelOwned;
        uint24 pixelListlength;
        string name; 
        string link;
    }
    
    address public owner;
    
    string public constant symbol = &quot;1MT&quot;;
    string public constant name = &quot;OneMillionToken&quot;;
    uint8 public constant decimals = 0;
    
    uint private startPrice = 1000000000000000;
    
    uint public constant maxPrice = 100000000000000000000;
    uint public constant minPrice = 1000000000000;
    
    
    mapping (uint24 =&gt; PixelToken) private Image;
    
    mapping (address =&gt; pixelWallet) balance;
    
    function getPixelToken(uint24 _id) public view returns(uint256,string,string,uint24,address){
        return(Image[_id].pixelOwner == address(0) ? startPrice : Image[_id].price,balance[Image[_id].pixelOwner].name,balance[Image[_id].pixelOwner].link,Image[_id].color,Image[_id].pixelOwner);
    }
    
    function buyPixelTokenFor(uint24 _id,uint256 _price,uint24 _color, address _to) public payable returns (bool) {
        require(_id&gt;=0&amp;&amp;_id&lt;1000000);
        
        require(_price&gt;=minPrice&amp;&amp;_price&lt;=maxPrice);
        require(msg.value&gt;=minPrice&amp;&amp;msg.value&lt;=maxPrice);
        
        if(Image[_id].pixelOwner== address(0)){
            
            require(msg.value&gt;=startPrice);
            
            Transfer(owner, _to, _id);
            
            Image[_id].pixelOwner = _to;
            balance[_to].pixelOwned.push(_id);
            balance[_to].indexList[_id] = balance[_to].pixelOwned.length;
            balance[_to].pixelListlength++;
            
            require(owner.send(msg.value));
            
            Image[_id].price = _price;
            Image[_id].color = _color;
            
            ChangePixel(_id);
            
            return true;
            
        }else{
            require(msg.value&gt;=Image[_id].price);
            
            address prevOwner =Image[_id].pixelOwner; 
            
            balance[Image[_id].pixelOwner].indexList[_id] = 0;
            balance[Image[_id].pixelOwner].pixelListlength--;
            
            
            Transfer(Image[_id].pixelOwner, _to, _id);
            
            Image[_id].pixelOwner = _to;
            balance[_to].pixelOwned.push(_id);
            balance[_to].indexList[_id] = balance[_to].pixelOwned.length;
            balance[_to].pixelListlength++;
            
            require(prevOwner.send(msg.value));
            
            Image[_id].price = _price;
            Image[_id].color = _color;
            
            ChangePixel(_id);
            
            return true;
        }
    }
    
    function buyPixelToken(uint24 _id,uint256 _price,uint24 _color) public payable returns (bool){
        return buyPixelTokenFor(_id, _price, _color, msg.sender);
    }
    
    function setPixelToken(uint24 _id,uint256 _price,uint24 _color) public returns (bool){
        require(_id&gt;=0&amp;&amp;_id&lt;1000000);
        require(_price&gt;=minPrice&amp;&amp;_price&lt;=maxPrice);
        
        require(msg.sender==Image[_id].pixelOwner);
        
        Image[_id].price = _price;
        Image[_id].color = _color;
        
        ChangePixel(_id);
        
        return true;
    }
    
    function OneMillionToken() public {
        owner = msg.sender;
    }
    
    function setNameLink(string _name,string _link) public{
        balance[msg.sender].name = _name;
        balance[msg.sender].link = _link;
    }
    
    function totalSupply() public pure returns (uint) {
        return 1000000;    
    }

    function balanceOf(address _tokenOwner) public constant returns (uint){
        return balance[_tokenOwner].pixelListlength;
    }
    
    function myBalance() public view returns (uint24[]){
        uint24[] memory list = new uint24[](balance[msg.sender].pixelListlength);
        
        uint24 index = 0;
        
        for(uint24 i = 0; i &lt; balance[msg.sender].pixelOwned.length;i++){
            if(balance[msg.sender].indexList[balance[msg.sender].pixelOwned[i]]==i+1){
                list[index]=balance[msg.sender].pixelOwned[i];
                index++;
            }
        }
        return list;
    }

    function transfer(address _to, uint24 _id) public returns (bool success){
        require(_id&gt;=0&amp;&amp;_id&lt;1000000);
        require(Image[_id].pixelOwner == msg.sender);
        
        balance[Image[_id].pixelOwner].indexList[_id] = 0;
        balance[Image[_id].pixelOwner].pixelListlength--;
        
        Transfer(Image[_id].pixelOwner, _to, _id);
        
        Image[_id].pixelOwner = _to;
        
        balance[_to].pixelOwned.push(_id);
        balance[_to].indexList[_id] = balance[_to].pixelOwned.length;
        balance[_to].pixelListlength++;
        return true;
    }
    
    function pixelblockPrice (uint24 _startx,uint24 _starty,uint24 _endx,uint24 _endy) public view returns (uint){
        require(_startx&gt;=0&amp;&amp;_startx&lt;1600);
        require(_starty&gt;=0&amp;&amp;_starty&lt;625);
        require(_endx&gt;=_startx&amp;&amp;_endx&lt;1600);
        require(_endy&gt;=_starty&amp;&amp;_endy&lt;625);
        
        uint256 price = 0;
        for(uint24 x = _startx; x&lt;= _endx;x++){
            for(uint24 y = _starty;y&lt;=_endy;y++ ){
                uint24 id = y*1600+x;
                if(Image[id].pixelOwner==address(0)){
                    price=add(price,startPrice);
                }else{
                    price=add(price,Image[id].price);
                }
            }
        }
        return price;
    }
    
    function setStartPrice(uint _price) public onlyOwner returns (bool){
        
        require(_price&gt;=minPrice&amp;&amp;_price&lt;=maxPrice);
        startPrice = _price;
        return true;
    }
    
    function getStartPrice() public view returns (uint){
        return startPrice;
    }
    
    modifier onlyOwner{
        require(msg.sender==owner);
        _;
    }
    
    event ChangePixel(uint tokens);

    event Transfer(address indexed from, address indexed to, uint tokens);
}