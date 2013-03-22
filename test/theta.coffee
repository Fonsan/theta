theta = require "../lib/theta"
moment = require "moment"

describe 'Theta', ->

  context = null

  beforeEach ->
    context = theta.create()

  afterEach ->
    context.stop()
    context = null

  describe 'wrap', ->
    it 'any callback', ->
      ran = false
      callback = context.wrap -> ran = true
      callback()
      ran.should.be.ok

    it 'does not run wrapped callback when stopped', ->
      ran = false
      callback = context.wrap -> ran = true
      context.stop()
      callback()
      ran.should.not.be.ok

    it 'reflects errors', (done) ->
      error = new Error('foo')
      catcher = (e) ->
        e.should.equal(error)
        done()
      context.onError catcher
      (->
        context.wrap((-> throw error))()
      ).should.throw(error)

  describe 'timeout', ->
    it 'provides time', ->
      context.time().getTime().should.be.above(1)

    it 'delays work', (done) ->
      context = theta.create()
      time = moment(context.time())
      delay = 5
      context.timeout delay, ->
        moment(context.time()).
          should.be.above(time.add(delay - 1, 'millisecond'))
        done()

    it 'does not run work if stopped', (done) ->
      context = theta.create()
      time = moment(context.time())
      delay = 5
      ran = false
      context.timeout delay, ->
        ran = true
      context.stop()
      setTimeout(
        (->
          ran.should.not.be.ok
          done()
        ), delay + 1)

  describe 'subcontexts', ->
    subcontext = null
    beforeEach ->
      subcontext = context.create()

    it 'runs wrapped', (done) ->
      subcontext.wrap(-> done())()

    it 'propagates errors to parent', (done) ->
      context.onError -> done()
      error = new Error('fail')
      (->
        subcontext.wrap(-> throw error)()
      ).should.throw(error)

