_      = require 'lodash'
path   = require 'path'
url    = require 'url'
yaml   = require 'node-yaml'
colors = require 'colors'
fs     = require 'fs'
debug  = require('debug')('deploy-state-util:project-service')

class ProjectService
  constructor: ({ config, @hubOnly }) ->
    throw new Error 'Missing config argument' unless config?
    @hubOnly ?= false
    @travisYml = path.join process.cwd(), '.travis.yml'
    @packagePath = path.join process.cwd(), 'package.json'
    @dockerFilePath = path.join process.cwd(), 'Dockerfile'
    @webhookUrl = url.format {
      hostname: config['beekeeper'].hostname,
      protocol: 'https',
      slashes: true,
      pathname: '/webhooks/travis:ci'
    }

  configure: ({ isPrivate }, callback) =>
    @_modifyTravis { isPrivate }, (error) =>
      return callback error if error?
      @_modifyDockerfile (error) =>
        return callback error if error?
        @_modifyPackage callback

  _modifyPackage: (callback) =>
    try
      packageJSON = _.cloneDeep require @packagePath
    catch error
      debug 'modify package.json require error', error
    return callback() unless packageJSON?
    orgPackage = _.cloneDeep packageJSON
    packageJSON.scripts ?= {}
    packageJSON.scripts['test'] ?= 'mocha'
    packageJSON.scripts['coverage'] ?= 'nyc npm test'
    packageJSON.scripts['mocha:json'] ?= 'env NPM_ENV=test mocha --reporter json > coverage/mocha.json'
    packageJSON.scripts['test:watch'] ?= 'mocha -w -R mocha-multi --reporter-options spec=-,mocha-osx-reporter=-'
    packageJSON.devDependencies ?= {}
    packageJSON.devDependencies['nyc'] ?= '^8.3.0'
    packageJSON.devDependencies['mocha-osx-reporter'] ?= '^0.1.2'
    packageJSON.devDependencies['mocha-multi'] ?= '^0.9.1'
    packageJSON.devDependencies['mocha'] ?= '^2.5.3'
    return callback null if _.isEqual packageJSON, orgPackage
    console.log colors.magenta('NOTICE'), colors.white('modifying package.json - make sure you run npm install')
    packageStr = JSON.stringify(packageJSON, null, 2)
    fs.writeFile @packagePath, "#{packageStr}\n", callback

  _modifyTravis: ({ isPrivate }, callback) =>
    yaml.read @travisYml, (error, data) =>
      return callback error if error?
      return callback new Error('Missing .travis.yml') unless data?
      orgData = _.cloneDeep data
      type = 'pro' if isPrivate
      type ?= 'org'
      _.set data, 'notifications.webhooks', [@webhookUrl] unless @hubOnly
      data.after_success ?= []
      after_success = [
        'npm run coverage'
        'npm run mocha:json'
        'bash <(curl -s https://codecov.io/bash)'
        'bash <(curl -s https://codecov.octoblu.com/bash)'
      ]
      _.pullAll data.after_success, after_success
      data.after_success = _.concat data.after_success, after_success
      return callback null if _.isEqual orgData, data
      console.log colors.magenta('NOTICE'), colors.white('modifying .travis.yml')
      yaml.write @travisYml, data, callback

  _modifyDockerfile: (callback) =>
    console.log colors.magenta('NOTICE'), colors.white('make sure you add a HEALTHCHECK to your Dockerfile')
    console.log '  ', colors.cyan('Example'), colors.white('`HEALTHCHECK CMD curl --fail http://localhost:80/healthcheck || exit 1`')
    callback null

module.exports = ProjectService
