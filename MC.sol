
pragma solidity ^0.4.11;
contract ManageContract{
    string public str;
    struct Manage{
        string str;
    }
   
    mapping(string => Manage) manage;
    
    function addCon(string _ov_ID) {
        Manage m = manage[_ov_ID];
        m.str = 'Not yet traded (尚未交易)';
        str = manage[_ov_ID].str;
    }
    
    function updateMan(string _ov_ID){
        Manage m = manage[_ov_ID];
        m.str = 'Uncollected (未收款)';
        str = manage[_ov_ID].str;
        
    }
    
    function updateMan2(string _ov_ID){
        manage[_ov_ID].str = 'Transaction complete (交易完成)';
        str = manage[_ov_ID].str;
    }
    
    function updateMan3(string _ov_ID){
        manage[_ov_ID].str = 'dispute (爭議階段)';
        str = manage[_ov_ID].str;
    }
    
}