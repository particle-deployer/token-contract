const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");
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

const processMerkleTree = async () => {
  try {
    // (1) read from CSV file
    const csvInput = await readCSV(inputFilePath);
    const values = csvInput.map((value) => {
      return [value.address.toLowerCase(), value.amount];
    });

    // (2) create Merkle tree
    const tree = StandardMerkleTree.of(values, ["address", "uint256"]);

    // (3) generate Merkle root
    console.log("Merkle Root:", tree.root);

    // (4) write the tree into csv
    const proofs = [];
    for (const [i, v] of tree.entries()) {
      const proof = tree.getProof(i);
      proofs.push({
        address: v[0],
        amount: v[1],
        proof: proof,
      });
    }
    await writeCSV(outputFilePath, proofs);

    console.log("Merkle tree written to file", outputFilePath);
  } catch (error) {
    console.error("Error processing Merkle tree:", error);
  }
};

processMerkleTree();
