
pragma solidity ^0.4.11;
contract OVContract{
    address public owner;       //目前有機蔬菜者之位址
    address public buyaddr;     //買者位址
    string public str;
    
    //銷售紀錄
    struct Record{
        uint price;             //價格
        address owner;          //擁有者之位址
        address manaddr;        //管理合約位址
    }
    
    //爭議紀錄
    struct Arguestr{
        address a_addr;         //發起者
        string str;             //爭議資訊
        uint total_price;       //有機蔬菜合約總餘額
    }
    
    //有機蔬菜資訊
    struct OVinfo{
        address tapaddr;        //生產履歷位址
        uint farm_num;          //土地代碼
        address arbitrator;     //仲裁員位址
        string ov_ID;           //有機蔬菜ID
        string ov_name;         //有機蔬菜名稱
        string ov_weight;       //有機蔬菜重量
        uint nowtime;           //時間
        uint endtime;           //有限期限
        uint num;               //交易次數
        bool state;             //是否可交易狀態
        address buyaddr;
        uint a_num;
        mapping(uint => Record) record;
        mapping(uint => Arguestr) arguestr;
    }
    
    mapping(string => OVinfo) ovinfo;
    
    //註冊有機蔬菜
    function regOV(address _tapaddr, uint _farm_num, address _arbitrator, string _ov_ID, string _ov_name, string _ov_weight, uint _price, uint _exp, address _manaddr) public returns(bool){
        if(ovinfo[_ov_ID].tapaddr == 0){
            owner = msg.sender;
            uint nowtime = now;
            uint endtime = nowtime + _exp*86400;
            ovinfo[_ov_ID] = OVinfo(_tapaddr, _farm_num, _arbitrator, _ov_ID, _ov_name, _ov_weight, nowtime, endtime , 0, true, 0, 0);
            OVinfo o = ovinfo[_ov_ID];
            o.record[o.num++] = Record({price: _price, owner: owner, manaddr: _manaddr});
            if(o.record[o.num-1].owner == owner){        //check
                str = 'regOV success!!!';
                return _manaddr.call(bytes4(keccak256('addCon(string)')), _ov_ID);       //新增至管理合約(尚未交易)
            }
            else
                str = 'regOV failure!!!';
        }
        else
            str = 'regOV failure!!!';
    }
    //交易
    function activate(string _ov_ID) public payable returns(bool){
        if(msg.sender != owner){
            OVinfo o = ovinfo[_ov_ID];
            if(o.farm_num != 0){
                if(o.a_num > 0)
                    str = "arguing...";
                else{
                    if(o.endtime > now){
                        if(o.state == true){                   //check
                            buyaddr = msg.sender;
                            o.buyaddr = buyaddr;
                            o.state = false;                    //不可交易
                            str = 'activate success!!!';
                            return o.record[o.num-1].manaddr.call(bytes4(keccak256('updateMan(string)')), _ov_ID);      //更新管理合約(未收款)   
                            
                        }
                        else{
                            str = 'activate failure!!!';
                            if(!msg.sender.send(msg.value)) 
                                throw;
                        }
                    }
                    else{
                        str = 'expired...';
                        o.state = false;                        //不可交易
                        if(!msg.sender.send(msg.value)) 
                            throw;
                    }
                }    
            }
            else{
                str = 'ov_ID no register';
                if(!msg.sender.send(msg.value)) 
                    throw;
            }
        }
        else{
            str = 'activate failure!!!';
            if(!msg.sender.send(msg.value)) 
                throw;
        }
    }
    
    //收款
    function withdraw(string _ov_ID) public returns(bool){
        OVinfo o = ovinfo[_ov_ID];
        if(o.record[o.num-1].owner == msg.sender){
            if(!msg.sender.send(this.balance))
                throw;
            else{
                o.state = true;
                o.record[o.num++] = Record({price: o.record[o.num-1].price, owner: o.buyaddr, manaddr: o.record[o.num-1].manaddr});                
                str = 'withdraw success!!!';
                return o.record[o.num-1].manaddr.call(bytes4(keccak256('updateMan2(string)')), _ov_ID);      //更新管理合約(交易完成)
            }
        }
        else
            str = 'Permission denied';
    }
    
    //修改價錢
    function editprice(string _ov_ID, uint _newprice, address _manaddr) public returns(bool){
        OVinfo o = ovinfo[_ov_ID];
        if(o.buyaddr == msg.sender){
            if(o.num > 0){      //check transactions num
                o.record[o.num++] = Record({price: _newprice, owner: msg.sender, manaddr: _manaddr});
                o.buyaddr = 0;
                str = 'editprice success!!!';
                return o.record[o.num-1].manaddr.call(bytes4(keccak256('addCon(string)')), _ov_ID);        //更新管理合約(尚未交易)
            }
            else
                str = 'editprice failure!!!';    
        }
        else
            str ='Permission denied';
    }
    
    //爭議
    function argue(string _ov_ID, string _str) public returns(bool){
        OVinfo o = ovinfo[_ov_ID];
        if(o.tapaddr != 0){
            o.state = false;  //不可交易 
            str = 'argue success!!!';
            o.arguestr[o.a_num++] = Arguestr({a_addr: msg.sender, str: _str, total_price: this.balance});
            o.arbitrator.transfer(this.balance);                                        //將餘額傳送至仲裁員
            return o.record[o.num-1].manaddr.call(bytes4(keccak256('updateMan3(string)')), _ov_ID);                       //更新管理合約(爭議階段)       
        }
        else
            str = 'No ov record';
    }
    
    //view
    function viewOC(string _ov_ID) public constant returns(uint, address, uint, string, string){
        OVinfo o = ovinfo[_ov_ID];
        return (o.record[o.num-1].price, o.record[o.num-1].owner, o.num-1, o.ov_name, o.ov_weight);
    } 
}