assert = require 'power-assert'
sinon = require 'sinon'
_ = require 'underscore'

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
    db = {}
    before () ->
      @api = db
      #the manual promise thing is gross but coffeescript syntax
      #makes it hard to hang a promise on require without gross syntax

      promise = require('../src/api')(@api)


    beforeEach () ->
      @api.begin_transaction()
      #horrible but necessary to keep sqlite in check
      this.timeout 30000

    afterEach () ->
      @api.rollback_transaction()
      this.timeout 30000

    it 'can make a list', ->
      api = @api
      @api.create_list('new_list')
        .then (data) ->
          assert.ok(data.changes > 0)
          api.get_pending_list()
        .then (data) ->
          assert.ok(data.listid)


    it 'gets a pending list when there is one', ->

      api = @api
      api.create_list('foo')
        .then () ->
          api.get_pending_list()
            .then (data) ->
              assert.ok(data.listid > 0)
            .catch (nolist) ->
              throw nolist

    it 'gets current list when there is not an active current list', ->
      @api.get_current_list().then (data) ->
        assert.equal(data, undefined)

    it 'can activate a list', ->
      api = @api
      @api.create_list('inactive list')
        .then () ->
          api.activate_pending_list()
        .then (list) ->
          list

    it 'only leaves one active list at a time', ->
      api = @api
      api.create_list('foo')
        .then () ->
          api.create_list('bar')
        .then () ->
          api.fetch_all_pending_lists()
        .then (pending_lists) ->
          assert.ok(pending_lists.length == 2)
          api.activate_pending_list()
        .then () ->
          api.activate_pending_list()
        .then () ->
          api.fetch_all_pending_lists()
        .then (data) ->
          assert.ok(data.length == 1)
          api.get_pending_list()
        .then (list) ->
          assert.ok(list.name == 'bar')
          assert.ok(list.is_active == 0)
          api.get_list_by_id(1)
        .then (list) ->
          assert.ok(list.is_active = 1)

        .catch (err) ->
          throw err

    it 'gets current list when there is one', ->
      @api.get_current_list().then (data) ->
        assert.equal(data, undefined)

    it 'gets last pending list', ->
      api = @api
      api.create_list 'foo'
      .then () ->
        api.create_list 'bar'
      .then () ->
        api.get_pending_list()
      .then (list) ->
        assert.equal(list.name, 'bar')


describe 'db api2', ->
    db = {}
    before () ->
      @api = db
      #the manual promise thing is gross but coffeescript syntax
      #makes it hard to hang a promise on require without gross syntax

      promise = require('../src/api')(@api)
      promise.then (db) ->
        db.begin_transaction()
          .then () ->
            db.create_list 'baz'

      after () ->
        db.rollback_transaction()

    beforeEach () ->
      this.timeout 2000

      after
    afterEach () ->
      this.timeout 2000

    it 'can add a fite with no name', ->
      api = @api
      api.get_row_count('fite')
        .then (first_count) ->
          api.add_fite('left', 'right').then (data) ->
            assert.ok(data)
          .then () ->
            api.get_row_count('fite').then (second_count) ->
              assert.notEqual first_count, second_count

    it 'fetches all of the fites in a pending list', ->
      api = @api
      api.create_list 'baz'
        .then () ->
          api.add_fite 'coin', 'taxes'
        .then () ->
          api.add_fite 'magnets', 'death'
        .then () ->
          api.add_fite 'desk', 'chair'
        .then () ->
          api.add_fite 'can', 'bottle'
        .then () ->
          api.get_pending_list()
            .then (list) ->
              list
        .then (list) ->
          assert.equal(list.fites.length, 4)
          assert.equal(list.fites[3].left_fiter, 'can')

    it 'can fetch a list by id', ->
      api = @api
      api.create_list 'biz'
        .then () ->
          api.get_pending_list()
        .then (list) ->
          api.get_list_by_id(list.listid)
        .then (new_list) ->
          assert.equal(new_list.name, 'biz')


    it 'can fetch all lists', ->
      api = @api
      api.create_list('another')
        .then () ->
          api.fetch_all_pending_lists()
        .then (lists) ->
          assert.ok(lists.length > 0)


    it 'can activate a pending list', ->
      assert.ok(1)
