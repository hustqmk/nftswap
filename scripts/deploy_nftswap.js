const hre = require("hardhat");

async function main() {
    const contract = await hre.ethers.getContractFactory("nftswap")
    const swap_contract = await contract.deploy()

    await swap_contract.deployed()

    console.log("deploy to ", swap_contract.address);

}


main()
    .then(()=> {
        console.log("Finished");
        process.exit(0);
    })
    .catch(error => {
        console.log("err0r: ", error);
        process.exit(1);
    })