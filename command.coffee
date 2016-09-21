colors      = require 'colors'
program     = require 'commander'
packageJSON = require './package.json'

program
  .version packageJSON.version
  .command 'configure', 'configure a project to work with deploy-state'
  .command 'list', 'list deployments'
  .command 'status', 'get the status of a deploy'
  .command 'watch', 'watch the status of a deploy'

class Command
  constructor: ->
    process.on 'uncaughtException', @die
    {@runningCommand} = @parseOptions()

  parseOptions: =>
    program.parse process.argv
    { runningCommand } = program
    return { runningCommand }

  run: =>
    return if @runningCommand
    program.outputHelp()
    process.exit 0

  die: (error) =>
    return process.exit(0) unless error?
    console.error 'ERROR'
    console.error error.stack
    process.exit 1

module.exports = Command
