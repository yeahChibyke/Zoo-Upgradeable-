// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * ▒███████▒ ▒█████   ▒█████      █    ██  ██▓███    ▄████  ██▀███   ▄▄▄      ▓█████▄ ▓█████ ▄▄▄       ▄▄▄▄    ██▓    ▓█████
 * ▒ ▒ ▒ ▄▀░▒██▒  ██▒▒██▒  ██▒    ██  ▓██▒▓██░  ██▒ ██▒ ▀█▒▓██ ▒ ██▒▒████▄    ▒██▀ ██▌▓█   ▀▒████▄    ▓█████▄ ▓██▒    ▓█   ▀
 * ░ ▒ ▄▀▒░ ▒██░  ██▒▒██░  ██▒   ▓██  ▒██░▓██░ ██▓▒▒██░▄▄▄░▓██ ░▄█ ▒▒██  ▀█▄  ░██   █▌▒███  ▒██  ▀█▄  ▒██▒ ▄██▒██░    ▒███
 *   ▄▀▒   ░▒██   ██░▒██   ██░   ▓▓█  ░██░▒██▄█▓▒ ▒░▓█  ██▓▒██▀▀█▄  ░██▄▄▄▄██ ░▓█▄   ▌▒▓█  ▄░██▄▄▄▄██ ▒██░█▀  ▒██░    ▒▓█  ▄
 * ▒███████▒░ ████▓▒░░ ████▓▒░   ▒▒█████▓ ▒██▒ ░  ░░▒▓███▀▒░██▓ ▒██▒ ▓█   ▓██▒░▒████▓ ░▒████▒▓█   ▓██▒░▓█  ▀█▓░██████▒░▒████▒
 * ░▒▒ ▓░▒░▒░ ▒░▒░▒░ ░ ▒░▒░▒░    ░▒▓▒ ▒ ▒ ▒▓▒░ ░  ░ ░▒   ▒ ░ ▒▓ ░▒▓░ ▒▒   ▓▒█░ ▒▒▓  ▒ ░░ ▒░ ░▒▒   ▓▒█░░▒▓███▀▒░ ▒░▓  ░░░ ▒░ ░
 * ░░▒ ▒ ░ ▒  ░ ▒ ▒░   ░ ▒ ▒░    ░░▒░ ░ ░ ░▒ ░       ░   ░   ░▒ ░ ▒░  ▒   ▒▒ ░ ░ ▒  ▒  ░ ░  ░ ▒   ▒▒ ░▒░▒   ░ ░ ░ ▒  ░ ░ ░  ░
 * ░ ░ ░ ░ ░░ ░ ░ ▒  ░ ░ ░ ▒      ░░░ ░ ░ ░░       ░ ░   ░   ░░   ░   ░   ▒    ░ ░  ░    ░    ░   ▒    ░    ░   ░ ░      ░
 *   ░ ░        ░ ░      ░ ░        ░                    ░    ░           ░  ░   ░       ░  ░     ░  ░ ░          ░  ░   ░  ░
 * ░                                                                           ░                            ░
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

