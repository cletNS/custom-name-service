// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "https://github.com/cletNS/interfaces/blob/master/ICustomResolver.sol";

contract MyNameService is ICustomResolver, Ownable {
    address public CletCore;
    string public BaseTicker;
    string public TickerName;
    string public TickerIcon;
    string public ReturnTicker;

    /// @notice Sets/updates the essential details.
    /// @dev You can set the essential details post deploy.
    constructor() {
        setEssentials(
            0x8dee8633c228418bbB4D946946308aDDb40bBe92,
            "eth",
            "Skale",
            "https://assets-global.website-files.com/625c39b93541414104a1d654/625c68f38c04ec14737f2ad8_svg-gobbler%20(3)%201.svg",
            "skl"
        );
    }

    function setEssentials(
        address _address,
        string memory _baseTicker,
        string memory _tickerName,
        string memory _tickerIcon,
        string memory _returnTicker
    ) public onlyOwner {
        CletCore = _address;
        BaseTicker = string.concat(".", _baseTicker);
        TickerName = _tickerName;
        TickerIcon = _tickerIcon;
        ReturnTicker = _returnTicker;
    }

    /// @dev Do not include the ticker
    function resolve(string memory _name)
        public
        view
        returns (MappedAddress memory)
    {
        MappedAddress memory ma = ICustomResolver(CletCore).resolve(
            string.concat(_name, BaseTicker)
        );
        Ticker memory ticker;
        ticker.name = TickerName;
        ticker.ticker = ReturnTicker;
        ticker.icon = TickerIcon;
        ticker.tag = "crypto"; //optional
        ma.ticker = ticker;
        return ma;
    }

    /// @notice Returns the name belonging to a mapped information
    function reverseLookup(string memory _addess)
        public
        view
        returns (string memory)
    {
        string memory name_ex = ICustomResolver(CletCore).reverseLookup(
            _addess
        );
        bytes memory _nex = bytes(name_ex);
        uint256 _len = _nex.length - bytes(BaseTicker).length + 1;
        bytes memory trimmed_bytes = new bytes(_len);
        for (uint i = 0; i < _len; i++) {
            trimmed_bytes[i] = _nex[i];
        }
        return string.concat(string(trimmed_bytes), ReturnTicker);
    }
}
