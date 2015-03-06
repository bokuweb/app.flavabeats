class @Game
  _fallDist = 550
  _noteWidth = 64
  _noteHeight = 64
  _endTime = 90
  _threshold =
    great : 0.1
    good : 0.2

  _game = null
  _status = "stop"
  _pool =
    note : []

  _score =
    board: null
    actual:0
    shown:0

  _n = null

  constructor : (parms)->
    enchant()
    _game = new Core(980, 600)
    _game.fps = 60
    _game.preload("img/chara1.png", "img/chara1_shadow.png", "img/logo.png", "img/score.png")

  play : (music)->
    _game.preload(music.src, music.img)
    _endTime = music.endTime
    _n = new Note(_game, music.note)
    _game.start()

    _game.onload = ->
      _game.music = _game.assets[music.src]
      _score.board = new Score(
        game : _game
        offsetX : 20
        offsetY : 360
        url : "img/score.png"
        num : 6
        width: 36
        height: 49.7
        )
      _n.init()
      _score.board.generate()
      _score.board.update(0)
      _game.rootScene.addEventListener "enterframe", ->
        if _status is "playing"
           _n.create()
          # score update
          if _score.actual > _score.shown
            _score.shown += 100000 / _note.timing.length / 6
            if _score.actual < _score.shown then _score.shown = _score.actual
            _score.board.update(Math.ceil(_score.shown))
        _endGameIfTimeOver()

  _endGameIfTimeOver = ->
    music = _game.music
    if music.currentTime >= _endTime or music.duration <= music.currentTime
      if music.volume - 0.1 < 0 then music.volume = 0 else music.volume -= 0.1
      if music.volume <= 0
        music.stop()
        music.volume = 1
        music.currentTime = 0
        _status = "stop"
        #_game.callback.end()

  # keydown event detected
  document.addEventListener "keydown", (e)->
    music = _game.music
    if _status is "stop"
      if e.keyCode is 13
        music.play()
        _status = "playing"

    else if _status = "playing"
      for value in _note.group.childNodes
        switch e.keyCode
          when 90 then code = 0 # Z
          when 83 then code = 1 # S
          when 88 then code = 2 # X
          when 68 then code = 3 # D
          when 67 then code = 4 # C
          else code = null
        if value.key is code
          if -1 < value.timing - music.currentTime < 1
            value.clear = true
            value.clearTime = music.currentTime
            break
      return


class Note
  _game = null
  _pool = []
  _fallDist = 550
  _noteWidth = 64
  _noteHeight = 64
  _note =
    index : 0
    group : null
    timing : []
    key : []
    speed : 0

  constructor : (game, params)->
    _game = game
    _note.timing = params.timing
    console.log _note.timing
    _note.key = params.key
    _note.speed = params.speed

  init : ->
    _note.group = new Group()
    _note.index = 0
    _renderDist()
    _preAllocate()
    _game.rootScene.addChild(_note.group)

  create : ->
    if _note.timing[_note.index]?
      if _game.music.currentTime > (_note.timing[_note.index] - (_fallDist / _note.speed)) then _gen(_note.index++)

  _renderDist = ->
    for i in [0...5]
      noteShadow = new Sprite(_noteWidth, _noteHeight)
      noteShadow.y = -_noteHeight + _fallDist
      noteShadow.opacity = 0.6
      noteShadow.x = i * ( _noteWidth + 20) + 480
      noteShadow.image = _game.assets["img/chara1_shadow.png"]
      _game.rootScene.addChild(noteShadow)
    return

  _preAllocate = ->
    for v in _note.timing
      note = new Sprite(_noteWidth, _noteHeight)
      note.image = _game.assets["img/chara1.png"]
      GameSys.poolSprite(_pool, note)
    return

  _gen = (number)->
    note = GameSys.getSprite(_pool)
    note.number = number
    note.key = _note.key[number]
    note.destinationY = -_noteHeight + _fallDist  
    note.y = -_noteHeight
    note.x = note.key * (note.width+20) + 480
    note.frame  = 0
    note.timing = _note.timing[number]
    note.clear  = false
    note.opacity = 1
    note.tl.clear()
    note.tl.setTimeBased()
    note.tl.scaleTo(1, 1, 0)
    note.tl.moveY(note.destinationY, (_fallDist / _note.speed) * 1000)
    note.hasClearAnimationStarted = false
    _note.group.addChild(note)
    #
    # note animation frame
    # monitor whether there is outdated notes
    #
    note.addEventListener "enterframe", ->
      music = _game.music
      note  = _note
      if @oldtime?
        @rotate((music.currentTime - @oldtime) * 500)
      @oldtime = music.currentTime

      if note.timing[@number] - music.currentTime < -1
        @tl.fadeOut(300).then(()->
          note.group.removeChild(@)
        )
      #
      # clear note animation
      # define animation when note cleared
      #
      if @clear and not @hasClearAnimationStarted
        @tl.clear()
        @tl.scaleTo(1.5, 1.5, 200).and().fadeOut(200).then(()->
          note.group.removeChild(@)
        )
        if -_threshold.great < (note.timing[@number] - @clearTime) < _threshold.great
          judge = "great"
          _game.score.actual += 100000 / _note.timing.length
        else if -_threshold.good < (note.timing[@number] - @clearTime) < _threshold.good
          judge = "good"
          _game.score.actual += 70000 / _note.timing.length
        else
          judge = "bad"

        judgeLabel = new Label(judge)
        judgeLabel.x = 450
        judgeLabel.y = 450
        _game.rootScene.addChild(judgeLabel)

        judgeLabel.tl.setTimeBased()
        judgeLabel.tl.fadeOut(300).and().moveY(400, 300).then(()->
          _game.rootScene.removeChild(judgeLabel)
        )
        @hasClearAnimationStarted = true


class GameSys
  @getSprite : (pool)->
    for value, i in pool
      unless value.active
        value.active = true
        return value
    console.log "error sprite pool empty"
    return false

  @poolSprite : (pool, sprite)->
    pool.push(sprite)
    sprite.active = false
    if sprite.addEventListener
      sprite.addEventListener "removed", ()->
        @active = false

  #@getResouce : (src)-> _game.assets[src]
