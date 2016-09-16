_      = require 'lodash'
colors = require 'colors'
moment = require 'moment'

class Printer
  constructor: ({ @json, @slug }) ->

  printDeployment: (result) =>
    return @_printEmpty() if _.isEmpty result
    return @_printJSON result if @json
    @_printPretty result

  _printEmpty: =>
    console.log colors.yellow "No deployment exists for #{@slug}"

  _printJSON: (result) =>
    console.log JSON.stringify result, null, 2

  _printPretty: (result) =>
    console.log ''
    console.log "[deployment]", colors.cyan "#{@slug}"
    @_printBuild result
    @_printCluster result
    console.log ''

  _printBuild: (result) =>
    result.build ?= {}
    if !result.build['travis-ci']? or !result.build['docker']?
      result.build.pending = true
    console.log ''
    console.log "[build]  ", @_passfail result.build
    console.log "  travis:", @_passfail result.build["travis-ci"]
    console.log "  docker:", @_passfail result.build.docker

  _printCluster: (result) =>
    return if _.isEmpty result.cluster
    console.log ''
    console.log "[cluster]"
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
