_           = require 'lodash'
fs          = require 'fs'
path        = require 'path'
colors      = require 'colors'
program     = require 'commander'
moment      = require 'moment'
cliClear    = require 'cli-clear'
Printer     = require './src/printer'
packageJSON = require './package.json'

DeployStateService = require './src/deploy-state-service'

program
  .version packageJSON.version
  .usage '[options] <project-name> <tag>'
  .option '-u, --deploy-state-uri',
    'Deploy State URI, should contain authentication. (env: DEPLOY_STATE_URI)'
  .option '-o, --owner <octoblu>', 'Project owner'
  .option '-j, --json', 'Print JSON'

class Command
  constructor: ->
    process.on 'uncaughtException', @die
    {@repo, @owner, @tag, @json, deployStateUri} = @parseOptions()
    @deployStateService = new DeployStateService { deployStateUri }

  parseOptions: =>
    program.parse process.argv
    repo = program.args[0]
    repo ?= @_getPackageName()

    tag = program.args[1]
    tag ?= @_getPackageVersion()

    { owner, json, deployStateUri } = program
    owner ?= 'octoblu'

    deployStateUri ?= process.env.DEPLOY_STATE_URI

    throw new Error 'Missing repo' unless repo?
    throw new Error 'Missing tag' unless tag?
    throw new Error 'Missing deploy state uri' unless deployStateUri?

    return { repo, owner, json: json?, deployStateUri, tag }

  run: =>
    @getStatus()

  getStatus: =>
    cliClear()
    console.log '[refreshed at] ', colors.cyan moment().toString()
    @deployStateService.getStatus { @repo, @owner, @tag }, (error, result) =>
      return @die error if error?
      return @die new Error 'Deployment not found' unless result?
      _.delay @getStatus, 1000 * 40
      @_print result

  _print: (result) =>
    printer = new Printer { @json }
    printer.printDeployment result

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
