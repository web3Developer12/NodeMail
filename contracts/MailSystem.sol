//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "hardhat/console.sol";

contract MailSystem {

    struct Mail {

        address _from;
        address _to;
        string  _subject;
        string  _markdown;
        uint256 _timeStamp;
        uint256 _index  ;

        bool    _inbox  ;
        bool    _starred;
        bool    _archive;
        bool    _sent   ;
        bool    _read   ;
        bool    _spam   ;
        bool    _trash  ;
        bool    _tracked;

    }

    mapping(address => Mail[]) mails;
    mapping(address => uint256) uid;
    mapping(address => bool)   scam;
    uint256 global_index  = 0;

    function compose(
        address _to,string calldata _subject,string calldata _markdown
    )external{
        Mail memory _newMail = Mail(
            msg.sender,_to,_subject,_markdown,block.number,global_index,false,false,false,false,false,false,false,false
        );
        _newMail._inbox = true;
        mails[_to].push(_newMail);

        _newMail._inbox = false;
        _newMail._sent  = true;
        global_index ++;
        _newMail._index = global_index;
        mails[msg.sender].push(_newMail);
        global_index++;

    }

    function move(string calldata _to,uint256[] memory _indexes) external {
        
            
            if(keccak256(abi.encodePacked(_to)) == keccak256(abi.encodePacked("STAR"))){
                uint256 size = _indexes.length;
                for(uint256 i=0;i<size;i++){
                    uint position = _indexes[i];
                    mails[msg.sender][position]._starred = !mails[msg.sender][position]._starred;
                }

            }
            else if(keccak256(abi.encodePacked(_to)) == keccak256(abi.encodePacked("ARCHIVE"))){
                uint256 size = _indexes.length;
                for(uint256 i=0;i<size;++i){
                    uint index = _indexes[i];
                    mails[msg.sender][index]._inbox   = false;
                    mails[msg.sender][index]._spam    = false;
                    mails[msg.sender][index]._archive = !mails[msg.sender][index]._archive;
                }
            }
            else if(keccak256(abi.encodePacked(_to)) == keccak256(abi.encodePacked("SPAM"))){
                uint256 size = _indexes.length;
                for(uint256 i=0;i<size;++i){
                    uint index = _indexes[i];
                    mails[msg.sender][index]._inbox   = false;
                    mails[msg.sender][index]._archive = false;
                    mails[msg.sender][index]._spam    = !mails[msg.sender][index]._spam;
                }
            }
            else if(keccak256(abi.encodePacked(_to)) == keccak256(abi.encodePacked("READ"))){
                uint256 size = _indexes.length;
                for(uint256 i=0;i<size;++i){
                    uint index = _indexes[i];
                    mails[msg.sender][index]._read    = !mails[msg.sender][index]._read;

                }
            }
            else if(keccak256(abi.encodePacked(_to)) == keccak256(abi.encodePacked("TRASH"))){
                uint256 size = _indexes.length;
                for(uint256 i=0;i<size;++i){
                    uint index = _indexes[i];
                    mails[msg.sender][index]._inbox   = false;

                    if(mails[msg.sender][index]._trash == false){
                        mails[msg.sender][index]._trash   = true;
                    }else{
                        mails[msg.sender][index]._trash   = true;
                        mails[msg.sender][index]._tracked = true;
                    }
                }
            }
            
        
    }

    function inbox() external view returns(Mail[] memory){
        
        Mail[] storage _mails = mails[msg.sender];
        uint size = _mails.length;
        uint validSize = 0;

        // Count the number of valid elements
        for (uint i = 0; i < size; i++) {
            if (_mails[i]._inbox && _mails[i]._timeStamp != 0 && _mails[i]._tracked == false) {
                validSize++;
            }
        }

        Mail[] memory data = new Mail[](validSize);

        // Add only the valid elements to the data array
        uint j = 0;
        for (uint i = 0; i < size; i++) {
            if (_mails[i]._inbox && _mails[i]._timeStamp != 0 && _mails[i]._tracked == false) {
                data[j] = _mails[i];
                j++;
            }
        }

        return data;
    }

    function sent() external view returns(Mail[] memory){
        
        Mail[] storage _mails = mails[msg.sender];
        uint size = _mails.length;
        uint validSize = 0;

        // Count the number of valid elements
        for (uint i = 0; i < size; i++) {
            if (_mails[i]._sent && _mails[i]._timeStamp != 0 && _mails[i]._tracked == false) {
                validSize++;
            }
        }

        Mail[] memory data = new Mail[](validSize);

        // Add only the valid elements to the data array
        uint j = 0;
        for (uint i = 0; i < size; i++) {
            if (_mails[i]._sent && _mails[i]._timeStamp != 0 && _mails[i]._tracked == false) {
                data[j] = _mails[i];
                j++;
            }
        }

        return data;
    }

    function archive() external view returns(Mail[] memory){
        
        Mail[] storage _mails = mails[msg.sender];
        uint size = _mails.length;
        uint validSize = 0;

        // Count the number of valid elements
        for (uint i = 0; i < size; i++) {
            if (_mails[i]._archive && _mails[i]._timeStamp != 0 && _mails[i]._tracked == false) {
                validSize++;
            }
        }

        Mail[] memory data = new Mail[](validSize);

        // Add only the valid elements to the data array
        uint j = 0;
        for (uint i = 0; i < size; i++) {
            if (_mails[i]._archive && _mails[i]._timeStamp != 0 && _mails[i]._tracked == false) {
                data[j] = _mails[i];
                j++;
            }
        }

        return data;
    }

    function star() external view returns(Mail[] memory){
        
        Mail[] storage _mails = mails[msg.sender];
        uint size = _mails.length;
        uint validSize = 0;

        // Count the number of valid elements
        for (uint i = 0; i < size; i++) {
            if (_mails[i]._starred && _mails[i]._timeStamp != 0 && !_mails[i]._archive && _mails[i]._tracked == false) {
                validSize++;
            }
        }

        Mail[] memory data = new Mail[](validSize);

        // Add only the valid elements to the data array
        uint j = 0;
        for (uint i = 0; i < size; i++) {
            if (_mails[i]._starred && _mails[i]._timeStamp != 0 && !_mails[i]._archive && _mails[i]._tracked == false) {
                data[j] = _mails[i];
                j++;
            }
        }

        return data;
    }
    
    function spam() external view returns(Mail[] memory){
        
        Mail[] storage _mails = mails[msg.sender];
        uint size = _mails.length;
        uint validSize = 0;

        // Count the number of valid elements
        for (uint i = 0; i < size; i++) {
            if (_mails[i]._spam && _mails[i]._timeStamp != 0 && _mails[i]._tracked == false) {
                validSize++;
            }
        }

        Mail[] memory data = new Mail[](validSize);

        // Add only the valid elements to the data array
        uint j = 0;
        for (uint i = 0; i < size; i++) {
            if (_mails[i]._spam && _mails[i]._timeStamp != 0 && _mails[i]._tracked == false) {
                data[j] = _mails[i];
                j++;
            }
        }

        return data;
    }
    function trash() external view returns(Mail[] memory){
        
        Mail[] storage _mails = mails[msg.sender];
        uint size = _mails.length;
        uint validSize = 0;

        // Count the number of valid elements
        for (uint i = 0; i < size; i++) {
            if (_mails[i]._trash && _mails[i]._timeStamp != 0 && _mails[i]._tracked == false) {
                validSize++;
            }
        }

        Mail[] memory data = new Mail[](validSize);

        // Add only the valid elements to the data array
        uint j = 0;
        for (uint i = 0; i < size; i++) {
            if (_mails[i]._trash && _mails[i]._timeStamp != 0 && _mails[i]._tracked == false) {
                data[j] = _mails[i];
                j++;
            }
        }

        return data;
    }

    function chain() external view returns(Mail[] memory){
        return mails[msg.sender];
    }
    


   
   
}
