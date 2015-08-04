{BufferedProcess, CompositeDisposable} = require 'atom'

module.exports =
  config:
    puppetExecutablePath:
      default: 'puppet'
      title: 'Puppet Executable Path'
      type: 'string'
    puppetArguments:
      default: '--disable_warnings=deprecations'
      title: 'Puppet Arguments'
      type: 'string'

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.config.observe 'linter-puppet-parser.puppetExecutablePath',
      (executablePath) =>
        @executablePath = executablePath
    @subscriptions.add atom.config.observe 'linter-puppet-parser.puppetArguments',
      (args) =>
        @args = args.split(' ')
  deactivate: ->
    @subscriptions.dispose()

  puppetParserLinter: ->
    provider =
      grammarScopes: ['source.puppet']
      scope: 'file'
      lintOnFly: false
      lint: (textEditor) =>
        return new Promise (resolve, reject) =>
          filePath = textEditor.getPath()
          regex = [ /(Warning|Error): (.+?) at [^\s]+?:(\d+):?(\d*)/,
                    /(Warning|Error): (.+?) in file [^\s]+ [oa][nt] line (\d+):?(\d*)/,
                    /(Warning|Error): (.+?) on line (\d+):?(\d*) in file [^\s]+/ ]
          filter = [ ]
          msg = ''
          arg = [ 'parser', 'validate', '--color=false', '--render-as=s' ]
          arg = arg.concat(@args.slice(0))
          arg.push filePath
          process = new BufferedProcess
            command: @executablePath
            args: arg
            stdout: (data) ->
              out = data
            stderr: (errdata) ->
              msg = errdata
            exit: (code) ->
              if code isnt 0 and code isnt 1
                atom.notifications.addError "Failed to run #{@executablePath} #{JSON.stringify(arg)}",
                  detail: "Exit Code: #{code}\n#{msg}"
                  dismissable: true
                return resolve []
              if msg is ''
                return resolve []
              msgA = msg.split('\n')
              msgA = msgA.filter (m) -> m isnt ''
              msgA = msgA.filter (m) ->
                for re in regex
                  if m.match re
                    return true
                return false
              msgA = msgA.filter (m) ->
                for f in filter
                  if m.match f
                    return false
                return true
              resolve msgA.map (err) ->
                for re in regex
                  if err.match re
                    [mAll, mType, mText, mLine, mCol] = err.match re
                # mCol only in puppet-4
                if mCol is ''
                  mCol = 1
                type: mType
                #text: mText
                text: mAll
                filePath: filePath
                range: [
                  [parseInt(mLine) - 1, parseInt(mCol) - 1],
                  [parseInt(mLine) - 1, parseInt(mCol) - 1]
                ]

          process.onWillThrowError ({error, handle}) ->
            atom.notifications.addError "Failed to run #{@executablePath}",
              detail: "#{error.messages}"
              dismissable: true
            handle()
            resolve []
