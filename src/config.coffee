path = require 'path'

class Config
  constructor: ->
    @configPath = path.join process.env.HOME, '.octoblu', 'deploy-state.json'
    @pkgPath = path.join process.cwd(), 'package.json'

  get: =>
    try
      return require @configPath
    catch error
      console.error "Missing deploy-state-util configuration", configPath
      process.exit 1

  getPackageName: =>
    try
      return require(@pkgPath).name

  getPackageVersion: =>
    try
      return "v#{require(@pkgPath).version}"

module.exports = Config
