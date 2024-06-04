const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

const amounts1 = [
  { address: "0x0000000000000000000000000000000000004242", entitlement: "100000000000000000000" },
  { address: "0x0000000000000000000000000000000000006969", entitlement: "4269000000000000000000" },
];

const amounts2 = [
  { address: "0x0000000000000000000000000000000000004242", entitlement: "200000000000000000000" },
  { address: "0x0000000000000000000000000000000000006969", entitlement: "4269000000000000000001" },
];

const encodePacked = (address, entitlement) => {
  const addressPadded = address.toLowerCase();
  const entitlementHex = BigInt(entitlement).toString(16);
  const entitlementPadded = entitlementHex.padStart(64, "0");
  return addressPadded + entitlementPadded;
};

// Generate leaves from users data
const leaves1 = amounts1.map((user) => keccak256(encodePacked(user.address, user.entitlement)));
const leaves2 = amounts2.map((user) => keccak256(encodePacked(user.address, user.entitlement)));

// Create the Merkle tree
const tree1 = new MerkleTree(leaves1, keccak256, { sortPairs: true });
const tree2 = new MerkleTree(leaves2, keccak256, { sortPairs: true });

// Get the Merkle root
const root1 = tree1.getRoot().toString("hex");
console.log("Merkle Root for mapping 1:", root1);
const root2 = tree2.getRoot().toString("hex");
console.log("Merkle Root for mapping 2:", root2);
console.log("");

// Generate and print the Merkle proof for each user
console.log("Tree 1");
amounts1.forEach((user, index) => {
  const leaf = leaves1[index];
  const proof = tree1.getProof(leaf).map((p) => p.data.toString("hex"));
  console.log(`Proof for ${user.address}:`, proof);
});
console.log("");

// Generate and print the Merkle proof for each user
console.log("Tree 2");
amounts2.forEach((user, index) => {
  const leaf = leaves2[index];
  const proof = tree2.getProof(leaf).map((p) => p.data.toString("hex"));
  console.log(`Proof for ${user.address}:`, proof);
});
console.log("");
