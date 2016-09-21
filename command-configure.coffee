_             = require 'lodash'
path          = require 'path'
colors        = require 'colors'
program       = require 'commander'

Config        = require './src/config.coffee'
QuayService   = require './src/quay-service.coffee'
TravisService = require './src/travis-service.coffee'

packageJSON   = require './package.json'

program
  .version packageJSON.version
  .usage '[options] <project-name>'
  .option '-o, --owner <octoblu>', 'Project owner'
  .option '-p, --private', 'Add this flag if the project is private'
  .option '--quay-token', 'Quay API Token. (env: QUAY_TOKEN)'

class Command
  constructor: ->
    process.on 'uncaughtException', @die
    @config = new Config()
    { @repo, @owner, @isPrivate, quayToken } = @parseOptions()
    @travisService = new TravisService { config: @config.get() }
    @quayService = new QuayService { config: @config.get(), quayToken }

  parseOptions: =>
    program.parse process.argv

    repo = program.args[0]
    repo ?= @config.getPackageName()

    { owner, quayToken } = program
    owner ?= 'octoblu'
    quayToken ?= process.env.QUAY_TOKEN

    throw new Error 'Missing QUAY_TOKEN' unless quayToken?

    isPrivate = program.private?

    return { repo, owner, isPrivate, quayToken }

  run: =>
    @travisService.configure { @isPrivate }, (error) =>
      return @die error if error?
      @quayService.configure { @repo, @owner, @isPrivate }, (error) =>
        return @die error if error?
        process.exit 0

  die: (error) =>
    return process.exit(0) unless error?
    console.error 'ERROR'
    console.error error.stack
    process.exit 1

module.exports = Command
