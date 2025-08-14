// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Zoo} from "../src/Zoo.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployZoo is Script {
    Zoo public zooImplementation;
    ERC1967Proxy public proxy;

    string bearSVG = vm.readFile("./img/bear.svg");
    string elephantSVG = vm.readFile("./img/elephant.svg");
    string leopardSVG = vm.readFile("./img/leopard.svg");
    string monkeySVG = vm.readFile("./img/monkey.svg");
    string snakeSVG = vm.readFile("./img/snake.svg");
    string wolfSVG = vm.readFile("./img/wolf.svg");

    string bearCub = "bearCub";
    string elephantCub = "elephantCub";
    string leopardCub = "leopardCub";
    string monkeyCub = "monkeyCub";
    string snakeCub = "snakeCub";
    string wolfCub = "wolfCub";

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }
}
