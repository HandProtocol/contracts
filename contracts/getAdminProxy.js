async function main() {
    // The address of your TransparentUpgradeableProxy:
const proxyAddress = "0xa6e35CCf2950c637AF0F06e162A3991f50CE210f";

// The EIP-1967 admin storage slot:
const adminSlot = "0xb53127684a568b3173ae13b9f8a6016c7a3c37bdc5ac6d167e9cc1f94193d7c9";

// Read the raw storage at that slot:
const rawSlotData = await web3.eth.getStorageAt(proxyAddress, adminSlot);
console.log("Raw slot data:", rawSlotData);

// Decode the address. The admin address is stored in the last 20 bytes:
const adminAddress = "0x" + rawSlotData.slice(26);
console.log("ProxyAdmin address:", adminAddress);
}

main()