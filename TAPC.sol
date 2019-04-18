
pragma solidity ^0.4.11;
contract TAPContract{
    address public owner;
    address public oia;
    string public str;
    
    //生產紀錄
    struct Recordinfo{
        string r_memo;          //紀錄說明(施肥或灌溉...)
        string r_name;          //肥料商名稱...
        uint r_UBN;             //公司統一編號Unified Business No. 
        uint nowtime;           //時間
    }
    
    //註冊、種子資訊、檢驗結果
    struct Register{
        address reguseraddr;    //註冊者位址
        uint farm_num;          //土地代碼
        string s_name;          //種子名稱
        string sd_name;         //種子商名稱
        uint sd_UBN;            //公司統一編號Unified Business No. 
        address OIAaddr;        //有機檢驗機構位址
        uint nowtime;           //時間
        uint num;
        bool resstate;       //新增檢驗結果狀態
        bool res;               //檢驗結果
        mapping(uint => Recordinfo) recordinfo;
    }
    
    mapping (uint => Register) public register;
    
    //註冊
    function regTAP(uint _farm_num, string _s_name, string _sd_name, uint _sd_UBN, address _OIAaddr) public{
        if(register[_farm_num].farm_num == 0){
            owner = msg.sender;
            oia = _OIAaddr;
            register[_farm_num] = Register(owner, _farm_num, _s_name, _sd_name, _sd_UBN, oia, now, 0, false, false);
            //check
            if(register[_farm_num].farm_num == _farm_num)
                str = 'regTAP success!!!';
            else
                str = 'regTAP failure!!!';
        }
        else
            str = 'farm_num repeat!!!';
    }
    
    //更新生產紀錄
    function updataTAP(uint _farm_num, string _r_memo, string _r_name, uint _r_UBN) public{
        owner = msg.sender;
        //此土地代碼是否有註冊
        if(register[_farm_num].farm_num == 0)
            str = 'farm_num no register';
        else{
            //check access
            if(register[_farm_num].reguseraddr == owner){
                Register r = register[_farm_num];
                r.recordinfo[r.num++] = Recordinfo({r_memo: _r_memo, r_name: _r_name, r_UBN: _r_UBN, nowtime: now});
                //check
                if(keccak256(r.recordinfo[r.num-1].r_memo) == keccak256(_r_memo))
                    str = 'updataTAP success!!!';
                else
                    str = 'updataTAP failure!!!';        
            }
            else
                str = 'Permission denied!!!';
        }
    }
    
    //新增檢驗結果(只能執行一次)
    function addResult(uint _farm_num, bool _res) public{
        oia = msg.sender;
        Register r = register[_farm_num];
        //此土地代碼是否有註冊
        if(r.farm_num == 0)
            str = 'farm_num no register';
        else{
            //check access
            if(r.OIAaddr == oia){
                //檢查是否已新增檢驗結果
                if(r.resstate == false){
                    //檢查是否有生產紀錄
                    if(r.num > 0){                             
                        r.res = _res;    
                        r.resstate = true;
                        str = 'addResult success!!!';    
                    }
                    else
                        str = 'No production record!!!';
                }
                else
                    str = 'test results have been completed!!!';
            }
            else
                str = 'Permission denied';
        }
    }
    
    //view
    function viewTAP(uint _farm_num, uint num) public constant returns(string , string, string ,string, string, uint, string, uint){
        Register r = register[_farm_num];
        return ('Record description:', r.recordinfo[num-1].r_memo, 'Company name:', r.recordinfo[num-1].r_name, 'Company uniform number:', r.recordinfo[num-1].r_UBN, 'Time:', r.recordinfo[num-1].nowtime);        
    }
}