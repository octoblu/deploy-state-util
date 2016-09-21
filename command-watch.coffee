_           = require 'lodash'
colors      = require 'colors'
program     = require 'commander'
moment      = require 'moment'
cliClear    = require 'cli-clear'
Printer     = require './src/printer'
Config      = require './src/config.coffee'
packageJSON = require './package.json'

GovernatorService = require './src/governator-service.coffee'
DeployStateService = require './src/deploy-state-service'
ServiceStateService  = require './src/service-state-service'

program
  .version packageJSON.version
  .usage '[options] <project-name> <tag>'
  .option '-o, --owner <octoblu>', 'Project owner'
  .option '-j, --json', 'Print JSON'

class Command
  constructor: ->
    process.on 'uncaughtException', @die
    @config = new Config()
    {@repo, @owner, @tag, @json} = @parseOptions()
    @deployStateService = new DeployStateService { config: @config.get() }
    @governatorService = new GovernatorService { config: @config.get() }
    @serviceStateService = new ServiceStateService { config: @config.get() }

  parseOptions: =>
    program.parse process.argv
    repo = program.args[0]
    repo ?= @config.getPackageName()

    tag = program.args[1]
    tag ?= @config.getPackageVersion()

    { owner, json } = program
    owner ?= 'octoblu'

    throw new Error 'Missing repo' unless repo?
    throw new Error 'Missing tag' unless tag?

    return { repo, owner, json: json?, tag }

  run: =>
    @getStatus()

  getStatus: =>
    cliClear()
    slug = "#{@owner}/#{@repo}:#{@tag}"
    printer = new Printer { @json, slug }
    console.log '[refreshed at] ', colors.cyan moment().toString()
    @deployStateService.getStatus { @repo, @owner, @tag }, (error, deployment) =>
      return @die error if error?
      @serviceStateService.getStatuses { @repo, @owner }, (error, dockerUrls) =>
        return @die error if error?
        @governatorService.getStatuses { @repo, @owner, @tag }, (error, governators) =>
          return @die error if error?
          return printer.printJSON { deployment, dockerUrls, governators } if @json
          printer.printDeployment deployment
          printer.printDockerUrls dockerUrls
          printer.printGovernators governators
          _.delay @getStatus, 1000 * 40

  die: (error) =>
    return process.exit(0) unless error?
    console.error 'ERROR'
    console.error error.stack
    process.exit 1

module.exports = Command
