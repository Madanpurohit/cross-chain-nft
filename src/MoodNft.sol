// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721 {
    //Error
    error MoodNft__notOwner();
    error MoodNft__invalidAddress();
    enum Mood {
        HAPPY,
        SAD
    }
    uint256 private s_count;
    string private s_happy_mood_img;
    string private s_sad_mood_img;
    mapping(uint256 => Mood) private s_counter_mood_mapping;

    constructor(
        string memory happy,
        string memory sad
    ) ERC721("MoodNft", "MDN") {
        s_count = 0;
        s_happy_mood_img = happy;
        s_sad_mood_img = sad;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }
    function flipMood(uint256 token) external {
        if(ownerOf(token) != msg.sender){
            revert MoodNft__notOwner();
        }
        if(s_counter_mood_mapping[token] == Mood.HAPPY){
            s_counter_mood_mapping[token] = Mood.SAD;
        } else{
            s_counter_mood_mapping[token] = Mood.HAPPY;
        }
    }
    function mintNft(address creator) external {
        if(creator == address(0)){
            revert MoodNft__invalidAddress();
        }
        _safeMint(creator, s_count);
        s_counter_mood_mapping[s_count] = Mood.HAPPY;
        s_count++;
    }

    function tokenURI(
        uint256 token
    ) public view override returns (string memory) {
        string memory imageURI = s_happy_mood_img;
        if(s_counter_mood_mapping[token] == Mood.SAD){
            imageURI = s_sad_mood_img;
        }
        return
            string(
                abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes( // bytes casting actually unnecessary as 'abi.encodePacked()' returns a bytes
                        abi.encodePacked(
                            '{"name":"',
                            name(), // You can add whatever name here
                            '", "description":"An NFT that reflects the mood of the owner, 100% on Chain!", ',
                            '"attributes": [{"trait_type": "moodiness", "value": 100}], "image":"',
                            imageURI,
                            '"}'
                        )
                    )
                )
            )
            );
    }

    /**Getters */
    function getHappyMoodSvg() external view returns(string memory){
        return s_happy_mood_img;
    }
}
