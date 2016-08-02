assert = require 'power-assert'
sinon = require 'sinon'

describe 'fitebot', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()

    @api = 
      badger: sinon.spy()

    require('../src/fitebot')(@robot)
    require('../src/api')(@api)

  it 'registers a respond listener', ->
    assert.ok(@robot.respond.calledWith(/hello/))

  it 'registers a hear listener', ->
    assert.ok(@robot.hear.calledWith(/orly/))


  it 'responds to badger', ->
    assert.ok(@robot.hear.calledWith(/badger/i))

  it 'responds to badger with what?!', ->
    console.log 'hey there'
    console.log @api.badger()
    console.log @api.shout()

describe 'simple msgs', ->
    beforeEach ->
      @api = {}
      require('../src/api')(@api)

    it 'responds to badger', ->
      assert.ok(@api.badger())

    it 'badgers and asks what', ->
      assert.equal(@api.badger(), 'what?!')
