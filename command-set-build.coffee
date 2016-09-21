_           = require 'lodash'
colors      = require 'colors'
program     = require 'commander'

Config      = require './src/config.coffee'
packageJSON = require './package.json'

DeployStateService = require './src/deploy-state-service'

program
  .version packageJSON.version
  .usage '[options] <project-name> <tag>'
  .option '-o, --owner <octoblu>', 'Project owner'
  .option '-s, --state <travis-ci>', 'The state to set on the build. Could be one of `travis-ci` and `quay.io`'
  .option '-p, --passing <true>', 'A boolean to indicate whether the build is passing or failing.'

class Command
  constructor: ->
    process.on 'uncaughtException', @die
    @config = new Config()
    {@repo, @owner, @tag, @state, @passing } = @parseOptions()
    @deployStateService = new DeployStateService { config: @config.get() }

  parseOptions: =>
    program.parse process.argv
    repo = program.args[0]
    repo ?= @config.getPackageName()

    tag = program.args[1]
    tag ?= @config.getPackageVersion()

    { owner, state } = program
    owner ?= 'octoblu'

    throw new Error 'Missing repo argument' unless repo?
    throw new Error 'Missing tag argument' unless tag?
    throw new Error 'Missing state argument' unless state?
    throw new Error 'Missing passing argument' unless program.passing?

    passing = false
    passing = true if program.passing == 'true'

    return { repo, owner, tag, state, passing }

  run: =>
    options = { @repo, @owner, @tag, @state, @passing, type: 'build' }
    @deployStateService.setState options, (error, deployment) =>
      return @die error if error?
      process.exit 0

  die: (error) =>
    return process.exit(0) unless error?
    console.error 'ERROR'
    console.error error.stack
    process.exit 1

module.exports = Command
