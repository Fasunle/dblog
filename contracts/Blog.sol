//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Blog {
    string public name;
    address public owner;

    mapping(string => Post) private hashToPost;
    mapping(uint256 => Post) private idToPost;

    struct Post {
        uint256 id;
        string title;
        string content;
        bool published;
    }

    event PostCreated(uint256 id, string title, string _hash);
    event PostUpdated(uint256 id, string title, string _hash, bool published);

    using Counters for Counters.Counter;
    Counters.Counter private _postId;

    constructor(string memory _name) {
        console.log("Deploying blog with name: ", _name);
        name = _name;
        owner = msg.sender;
    }

    function updateName(string memory _name) public {
        name = _name;
    }

    function fetchPost(string memory _hash) public view returns (Post memory) {
        return hashToPost[_hash];
    }

    function createPost(string memory _title, string memory _hash)
        public
        onlyOwner
    {
        _postId.increment();
        uint256 postId = _postId.current();
        Post storage post = idToPost[postId];
        post.id = postId;
        post.title = _title;
        post.content = _hash;
        post.published = true;

        hashToPost[_hash] = post;
        emit PostCreated(postId, _title, _hash);
    }

    function updatePost(
        uint256 _id,
        string memory _title,
        string memory _hash,
        bool _published
    ) public onlyOwner {
        Post storage post = idToPost[_id];
        post.id = _id;
        post.title = _title;
        post.content = _hash;
        post.published = _published;

        idToPost[_id] = post;
        hashToPost[_hash] = post;
        emit PostUpdated(_id, _title, _hash, _published);
    }

    function fetchPosts() public view returns (Post[] memory) {
        uint256 itemCount = _postId.current();
        uint256 currentIndex = 0;

        Post[] memory posts = new Post[](itemCount);

        for (uint256 i = 0; i < posts.length; i++) {
            uint256 currentId = i + 1;
            Post storage currentItem = idToPost[currentId];
            posts[currentIndex] = currentItem;
            currentIndex += 1;
        }

        return posts;
    }

    function transferOwnershipTo(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}
