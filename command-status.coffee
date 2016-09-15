fs                 = require 'fs'
path               = require 'path'
_                  = require 'lodash'
colors             = require 'colors'
moment             = require 'moment'
program            = require 'commander'
packageJSON        = require './package.json'

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
    @deployStateService.getStatus { @repo, @owner, @tag }, (error, result) =>
      return @die error if error?
      return @die new Error 'Deployment not found' unless result?
      @_print result

  _print: (result) =>
    return @_printJSON result if @json
    @_printPretty result

  _printJSON: (result) =>
    console.log JSON.stringify result, null, 2

  _printPretty: (result) =>
    console.log ''
    console.log "[deployment]", colors.cyan "#{result.owner}/#{result.repo}:#{result.tag}"
    @_printBuild result
    @_printCluster result
    console.log ''

  _printBuild: (result) =>
    console.log ''
    console.log "[build]  ", @_passfail result.build
    console.log "  travis:", @_passfail result.build["travis-ci"]
    console.log "  docker:", @_passfail result.build.docker

  _printCluster: (result) =>
    return if _.isEmpty result.cluster
    console.log "[cluster]"
    _.each _.keys(result.cluster), (cluster) =>
      console.log "  #{cluster}:", @_passfail result.cluster[cluster]

  _passfail: ({ passing, createdAt, updatedAt } = {}) =>
    status = colors.green "(passing)" if passing
    status = colors.red "(failed)" unless passing
    date = createdAt ? updatedAt
    return status unless date?
    humanDate = moment(date).fromNow()
    return "#{status} #{colors.cyan(humanDate)}"

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
