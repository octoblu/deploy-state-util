_                  = require 'lodash'
colors             = require 'colors'
program            = require 'commander'

Printer     = require './src/printer'
Config      = require './src/config.coffee'
packageJSON = require './package.json'

GovernatorService = require './src/governator-service.coffee'
DeployStateService = require './src/deploy-state-service'

program
  .version packageJSON.version
  .usage '[options] <project-name>'
  .option '-o, --owner <octoblu>', 'Project owner'
  .option '-j, --json', 'Print JSON'

class Command
  constructor: ->
    process.on 'uncaughtException', @die
    @config = new Config()
    {@repo, @owner, @json} = @parseOptions()
    @deployStateService = new DeployStateService { config: @config.get() }
    @governatorService = new GovernatorService { config: @config.get() }

  parseOptions: =>
    program.parse process.argv
    repo = program.args[0]
    repo ?= @config.getPackageName()

    { owner, json } = program
    owner ?= 'octoblu'

    @dieHelp new Error 'Missing repo' unless repo?

    return { repo, owner, json: json? }

  run: =>
    printer = new Printer { }
    @deployStateService.getList { @repo, @owner }, (error, result) =>
      return @die error if error?
      { deployments } = result
      @governatorService.getStatuses { @repo, @owner }, (error, governators) =>
        return @die error if error?
        return printer.printJSON { deployments, governators } if @json
        _.each _.reverse(deployments), @printDeployment
        printer.printGovernators governators

  printDeployment: (deployment) =>
    printer = new Printer { slug: "#{deployment.owner}/#{deployment.repo}:#{deployment.tag}" }
    printer.printDeployment deployment

  dieHelp: (error) =>
    program.outputHelp()
    return @die error

  die: (error) =>
    return process.exit(0) unless error?
    console.error error.stack
    process.exit 1

module.exports = Command
