// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "https://github.com/cletNS/interfaces/blob/master/ICustomResolver.sol";

contract SubNS is Ownable {
    struct Resolver {
        string baseTicker;
        string tickerName;
        string tickerIcon;
        string ticker;
    }

    Resolver[] public s_Resolver;
    address public CletCoreContract;

    function setEssentials(address _address) public onlyOwner {
        CletCoreContract = _address;
    }

    function setEssentials(
        string memory _baseTicker,
        string memory _tickerName,
        string memory _tickerIcon,
        string memory _ticker
    ) public onlyOwner {
        s_Resolver.push(
            Resolver(
                string.concat(".", _baseTicker),
                _tickerName,
                _tickerIcon,
                _ticker
            )
        );
    }

    function updateEssentials(
        uint256 _index,
        string memory _baseTicker,
        string memory _tickerName,
        string memory _tickerIcon,
        string memory _ticker
    ) public onlyOwner {
        s_Resolver[_index].baseTicker = string.concat(".", _baseTicker);
        s_Resolver[_index].tickerName = _tickerName;
        s_Resolver[_index].tickerIcon = _tickerIcon;
        s_Resolver[_index].ticker = _ticker;
    }

    /// @dev Do not include the ticker
    function getResolve(string memory _name, uint256 _resolverIndex)
        public
        view
        returns (ICustomResolver.MappedAddress memory)
    {
        ICustomResolver.MappedAddress memory ma = ICustomResolver(
            CletCoreContract
        ).resolve(string.concat(_name, s_Resolver[_resolverIndex].baseTicker));
        ICustomResolver.Ticker memory ticker;
        ticker.name = s_Resolver[_resolverIndex].tickerName;
        ticker.ticker = s_Resolver[_resolverIndex].ticker;
        ticker.icon = s_Resolver[_resolverIndex].tickerIcon;
        ticker.tag = "crypto"; //optional
        ma.ticker = ticker;
        return ma;
    }

    /// @notice Returns the name belonging to a mapped information
    function reverseLookup(string memory _addess, uint256 _resolverIndex)
        public
        view
        returns (string memory)
    {
        string memory name_ex = ICustomResolver(CletCoreContract).reverseLookup(
            _addess
        );
        bytes memory _nex = bytes(name_ex);
        uint256 _len = _nex.length -
            bytes(s_Resolver[_resolverIndex].baseTicker).length +
            1;
        bytes memory trimmed_bytes = new bytes(_len);
        for (uint i = 0; i < _len; i++) {
            trimmed_bytes[i] = _nex[i];
        }
        return
            string.concat(
                string(trimmed_bytes),
                s_Resolver[_resolverIndex].ticker
            );
    }
}
