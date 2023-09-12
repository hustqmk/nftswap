const hre = require("hardhat");

async function main() {
    const contract = await hre.ethers.getContractFactory("MKNFT")
    const swap_contract = await contract.deploy("MKNFT", "MKN")

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