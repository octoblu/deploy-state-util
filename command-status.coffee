_           = require 'lodash'
fs          = require 'fs'
path        = require 'path'
colors      = require 'colors'
program     = require 'commander'
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
    {@repo, @owner, @tag, @json} = @parseOptions()
    config = new Config().get()
    @deployStateService = new DeployStateService { config }
    @governatorService = new GovernatorService { config }
    @serviceStateService = new ServiceStateService { config }

  parseOptions: =>
    program.parse process.argv
    repo = program.args[0]
    repo ?= @_getPackageName()

    tag = program.args[1]
    tag ?= @_getPackageVersion()

    { owner, json } = program
    owner ?= 'octoblu'

    throw new Error 'Missing repo' unless repo?
    throw new Error 'Missing tag' unless tag?

    return { repo, owner, json: json?, tag }

  run: =>
    slug = "#{@owner}/#{@repo}:#{@tag}"
    printer = new Printer { @json, slug }
    @deployStateService.getStatus { @repo, @owner, @tag }, (error, deployment) =>
      return @die error if error?
      @serviceStateService.getStatuses { @repo, @owner }, (error, dockerUrls) =>
        return @die error if error?
        @governatorService.getStatuses { @repo, @owner }, (error, governators) =>
          return @die error if error?
          return printer.printJSON { deployment, dockerUrls, governators } if @json
          printer.printDeployment deployment
          printer.printDockerUrls dockerUrls
          printer.printGovernators governators

  _getPackageName: =>
    pkgPath = path.join process.cwd(), 'package.json'
    try
      pkg = JSON.parse fs.readFileSync pkgPath
      return pkg.name

  _getPackageVersion: =>
    pkgPath = path.join process.cwd(), 'package.json'
    try
      pkg = JSON.parse fs.readFileSync pkgPath
      return "v#{pkg.version}"

  die: (error) =>
    return process.exit(0) unless error?
    console.error 'ERROR'
    console.error error.stack
    process.exit 1

module.exports = Command
