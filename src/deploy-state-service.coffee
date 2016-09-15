request = require 'request'
debug   = require('debug')('deploy-state-util:service')

class DeployStateService
  constructor: ({ @deployStateUri }) ->

  getStatus: ({ owner, repo, tag }, callback) =>
    options =
      baseUrl: @deployStateUri
      uri: "/deployments/#{owner}/#{repo}/#{tag}"
      json: true
    debug 'get status options', options
    request.get options, (error, response, body) =>
      return callback error if error?
      if response.statusCode > 499
        return callback new Error 'Fatal error from deploy state service'
      if response.statusCode == 404
        return callback null
      callback null, body

  getList: ({ owner, repo }, callback) =>
    options =
      baseUrl: @deployStateUri
      uri: "/deployments/#{owner}/#{repo}"
      json: true
    debug 'get list options', options
    request.get options, (error, response, body) =>
      return callback error if error?
      if response.statusCode > 499
        return callback new Error 'Fatal error from deploy state service'
      callback null, body

module.exports = DeployStateService
