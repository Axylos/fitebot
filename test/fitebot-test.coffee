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

    it 'gets current list when empty', ->
      @api.get_current_list().then (data) ->
        assert.equal(data, undefined)

    it 'can make a list', ->
      @api.create_list('new_list').then (data) ->
        assert.ok(data)

    it 'gets a pending list when there is one', ->

      @api.get_pending_list()
        .then (data) ->
          assert.ok(data)
          #assert.ok(data.listid > 0)
        .catch (err) ->
          console.log err

    it 'gets current list when there is not an active current list', ->
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

    describe 'fetching', ->
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
        api.fetch_all_lists()
          .then (lists) ->
            assert.ok(lists.length > 0)
            assert.ok()

