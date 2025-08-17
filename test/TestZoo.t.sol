// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Zoo} from "../src/Zoo.sol";
import {DeployZoo} from "../script/DeployZoo.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract TestZoo is Test {
    DeployZoo zoo;
    address zooKeeper;
    address alice;
    address proxyAddress;

    string bearCub;
    string elephantCub;
    string leopardCub;
    string monkeyCub;
    string snakeCub;
    string wolfCub;

    function setUp() public {
        zoo = new DeployZoo();
        zooKeeper = zoo.keeper();
        alice = makeAddr("alice");
        proxyAddress = zoo.deployZoo();

        // bearCub
    }

    function test_Zoo_Contract_Constructor() public view {
        assert(zooKeeper == Zoo(proxyAddress).getZooKeeper());
        assert(Zoo(proxyAddress).getUpgradeStatus() == false);
        assert(Zoo(proxyAddress).getTotalCubs() == 6);
    }

    function test_Only_ZooKeeper_Can_Feed_Cubs() public {
        vm.prank(alice);
        vm.expectRevert();
        Zoo(proxyAddress).feedCub(bearCub);
    }

    function test_Cannot_Feed_Uninitialized_Cub() public {
        string memory dogCub = "dog cub";
        vm.prank(zooKeeper);
        vm.expectRevert();
        Zoo(proxyAddress).feedCub(dogCub);
    }

    function test_Can_Feed_Cubs() public {
        assert(Zoo(proxyAddress).getFeedingCount(bearCub) == 0);

        vm.prank(zooKeeper);
    }
}
