// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Chat {

    struct Friend {
        string name;
        address add;
    }

    struct User {
        string name;
        Friend[] friendlist;
    }

    struct Message {
        address sender;
        uint256 timestamp;
        string msgcon;
    }

    Message[] public msgsbtw;
    mapping(address => User) public accounts;
    mapping(bytes32 => Message[]) allmessages;

    function viewMessagesBetweenTwo(address _raddress) public view returns (Message[] memory) {
        bytes32 hash = _getChatCode(_raddress);
        return allmessages[hash];
    }

    function userExists(address _address) public view returns (bool) {
        return bytes(accounts[_address].name).length > 0;
    }

    function createUser(string memory _name) public {
        require(!userExists(msg.sender), "You already have an account");
        require(bytes(_name).length != 0, "Enter a valid name");
        accounts[msg.sender].name = _name;
    }

    function getUserName() public view returns (string memory) {
        return accounts[msg.sender].name;
    }

    function addFriend(address _faddress, string memory _name) public {
        require(!checkAlreadyFriends(_faddress), "You both are already friends");
        require(_faddress != msg.sender, "You can't friend yourself");
        require(userExists(_faddress), "Friend doesn't have an account");
        require(keccak256(bytes(accounts[_faddress].name)) == keccak256(bytes(_name)), "Invalid name for the given address");

        accounts[msg.sender].friendlist.push(Friend(_name, _faddress));
        accounts[_faddress].friendlist.push(Friend(accounts[msg.sender].name, msg.sender));
    }

    function checkAlreadyFriends(address _faddress) public view returns (bool) {
        for (uint i = 0; i < accounts[_faddress].friendlist.length; i++) {
            if (accounts[_faddress].friendlist[i].add == msg.sender) {
                return true;
            }
        }
        return false;
    }

    function getMyFriends() public view returns (Friend[] memory) {
        return accounts[msg.sender].friendlist;
    }

    function _getChatCode(address _raddress) public view returns (bytes32) {
        return bytes32(abi.encodePacked(msg.sender > _raddress ? (msg.sender, _raddress) : (_raddress, msg.sender)));
    }

    function sendMessage(address _raddress, string memory _message) public {
        require(userExists(msg.sender), "Create an account to send a message");
        require(userExists(_raddress), "Recipient doesn't have an account");
        require(checkAlreadyFriends(_raddress), "Only friends can send messages");
        require(bytes(_message).length > 0, "Enter a valid message");

        bytes32 hash = _getChatCode(_raddress);
        allmessages[hash].push(Message(msg.sender, block.timestamp, _message));
    }

    function readMessages(address _raddress) public view returns (Message[] memory) {
        bytes32 hash = _getChatCode(_raddress);
        return allmessages[hash];
    }
}
