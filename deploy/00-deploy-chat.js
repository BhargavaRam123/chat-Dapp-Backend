// const { networkConfig, developmentchains } = require("../helper-hardhat-config");
const { network } = require("hardhat");
const { verify } = require("../utils/verify")
module.exports = async ({ getNamedAccounts, deployments }) => {
    var ethUsdPriceFeed
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const Chat = await deploy("Chat", {
        from: deployer,
        log: true,
        waitConfirmations: network.config.blockConformations || 1,
    })
    log("____________________________________")
    log(`Chat deployed at ${Chat.address}`)

    if (network.name == "Sepolia") {
        await verify(Chat.address, [])
    }
}

module.exports.tags = ["all", "chat"]