_      = require 'lodash'
colors = require 'colors'
moment = require 'moment'

class Printer
  constructor: ({ @slug }) ->

  printDeployment: (result) =>
    return @_printEmpty("deployment") if _.isEmpty result
    @_printPretty result

  printDockerUrls: (result) =>
    return if _.isEmpty result
    console.log "[current state]"
    _.each result, @printDockerUrl
    console.log ''

  printDockerUrl: (dockerUrl, cluster) =>
    return if _.isEmpty dockerUrl
    console.log "  [#{cluster}]"
    console.log "    ", colors.gray('docker_url'), colors.bold dockerUrl

  printGovernators: (result) =>
    return @_printEmpty("pending deploys") if _.isEmpty result
    console.log "[deployments]"
    _.each result, @printGovernator
    console.log ''

  printGovernator: (deploys, cluster) =>
    return if _.isEmpty deploys
    console.log "  [#{cluster}]"
    _.each deploys, @_printGovernatorDeploy

  _printGovernatorDeploy: ({ deploymentKey, deployAtSince, status }) =>
    status = colors.yellow status if status == 'pending'
    status = colors.red status unless status == 'pending'
    console.log "    ", colors.bold "#{deploymentKey}:"
    console.log "      ", colors.gray('deployAt'), colors.cyan deployAtSince
    console.log "      ", colors.gray('status'), status

  _printEmpty: (thing) =>
    console.log colors.yellow "No #{thing} exists for #{@slug}"

  printJSON: (result) =>
    console.log JSON.stringify result, null, 2

  _printPretty: (result) =>
    console.log ''
    console.log "[deployment]", colors.bold "#{@slug}"
    @_printBuild result
    @_printCluster result
    console.log ''

  _printBuild: (result) =>
    result.build ?= {}
    if !result.build['travis-ci']? or !result.build['docker']?
      result.build.pending = true
    console.log ''
    console.log "[build status]  ", @_passfail result.build
    console.log "  travis:", @_passfail result.build["travis-ci"]
    console.log "  docker:", @_passfail result.build.docker

  _printCluster: (result) =>
    return if _.isEmpty result.cluster
    console.log ''
    console.log "[cluster status]"
    _.each _.keys(result.cluster), (cluster) =>
      console.log "  #{cluster}:", @_passfail result.cluster[cluster]

  _passfail: (options) =>
    return colors.yellow "(pending)" if _.isEmpty options
    { passing, pending, createdAt, updatedAt } = options
    return colors.yellow "(pending)" if pending
    status = colors.green "(passing)" if passing
    status = colors.red "(failed)" unless passing
    date = createdAt ? updatedAt
    return status unless date?
    humanDate = moment(date).fromNow()
    return "#{status} #{colors.cyan(humanDate)}"

module.exports = Printer
