Fanout = ->
  listeners = []
  {
    register: (callback) ->
      listeners.push callback
    invoke: ->
      args = `arguments`
      for callback in listeners
        callback.apply null, args
  }

module.exports = Theta = do ->
  {
    create: (parent) ->
      running = true
      errors = Fanout()
      discarded = Fanout()
      parent ?=
        wrap: (callback) ->
          -> callback()

      wrap = (callback) ->
        parent.wrap ->
          if running
            try
              callback()
            catch error
              errors.invoke(error)
              throw error

      timeouts = {}

      context = {
        create: -> Theta.create(context)
        time: -> new Date()
        timeout: (timeout, callback) ->
          id = setTimeout(wrap(callback), timeout)
          timeouts[id] = true
        wrap: wrap
        onError: errors.register
        stop: ->
          running = false
          for id in timeouts
            clearTimeout(id)
            delete timeouts[id]
      }
  }