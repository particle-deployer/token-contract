const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");
const fs = require("fs");
const csv = require("csv-parser");
const { createObjectCsvWriter } = require("csv-writer");

const inputFilePath = "./data/allocation.csv";
const outputFilePath = "./data/airdrop.csv";

const readCSV = (filePath) => {
  return new Promise((resolve, reject) => {
    const results = [];
    fs.createReadStream(filePath)
      .pipe(csv())
      .on("data", (data) => results.push(data))
      .on("end", () => resolve(results))
      .on("error", (error) => reject(error));
  });
};

const writeCSV = (filePath, data) => {
  const csvWriter = createObjectCsvWriter({
    path: filePath,
    header: [
      { id: "address", title: "address" },
      { id: "amount", title: "amount" },
      { id: "proof", title: "proof" },
    ],
  });

  return csvWriter.writeRecords(data);
};

const encodePacked = (address, entitlement) => {
  const addressPadded = address.toLowerCase();
  const entitlementHex = BigInt(entitlement).toString(16);
  const entitlementPadded = entitlementHex.padStart(64, "0");
  return addressPadded + entitlementPadded;
};

const processMerkleTree = async () => {
  try {
    const amounts = await readCSV(inputFilePath);
    const leaves = amounts.map((user) => keccak256(encodePacked(user.address, user.amount)));
    const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });

    const root = tree.getRoot().toString("hex");
    console.log("Merkle Root:", root);

    const proofs = amounts.map((user, index) => {
      const leaf = leaves[index];
      const proof = tree.getProof(leaf).map((p) => p.data.toString("hex"));
      return {
        address: user.address,
        amount: user.amount,
        proof: proof.join(","),
      };
    });

    await writeCSV(outputFilePath, proofs);
    console.log("Proofs written to CSV file", outputFilePath);
  } catch (error) {
    console.error("Error processing Merkle tree:", error);
  }
};

processMerkleTree();
