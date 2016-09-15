fs                 = require 'fs'
path               = require 'path'
_                  = require 'lodash'
colors             = require 'colors'
program            = require 'commander'

packageJSON        = require './package.json'
Printer            = require './src/printer'
DeployStateService = require './src/deploy-state-service'

program
  .version packageJSON.version
  .usage '[options] <project-name>'
  .option '-u, --deploy-state-uri',
    'Deploy State URI, should contain authentication. (env: DEPLOY_STATE_URI)'
  .option '-o, --owner <octoblu>', 'Project owner'
  .option '-j, --json', 'Print JSON'

class Command
  constructor: ->
    process.on 'uncaughtException', @die
    {@repo, @owner, @json, deployStateUri} = @parseOptions()
    @deployStateService = new DeployStateService { deployStateUri }

  parseOptions: =>
    program.parse process.argv
    repo = program.args[0]
    repo ?= @_getPackageName()

    { owner, json, deployStateUri } = program
    owner ?= 'octoblu'

    deployStateUri ?= process.env.DEPLOY_STATE_URI

    throw new Error 'Missing repo' unless repo?
    throw new Error 'Missing deploy state uri' unless deployStateUri?

    return { repo, owner, json: json?, deployStateUri }

  run: =>
    @deployStateService.getList { @repo, @owner }, (error, result) =>
      return @die error if error?
      @_print result.deployments

  _print: (deployments=[]) =>
    printer = new Printer { @json }
    _.each deployments, printer.printDeployment

  _getPackageName: =>
    pkgPath = path.join process.cwd(), 'package.json'
    try
      pkg = JSON.parse fs.readFileSync pkgPath
      return pkg.name

  die: (error) =>
    return process.exit(0) unless error?
    console.error 'ERROR'
    console.error error.stack
    process.exit 1

module.exports = Command