// ------------------------------------------------------------------
//                             CONTRACT
// ------------------------------------------------------------------
contract Zoo is Initializable, UUPSUpgradeable, ERC721Upgradeable, OwnableUpgradeable {
    // ------------------------------------------------------------------
    //                              ERRORS
    // ------------------------------------------------------------------
    error ZOO__ZeroAddress();
    error Zoo__CubsNotComplete();
    error Zoo__UnAuthorized();
    error Zoo__NotACub();
    error Zoo__NotHealthyEnough();
    error Zoo__JungleNotSet();

    // ------------------------------------------------------------------
    //                             STORAGE
    // ------------------------------------------------------------------
    string[] private s_cubTypes;
    mapping(string => string) private cubToUri;
    mapping(string => uint8) private s_feedingCount;
    mapping(string => string) private s_healthStatus;
    mapping(string => uint8) private s_healthPoints;

    address private zooKeeper;
    address private jungleContract;
    uint256 private nextTokenId;

    // ------------------------------------------------------------------
    //                             EVENTS
    // ------------------------------------------------------------------
    event CubFed(string indexed cub, uint8 feedingCount, uint8 healthPoints, string healthStatus);
    event CubUpgraded(string indexed cub, uint256 tokenId, address jungleContract);

    // ------------------------------------------------------------------
    //                             MODIFIER
    // ------------------------------------------------------------------
    modifier onlyKeeper() {
        if (msg.sender != zooKeeper) {
            revert Zoo__UnAuthorized();
        }
        _;
    }

    modifier onlyJungle() {
        if (msg.sender != jungleContract) {
            revert Zoo__UnAuthorized();
        }
        _;
    }

    modifier validCub(string memory _cub) {
        if (bytes(cubToUri[_cub]).length == 0) {
            revert Zoo__NotACub();
        }
        _;
    }

    // ------------------------------------------------------------------
    //                           INITIALIZER
    // ------------------------------------------------------------------
    function initialize(address _keeper, string[] memory cubTypes, string[] memory cubsUri) public initializer {
        if (_keeper == address(0)) {
            revert ZOO__ZeroAddress();
        }
        if (cubsUri.length == 0 || cubTypes.length != cubsUri.length) {
            revert Zoo__CubsNotComplete();
        }

        zooKeeper = _keeper;
        s_cubTypes = cubTypes;

        // Initialize cubToUri mapping
        for (uint256 i = 0; i < cubTypes.length; i++) {
            cubToUri[cubTypes[i]] = cubsUri[i];
        }

        __ERC721_init("Zoo", "ZZOO");
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }

    // ------------------------------------------------------------------
    //                        EXTERNAL FUNCTIONS
    // ------------------------------------------------------------------
    function feedCub(string memory _cub) external onlyKeeper validCub(_cub) {
        s_feedingCount[_cub] += 1;
        uint8 healthPoints = s_feedingCount[_cub] * 10;
        s_healthPoints[_cub] = healthPoints;

        // Update health status
        if (healthPoints <= 30) {
            s_healthStatus[_cub] = "malnourished";
        } else if (healthPoints <= 60) {
            s_healthStatus[_cub] = "healthy";
        } else {
            s_healthStatus[_cub] = "vibrant";
        }

        emit CubFed(_cub, s_feedingCount[_cub], healthPoints, s_healthStatus[_cub]);
    }

    // @notice -- disregard logic in this function
    function upgradeToJungle(string memory _cub) external onlyOwner validCub(_cub) {
        if (jungleContract == address(0)) {
            revert Zoo__JungleNotSet();
        }

        // Check health status
        if (s_healthPoints[_cub] < 40) {
            revert Zoo__NotHealthyEnough();
        }

        // Mint NFT
        uint256 tokenId = nextTokenId++;
        _safeMint(jungleContract, tokenId);

        emit CubUpgraded(_cub, tokenId, jungleContract);
    }

    function setJungleContract(address _jungle) external onlyOwner {
        if (_jungle == address(0)) {
            revert ZOO__ZeroAddress();
        }
        jungleContract = _jungle;
    }

    // ------------------------------------------------------------------
    //                             INTERNAL FUNCTIONS
    // ------------------------------------------------------------------
    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function _helperURI(string memory _cub) internal view returns (string memory) {
        string memory imageURI = cubToUri[_cub];
        uint8 feedingCount = s_feedingCount[_cub];
        string memory healthStatus = s_healthStatus[_cub];
        uint8 healthPoints = s_healthPoints[_cub];

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
                        '{"trait_type": "health_points", "value": ',
                        Strings.toString(healthPoints),
                        "},",
                        '{"trait_type": "health_status", "value": "',
                        healthStatus,
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
    function getCubURI(string memory _cub) external view validCub(_cub) returns (string memory) {
        return _helperURI(_cub);
    }

    function getCubHealth(string memory _cub)
        external
        view
        validCub(_cub)
        returns (uint8 healthPoints, string memory healthStatus)
    {
        return (s_healthPoints[_cub], s_healthStatus[_cub]);
    }

    function getFeedingCount(string memory _cub) external view validCub(_cub) returns (uint8) {
        return s_feedingCount[_cub];
    }

    function getJungleContract() external view returns (address) {
        return jungleContract;
    }

    // ------------------------------------------------------------------
    //              REQUIRED OVERRIDE FOR UUPSUPGRADEABLE
    // ------------------------------------------------------------------
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
