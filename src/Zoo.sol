// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Zoo
 * @author Chukwubuike Victory Chime GH/Twitter: @yeahChibyke
 * @notice Animals are represented in the Zoo as on-chain NFTs. They get upgraded to the Jungle contract
 *
 * ░▒▓████████▓▒░░▒▓██████▓▒░ ░▒▓██████▓▒░
 *        ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
 *      ░▒▓██▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
 *    ░▒▓██▓▒░  ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
 *  ░▒▓██▓▒░    ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
 * ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
 * ░▒▓████████▓▒░░▒▓██████▓▒░ ░▒▓██████▓▒░
 */

// ------------------------------------------------------------------
//                             IMPORTS
// ------------------------------------------------------------------
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
// import {Base64NFTUpgradeable} from "@openzeppelin/contracts-upgradeable/mocks/docs/utilities/Base64NFTUpgradeable.sol";

contract Zoo is Initializable, UUPSUpgradeable, ERC721Upgradeable, OwnableUpgradeable {
    // ------------------------------------------------------------------
    //                              ERRORS
    // ------------------------------------------------------------------
    error ZOO__ZeroAddress();
    error Zoo__CubsNotComplete();
    error Zoo__UnAuthorized();
    error Zoo__NotACub();

    // ------------------------------------------------------------------
    //                             STORAGE
    // ------------------------------------------------------------------
    string[] private s_cubsUri;
    mapping(string cub => string cubUri) cubToUri;
    address zooKeeper;
    uint8 private s_hp;
    mapping(string cub => uint8 feedingCount) private s_feedingCount;
    mapping(string cub => string health) private s_healthBar;

    // ------------------------------------------------------------------
    //                             MODIFIER
    // ------------------------------------------------------------------
    modifier onlyKeeper() {
        if (msg.sender != zooKeeper) {
            revert Zoo__UnAuthorized();
        }
        _;
    }

    // ------------------------------------------------------------------
    //                           INITIALIZER
    // ------------------------------------------------------------------
    function initialize(address _keeper, string[] memory cubsUri) public initializer {
        if (_keeper == address(0)) {
            revert ZOO__ZeroAddress();
        }
        if (cubsUri.length <= 0) {
            revert Zoo__CubsNotComplete();
        }
        zooKeeper = _keeper;
        s_cubsUri = cubsUri;

        __ERC721_init("Zoo", "ZZOO");
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }

    // ------------------------------------------------------------------
    //                        EXTERNAL FUNCTIONS
    // ------------------------------------------------------------------
    function feedCubs(string memory _cub) external onlyKeeper {
        // check that cub exists
        s_feedingCount[_cub] += 1;
    }

    // ------------------------------------------------------------------
    //                             PUBLIC FUNCTIONS
    // ------------------------------------------------------------------

    // ------------------------------------------------------------------
    //                             INTERNAL FUNCTIONS
    // ------------------------------------------------------------------
    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function _helperURI(string memory _cub) internal view returns (string memory) {
        // require _cub is a valid cub
        string memory imageURI = cubToUri[_cub];
        uint8 feedingCount = s_feedingCount[_cub];
        string memory health = s_healthBar[_cub];

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    abi.encodePacked(
                        '{"name":"',
                        _cub,
                        '", "description":"A cute animal cub from the Zoo!", ',
                        '"attributes": [',
                        '{"trait_type": "feeding_count", "value": ',
                        Strings.toString(feedingCount),
                        "},",
                        '{"trait_type": "health", "value": "',
                        health,
                        '"}',
                        '], "image":"',
                        imageURI,
                        '"}'
                    )
                )
            )
        );
    }

    // ------------------------------------------------------------------
    //                         GETTER FUNCTIONS
    // ------------------------------------------------------------------
    function getNumberCubs() external view returns (uint256) {
        return s_cubsUri.length;
    }

    function getCubURI(string memory _cub) external view returns (string memory) {
        return _helperURI(_cub);
    }

    // ------------------------------------------------------------------
    //              REQUIRED OVERRIDE FOR UUPSUPGRADEABLE
    // ------------------------------------------------------------------
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
