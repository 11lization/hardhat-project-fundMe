// synchronous [solidity]
// asynchronous [javascript]

// cooking

// Synchronous
// 1. Put popcorn in microwave -> Promise
// 2. Wait for popcorn to finish
// 3. Pour dirnks for everyone

// Asnychronous
// 1. Put popcorn in microwave
// 2. Pour dirnks for everyone
// 3. Wait for popcorn to finish
const ethers = require("ethers");
const fs = require("fs-extra");

async function main() {
  // HTTP://127.0.0.1:7545
  const provider = new ethers.providers.JsonRpcProvider(
    "HTTP://127.0.0.1:7545"
  );
  const wallet = new ethers.Wallet(
    "a3d0af75704d727fc42fba7ee7b6ec5a8984cc48ab8179932ee02abadba4f076",
    provider
  );
  const abi = fs.readFileSync("./SimpleStorage_sol_SimpleStorage.abi", "utf8");
  const binary = fs.readFileSync(
    "./SimpleStorage_sol_SimpleStorage.bin",
    "utf8"
  );
  const contractFactory = new ethers.ContractFactory(abi, binary, wallet);
  console.log("Deploying, please wait...");
  const contract = await contractFactory.deploy(); // STOP here! Wait for contract deploy!
  console.log(contract);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
