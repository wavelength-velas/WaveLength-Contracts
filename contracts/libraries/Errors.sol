// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// solhint-disable

/**
 * @dev Reverts if `condition` is false, with a revert reason containing `errorCode`. Only codes up to 999 are
 * supported.
 */
function _require(bool condition, uint256 errorCode) pure {
    if (!condition) _revert(errorCode);
}

/**
 * @dev Reverts with a revert reason containing `errorCode`. Only codes up to 999 are supported.
 */
function _revert(uint256 errorCode) pure {
    // We're going to dynamically create a revert string based on the error code, with the following format:
    // 'BAL#{errorCode}'
    // where the code is left-padded with zeroes to three digits (so they range from 000 to 999).
    //
    // We don't have revert strings embedded in the contract to save bytecode size: it takes much less space to store a
    // number (8 to 16 bits) than the individual string characters.
    //
    // The dynamic string creation algorithm that follows could be implemented in Solidity, but assembly allows for a
    // much denser implementation, again saving bytecode size. Given this function unconditionally reverts, this is a
    // safe place to rely on it without worrying about how its usage might affect e.g. memory contents.
    assembly {
        // First, we need to compute the ASCII representation of the error code. We assume that it is in the 0-999
        // range, so we only need to convert three digits. To convert the digits to ASCII, we add 0x30, the value for
        // the '0' character.

        let units := add(mod(errorCode, 10), 0x30)

        errorCode := div(errorCode, 10)
        let tenths := add(mod(errorCode, 10), 0x30)

        errorCode := div(errorCode, 10)
        let hundreds := add(mod(errorCode, 10), 0x30)

        // With the individual characters, we can now construct the full string. The "BAL#" part is a known constant
        // (0x42414c23): we simply shift this by 24 (to provide space for the 3 bytes of the error code), and add the
        // characters to it, each shifted by a multiple of 8.
        // The revert reason is then shifted left by 200 bits (256 minus the length of the string, 7 characters * 8 bits
        // per character = 56) to locate it in the most significant part of the 256 slot (the beginning of a byte
        // array).

        let revertReason := shl(200, add(0x42414c23000000, add(add(units, shl(8, tenths)), shl(16, hundreds))))

        // We can now encode the reason in memory, which can be safely overwritten as we're about to revert. The encoded
        // message will have the following layout:
        // [ revert reason identifier ] [ string location offset ] [ string length ] [ string contents ]

        // The Solidity revert reason identifier is 0x08c739a0, the function selector of the Error(string) function. We
        // also write zeroes to the next 28 bytes of memory, but those are about to be overwritten.
        mstore(0x0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
        // Next is the offset to the location of the string, which will be placed immediately after (20 bytes away).
        mstore(0x04, 0x0000000000000000000000000000000000000000000000000000000000000020)
        // The string length is fixed: 7 characters.
        mstore(0x24, 7)
        // Finally, the string itself is stored.
        mstore(0x44, revertReason)

        // Even if the string is only 7 bytes long, we need to return a full 32 byte slot containing it. The length of
        // the encoded message is therefore 4 + 32 + 32 + 32 = 100.
        revert(0, 100)
    }
}

library Errors {
    // WaveEmissionDistributor
    uint256 internal constant INVALID_PID = 701;
    uint256 internal constant INVALID_ANOTHER_PID = 702;
    uint256 internal constant INVALID_VEWAVE_ADDRESS = 703;
    uint256 internal constant INVALID_WAVE_ADDRESS = 704;
    uint256 internal constant INVALID_MASTERCHEF_ADDRESS = 704;
    uint256 internal constant FUND_STILL_REMAINING = 705;
    uint256 internal constant NOT_OWNER_VEWAVE = 706;
    uint256 internal constant NOT_ENOUGH_VEWAVERECEIPT = 707;
    uint256 internal constant EXCEEDED_PER_BLOCK = 708;
    uint256 internal constant NOT_ADDED_ANOTHER = 709;

    // veWave
    uint256 internal constant REENTRANCY = 801;
    uint256 internal constant NOT_VOTER = 802;
    uint256 internal constant ALREADY_OWNED = 803;
    uint256 internal constant NOT_FROM = 804;
    uint256 internal constant NOT_OWNER = 805;
    uint256 internal constant ATTACHED = 806;
    uint256 internal constant NOT_APPROVED = 807;
    uint256 internal constant INVALID_OWNER = 808;
    uint256 internal constant NOT_MATCH_OWNER_APPROVED = 809;
    uint256 internal constant NOT_OPERATOR = 810;
    uint256 internal constant INVALID_TO = 811;
    uint256 internal constant EQUAL_FROM_TO = 812;
    uint256 internal constant ZERO_VALUE = 813;
    uint256 internal constant UNLOCK_TIME = 814;
    uint256 internal constant OVER_MAX_TIME = 815;
    uint256 internal constant LOCK_EXPIRED = 816;
    uint256 internal constant NOTHING_LOCK = 817;
    uint256 internal constant INCREASE_LOCK_DURATION = 818;
    uint256 internal constant NOT_EXPIRED = 819;
    uint256 internal constant INVALID_TOKEN = 820;
    uint256 internal constant INVALID_BLOCK_NUMBER = 821;
}
