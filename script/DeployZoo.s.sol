// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Zoo} from "../src/Zoo.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployZoo is Script {
    Zoo public zooImplementation;
    ERC1967Proxy public proxy;
    address keeper = makeAddr("keeper");

    string bearSVG = vm.readFile("./img/bear.svg");
    string elephantSVG = vm.readFile("./img/elephant.svg");
    string leopardSVG = vm.readFile("./img/leopard.svg");
    string monkeySVG = vm.readFile("./img/monkey.svg");
    string snakeSVG = vm.readFile("./img/snake.svg");
    string wolfSVG = vm.readFile("./img/wolf.svg");

    string bearURI = svgToImageURI(bearSVG);
    string elephantURI = svgToImageURI(elephantSVG);
    string leopardURI = svgToImageURI(leopardSVG);
    string monkeyURI = svgToImageURI(monkeySVG);
    string snakeURI = svgToImageURI(snakeSVG);
    string wolfURI = svgToImageURI(wolfSVG);

    string bearCub = "bearCub";
    string elephantCub = "elephantCub";
    string leopardCub = "leopardCub";
    string monkeyCub = "monkeyCub";
    string snakeCub = "snakeCub";
    string wolfCub = "wolfCub";

    function run() external returns (address proxyAddress) {
        proxyAddress = deployZoo();
        return proxyAddress;
    }

    function deployZoo() public returns (address) {
        string[] memory types = new string[](6);
        types[0] = bearCub;
        types[1] = elephantCub;
        types[2] = leopardCub;
        types[3] = monkeyCub;
        types[4] = snakeCub;
        types[5] = wolfCub;

        string[] memory uris = new string[](6);
        uris[0] = bearURI;
        uris[1] = elephantURI;
        uris[2] = leopardURI;
        uris[3] = monkeyURI;
        uris[4] = snakeURI;
        uris[5] = wolfURI;

        vm.startBroadcast();
        zooImplementation = new Zoo();
        proxy = new ERC1967Proxy(address(zooImplementation), "");
        Zoo(address(proxy)).initialize(keeper, types, uris);
        vm.stopBroadcast();

        return address(proxy);
    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }
}
