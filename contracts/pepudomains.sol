// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract pepudomains is Ownable, ReentrancyGuard, Pausable {
    using Strings for uint256;
    using SafeERC20 for IERC20;

    struct DomainRecord {
        address walletAddress;
        address owner;
        uint256 registrationTimestamp;
        uint256 expiryTimestamp;
        string tld;
    }

    mapping(string => mapping(string => DomainRecord)) public domains;
    mapping(address => string) public walletToDomainName;
    mapping(address => string) public walletToDomainTld;
    mapping(uint256 => uint256) public registrationFees;
    mapping(string => bool) public supportedTlds;
    address public usdcAddress;
    address public treasuryAddress;
    
    uint256 public constant MAX_NAME_LENGTH = 63;
    uint256 public constant MIN_NAME_LENGTH = 1;
    uint256 public constant MAX_BATCH_SIZE = 10;
    uint256 public constant MIN_YEARS = 1;
    uint256 public constant MAX_YEARS = 60;
    uint256 public constant DAYS_PER_YEAR = 365;

    event DomainRegistered(
        string indexed name,
        string indexed tld,
        address indexed owner,
        address walletAddress,
        uint256 registrationTimestamp,
        uint256 expiryTimestamp
    );

    event DomainRenewed(
        string indexed name,
        string indexed tld,
        uint256 expiryTimestamp
    );

    event WalletUpdated(
        string indexed name,
        string indexed tld,
        address newWallet
    );

    event RegistrationFeeUpdated(uint256 charCount, uint256 newFee);
    event TreasuryAddressUpdated(address oldTreasury, address newTreasury);
    event UsdcAddressUpdated(address oldUsdc, address newUsdc);
    event TldAdded(string tld);
    event TldRemoved(string tld);
    event BatchDomainRegistered(uint256 count);
    event DomainNameValidated(string name, bool isValid);
    event UnicodeDomainRegistered(string name, string tld, address owner);

    error DomainAlreadyExists();
    error DomainNotFound();
    error DomainExpired();
    error WalletAlreadyOwnsDomain();
    error InvalidTld();
    error InvalidYears();
    error InvalidName();
    error InsufficientUsdc();
    error InvalidWalletAddress();
    error Unauthorized();
    error InvalidBatchSize();
    error NameTooLong();
    error NameTooShort();
    error InvalidCharacter();
    error OverflowDetected();
    error SameAddress();
    error InvalidAddress();
    error EmptyTld();
    error FeeOverflow();

    constructor(
        address _usdcAddress,
        address _treasuryAddress
    ) Ownable(msg.sender) {
        if (_usdcAddress == address(0)) revert InvalidAddress();
        if (_treasuryAddress == address(0)) revert InvalidAddress();
        
        usdcAddress = _usdcAddress;
        treasuryAddress = _treasuryAddress;
        
        supportedTlds[".pepu"] = true;
        
        registrationFees[1] = 50e6;
        registrationFees[3] = 35e6;
        registrationFees[4] = 20e6;
        registrationFees[5] = 10e6;
    }

    function resolveName(string calldata name, string calldata tld) external view returns (address walletAddress) {
        string memory normalizedName = _toLowerCase(name);
        DomainRecord memory record = domains[normalizedName][tld];
        
        if (record.owner == address(0) || block.timestamp >= record.expiryTimestamp) {
            return address(0);
        }
        
        return record.walletAddress;
    }

    function registerDomain(
        string calldata name,
        string calldata tld,
        uint256 duration
    ) external nonReentrant whenNotPaused {
        _validateRegistration(name, tld, duration);
        
        if (bytes(walletToDomainName[msg.sender]).length > 0) {
            revert WalletAlreadyOwnsDomain();
        }
        
        uint256 baseFee = _calculateBaseFee(name);
        uint256 totalFee = baseFee * duration;
        if (totalFee / baseFee != duration) {
            revert FeeOverflow();
        }
        
        if (msg.sender != owner()) {
            _transferUsdcFee(totalFee);
        }
        
        string memory normalizedName = _toLowerCase(name);
        _registerDomain(normalizedName, tld, msg.sender, msg.sender, duration);
    }

    function adminRegister(
        string calldata name,
        string calldata tld,
        address walletAddress,
        uint256 duration
    ) external onlyOwner whenNotPaused {
        _validateRegistration(name, tld, duration);
        if (walletAddress == address(0)) revert InvalidWalletAddress();
        
        if (bytes(walletToDomainName[walletAddress]).length > 0) {
            revert WalletAlreadyOwnsDomain();
        }
        
        string memory normalizedName = _toLowerCase(name);
        _registerDomain(normalizedName, tld, walletAddress, walletAddress, duration);
    }

    function renewDomain(
        string calldata name,
        string calldata tld,
        uint256 duration
    ) external nonReentrant whenNotPaused {
        _validateRenewal(name, tld, duration);
        
        string memory normalizedName = _toLowerCase(name);
        DomainRecord storage record = domains[normalizedName][tld];
        
        if (record.owner != msg.sender) {
            revert Unauthorized();
        }
        
        if (block.timestamp >= record.expiryTimestamp) {
            revert DomainExpired();
        }
        
        uint256 baseFee = _calculateBaseFee(name);
        uint256 totalFee = baseFee * duration;
        if (totalFee / baseFee != duration) {
            revert FeeOverflow();
        }
        
        _transferUsdcFee(totalFee);
        
        uint256 additionalDays = duration * DAYS_PER_YEAR;
        if (additionalDays / DAYS_PER_YEAR != duration) {
            revert OverflowDetected();
        }
        record.expiryTimestamp += additionalDays * 1 days;
        
        emit DomainRenewed(name, tld, record.expiryTimestamp);
    }

    function setDomainWallet(
        string calldata name,
        string calldata tld,
        address newWallet
    ) external {
        if (newWallet == address(0)) revert InvalidWalletAddress();
        
        string memory normalizedName = _toLowerCase(name);
        DomainRecord storage record = domains[normalizedName][tld];
        
        if (record.owner != msg.sender) {
            revert Unauthorized();
        }
        
        if (block.timestamp >= record.expiryTimestamp) {
            revert DomainExpired();
        }
        
        if (newWallet == record.walletAddress) {
            revert SameAddress();
        }
        
        if (bytes(walletToDomainName[newWallet]).length > 0) {
            revert WalletAlreadyOwnsDomain();
        }
        
        if (record.walletAddress != address(0)) {
            delete walletToDomainName[record.walletAddress];
            delete walletToDomainTld[record.walletAddress];
        }
        
        record.walletAddress = newWallet;
        
        walletToDomainName[newWallet] = name;
        walletToDomainTld[newWallet] = tld;
        
        emit WalletUpdated(name, tld, newWallet);
    }

    function getDomainInfo(string calldata name, string calldata tld) external view returns (
        address walletAddress,
        address owner,
        uint256 registrationTimestamp,
        uint256 expiryTimestamp,
        string memory tldInfo
    ) {
        string memory normalizedName = _toLowerCase(name);
        DomainRecord memory record = domains[normalizedName][tld];
        
        if (record.owner == address(0)) {
            return (address(0), address(0), 0, 0, "");
        }
        
        return (
            record.walletAddress,
            record.owner,
            record.registrationTimestamp,
            record.expiryTimestamp,
            record.tld
        );
    }

    function isDomainAvailable(string calldata name, string calldata tld) external view returns (bool) {
        string memory normalizedName = _toLowerCase(name);
        DomainRecord memory record = domains[normalizedName][tld];
        
        if (record.owner == address(0)) {
            return true;
        }
        
        if (block.timestamp >= record.expiryTimestamp) {
            return true;
        }
        
        return false;
    }

    function getDomainByWallet(address wallet) external view returns (string memory name, string memory tld) {
        return (walletToDomainName[wallet], walletToDomainTld[wallet]);
    }

    function getDomainStatus(string calldata name, string calldata tld) external view returns (
        bool exists,
        bool expired,
        uint256 remainingDays,
        uint256 fee
    ) {
        string memory normalizedName = _toLowerCase(name);
        DomainRecord memory record = domains[normalizedName][tld];
        
        if (record.owner == address(0)) {
            return (false, false, 0, _calculateBaseFee(normalizedName));
        }
        
        bool isExpired = block.timestamp >= record.expiryTimestamp;
        uint256 remaining = isExpired ? 0 : (record.expiryTimestamp - block.timestamp) / 1 days;
        
        return (true, isExpired, remaining, _calculateBaseFee(normalizedName));
    }

    function getRegistrationFee(string calldata name, uint256 duration) external view returns (uint256) {
        return _calculateBaseFee(name) * duration;
    }

    function validateDomainName(string calldata name) external pure returns (bool) {
        return _isValidDomainName(name);
    }

    function getDomainNameInfo(string calldata name) external pure returns (
        uint256 charCount,
        uint256 byteLength,
        bool isValid
    ) {
        byteLength = bytes(name).length;
        charCount = _countUnicodeCharacters(name);
        isValid = _isValidDomainName(name);
        
        return (charCount, byteLength, isValid);
    }

    function batchRegisterDomains(
        string[] calldata names,
        string[] calldata tlds,
        uint256[] calldata durations
    ) external nonReentrant whenNotPaused {
        if (names.length == 0 || names.length > MAX_BATCH_SIZE) {
            revert InvalidBatchSize();
        }
        
        if (names.length != tlds.length || names.length != durations.length) {
            revert InvalidBatchSize();
        }
        
        if (bytes(walletToDomainName[msg.sender]).length > 0) {
            revert WalletAlreadyOwnsDomain();
        }
        
        uint256 totalFee = 0;
        
        for (uint256 i = 0; i < names.length; i++) {
            _validateRegistration(names[i], tlds[i], durations[i]);
            uint256 baseFee = _calculateBaseFee(names[i]);
            uint256 domainFee = baseFee * durations[i];
            if (domainFee / baseFee != durations[i]) {
                revert FeeOverflow();
            }
            totalFee += domainFee;
        }
        
        if (msg.sender != owner()) {
            _transferUsdcFee(totalFee);
        }
        
        for (uint256 i = 0; i < names.length; i++) {
            string memory normalizedName = _toLowerCase(names[i]);
            _registerDomain(normalizedName, tlds[i], msg.sender, msg.sender, durations[i]);
        }
        
        emit BatchDomainRegistered(names.length);
    }

    function setRegistrationFee(uint256 chars, uint256 fee) external onlyOwner {
        registrationFees[chars] = fee;
        emit RegistrationFeeUpdated(chars, fee);
    }

    function setUsdcAddress(address usdc) external onlyOwner {
        if (usdc == address(0)) revert InvalidAddress();
        address oldUsdc = usdcAddress;
        usdcAddress = usdc;
        emit UsdcAddressUpdated(oldUsdc, usdc);
    }

    function setTreasuryAddress(address treasury) external onlyOwner {
        if (treasury == address(0)) revert InvalidAddress();
        address oldTreasury = treasuryAddress;
        treasuryAddress = treasury;
        emit TreasuryAddressUpdated(oldTreasury, treasury);
    }



    function addTld(string calldata tld) external onlyOwner {
        if (bytes(tld).length == 0) revert EmptyTld();
        supportedTlds[tld] = true;
        emit TldAdded(tld);
    }

    function removeTld(string calldata tld) external onlyOwner {
        if (bytes(tld).length == 0) revert EmptyTld();
        supportedTlds[tld] = false;
        emit TldRemoved(tld);
    }

    function _validateRegistration(string calldata name, string calldata tld, uint256 duration) internal view {
        if (!supportedTlds[tld]) {
            revert InvalidTld();
        }
        
        if (duration < MIN_YEARS || duration > MAX_YEARS) {
            revert InvalidYears();
        }
        
        string memory normalizedName = _toLowerCase(name);
        _validateDomainName(normalizedName);
        
        DomainRecord memory record = domains[normalizedName][tld];
        if (record.owner != address(0) && block.timestamp < record.expiryTimestamp) {
            revert DomainAlreadyExists();
        }
    }

    function _validateRenewal(string calldata name, string calldata tld, uint256 duration) internal view {
        if (!supportedTlds[tld]) {
            revert InvalidTld();
        }
        
        if (duration < MIN_YEARS || duration > MAX_YEARS) {
            revert InvalidYears();
        }
        
        string memory normalizedName = _toLowerCase(name);
        DomainRecord memory record = domains[normalizedName][tld];
        if (record.owner == address(0)) {
            revert DomainNotFound();
        }
    }

    function _validateDomainName(string memory name) internal pure {
        uint256 nameLength = bytes(name).length;
        
        if (nameLength < MIN_NAME_LENGTH) {
            revert NameTooShort();
        }
        
        if (nameLength > MAX_NAME_LENGTH) {
            revert NameTooLong();
        }
        
        bytes memory nameBytes = bytes(name);
        for (uint256 i = 0; i < nameLength; i++) {
            uint8 char = uint8(nameBytes[i]);
            
            bool isValidAscii = (char >= 0x30 && char <= 0x39) || // 0-9
                               (char >= 0x41 && char <= 0x5A) || // A-Z
                               (char >= 0x61 && char <= 0x7A) || // a-z
                               (char == 0x2D); // hyphen
            
            bool isUnicodeStart = (char >= 0xC0 && char <= 0xDF) || // 2-byte UTF-8
                                 (char >= 0xE0 && char <= 0xEF) || // 3-byte UTF-8
                                 (char >= 0xF0 && char <= 0xF7);   // 4-byte UTF-8
            
            if (!isValidAscii && !isUnicodeStart) {
                revert InvalidCharacter();
            }
            
            // Additional Unicode validation for continuation bytes
            if (char >= 0x80 && char < 0xC0) {
                if (i == 0) revert InvalidCharacter(); // Continuation byte at start
                uint8 prevChar = uint8(nameBytes[i - 1]);
                if (prevChar < 0xC0) revert InvalidCharacter(); // Invalid UTF-8 sequence
            }
        }
    }

    function _toLowerCase(string calldata str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint256 i = 0; i < bStr.length; i++) {
            uint8 char = uint8(bStr[i]);
            if (char >= 0x41 && char <= 0x5A) {
                bLower[i] = bytes1(char + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }

    function _isValidDomainName(string memory name) internal pure returns (bool) {
        uint256 nameLength = bytes(name).length;
        
        if (nameLength < MIN_NAME_LENGTH || nameLength > MAX_NAME_LENGTH) {
            return false;
        }
        
        bytes memory nameBytes = bytes(name);
        for (uint256 i = 0; i < nameLength; i++) {
            uint8 char = uint8(nameBytes[i]);
            
            bool isValidAscii = (char >= 0x30 && char <= 0x39) || // 0-9
                               (char >= 0x41 && char <= 0x5A) || // A-Z
                               (char >= 0x61 && char <= 0x7A) || // a-z
                               (char == 0x2D); // hyphen
            
            bool isUnicodeStart = (char >= 0xC0 && char <= 0xDF) || // 2-byte UTF-8
                                 (char >= 0xE0 && char <= 0xEF) || // 3-byte UTF-8
                                 (char >= 0xF0 && char <= 0xF7);   // 4-byte UTF-8
            
            if (!isValidAscii && !isUnicodeStart) {
                return false;
            }
        }
        
        return true;
    }

    function _countUnicodeCharacters(string memory name) internal pure returns (uint256 count) {
        bytes memory nameBytes = bytes(name);
        uint256 byteLength = nameBytes.length;
        uint256 charCount = 0;
        
        for (uint256 i = 0; i < byteLength; i++) {
            uint8 char = uint8(nameBytes[i]);
            
            if (char < 0x80) {
                charCount++;
            } else if (char >= 0x80 && char < 0xC0) {
                continue;
            } else {
                charCount++;
            }
        }
        
        return charCount;
    }

    function _calculateBaseFee(string memory name) internal view returns (uint256) {
        uint256 charCount = _countUnicodeCharacters(name);
        
        if (charCount == 1) {
            return registrationFees[1];
        } else if (charCount == 3) {
            return registrationFees[3];
        } else if (charCount == 4) {
            return registrationFees[4];
        } else {
            return registrationFees[5];
        }
    }

    function _calculateExpiry(uint256 duration) internal view returns (uint256) {
        uint256 daysToAdd = duration * DAYS_PER_YEAR;
        
        if (daysToAdd / DAYS_PER_YEAR != duration) {
            revert OverflowDetected();
        }
        
        return block.timestamp + (daysToAdd * 1 days);
    }

    function _registerDomain(
        string memory name,
        string calldata tld,
        address owner,
        address walletAddress,
        uint256 duration
    ) internal {
        uint256 registrationTimestamp = block.timestamp;
        uint256 expiryTimestamp = _calculateExpiry(duration);
        
        domains[name][tld] = DomainRecord({
            walletAddress: walletAddress,
            owner: owner,
            registrationTimestamp: registrationTimestamp,
            expiryTimestamp: expiryTimestamp,
            tld: tld
        });
        
        walletToDomainName[walletAddress] = name;
        walletToDomainTld[walletAddress] = tld;
        
        emit DomainRegistered(
            name,
            tld,
            owner,
            walletAddress,
            registrationTimestamp,
            expiryTimestamp
        );
        
        if (_containsUnicode(name)) {
            emit UnicodeDomainRegistered(name, tld, owner);
        }
    }

    function _containsUnicode(string memory name) internal pure returns (bool) {
        bytes memory nameBytes = bytes(name);
        for (uint256 i = 0; i < nameBytes.length; i++) {
            if (uint8(nameBytes[i]) >= 0x80) {
                return true;
            }
        }
        return false;
    }

    function _transferUsdcFee(uint256 amount) internal {
        IERC20 usdc = IERC20(usdcAddress);
        
        if (usdc.balanceOf(msg.sender) < amount) {
            revert InsufficientUsdc();
        }
        
        if (usdc.allowance(msg.sender, address(this)) < amount) {
            revert InsufficientUsdc();
        }
        
        usdc.safeTransferFrom(msg.sender, treasuryAddress, amount);
    }
}
 