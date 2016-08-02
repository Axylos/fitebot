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

describe 'simple msgs', ->
    beforeEach ->
      @api = {}
      require('../src/api')(@api)

    it 'responds to badger', ->
      assert.ok(@api.badger())

    it 'badgers and asks what', ->
      assert.equal(@api.badger(), 'what?!')

describe 'db api', ->
    beforeEach ->
      @api = {}
      require('../src/api')(@api)

    it 'gets current list when empty', ->
      @api.get_current_list().then (data) ->
        assert.equal(data, undefined)

    it 'can make a list', ->
      @api.create_list('new_list').then (data) ->
        console.log data
        assert.ok(data)

    it 'gets a pending list when there is one', ->
      @api.get_pending_list().then (data) ->
        assert.ok(data)
        assert.ok(data.listid > 0)

    it 'gets current list when there is not an active current list', ->
      @api.get_current_list().then (data) ->
        assert.equal(data, undefined)

    it 'can add a fite with no description', ->
      @api.add_fite('left', 'right').then (data) ->
        assert.ok(data)

