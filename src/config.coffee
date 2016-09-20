class Config
  get: =>
    configPath = "#{process.env.HOME}/.octoblu/deploy-state.json"
    try
      return require configPath
    catch error
      console.error "Missing deploy-state-util configuration", configPath
      process.exit 1

module.exports = Config
