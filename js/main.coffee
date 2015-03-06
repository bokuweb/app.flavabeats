class @Game
  _endTime = 90
  _game = null
  _status = "stop"
  _score =
    board : null
    val : 0
  _note = null
  _loadCallback = null
  _endCallback = null
  
  constructor : (loadCallback, endCallback)->
    _loadCallback = loadCallback
    _endCallback = endCallback    
    enchant()
    _game = new Core 980, 600
    _game.fps = 60
    _game.preload "img/chara1.png", "img/chara1_shadow.png", "img/logo.png", "img/score.png"

  play : (music)->
    _game.preload music.src, music.img
    _game.start()
    _game.onload = ->
      _endTime = music.endTime
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
      _score.board.init()
      _score.val = 0
      _note = new Note _game, music.note, _judgeEndCallback
      _note.init()
      _game.rootScene.addEventListener "enterframe", ->
        if _status is "playing"
          _note.create()
          _endGameIfTimeOver()
      _loadCallback()

  _judgeEndCallback = (judge)->
    if judge is "Great" then _score.val += 100000 / _note.getNum()
    else if judge is "Good" then _score.val += 70000 / _note.getNum()
    _score.board.update Math.ceil(_score.val)

  _endGameIfTimeOver = ->
    music = _game.music
    if music.currentTime >= _endTime or music.duration <= music.currentTime
      if music.volume - 0.1 < 0 then music.volume = 0 else music.volume -= 0.1
      if music.volume <= 0
        music.stop()
        music.volume = 1
        music.currentTime = 0
        _status = "stop"
        _endCallback()

  # keydown event detected
  document.addEventListener "keydown", (e)->
    music = _game.music
    if _status is "stop"
      if e.keyCode is 13
        music.play()
        _status = "playing"
    else if _status = "playing" then _note.seek(e.keyCode)


class Note
  _game = null
  _pool = []
  _fallDist = 550
  _width = 64
  _height = 64
  _index = 0
  _group = null
  _timing = []
  _key = []
  _speed = 0
  _cb = null
  _threshold =
    great : 0.1
    good : 0.2

  constructor : (game, params, cb)->
    _game = game
    _timing = params.timing
    _key = params.key
    _speed = params.speed
    _cb = cb

  init : ->
    _group = new Group()
    _index = 0
    _renderDist()
    _preAllocate()
    _game.rootScene.addChild(_group)

  create : ->
    if _timing[_index]?
      if _game.music.currentTime > (_timing[_index] - (_fallDist / _speed)) then _gen(_index++)

  seek : (keyCode)->
    switch keyCode
      when 90 then code = 0 # Z
      when 83 then code = 1 # S
      when 88 then code = 2 # X
      when 68 then code = 3 # D
      when 67 then code = 4 # C
      else
    for value in _group.childNodes
      if value.key is code
        if -1 < value.timing - _game.music.currentTime < 1
          value.clear = true
          value.clearTime = _game.music.currentTime
          break
    return

  getNum : -> _timing.length
    
  _renderDist = ->
    for i in [0...5]
      noteDist = new Sprite(_width, _height)
      noteDist.y = -_height + _fallDist
      noteDist.opacity = 0.6
      noteDist.x = i * ( _width + 20) + 480
      noteDist.image = _game.assets["img/chara1_shadow.png"]
      _game.rootScene.addChild(noteDist)
    return

  _preAllocate = ->
    for v in _timing
      note = new Sprite(_width, _height)
      note.image = _game.assets["img/chara1.png"]
      GameSys.poolSprite(_pool, note)
    return

  _gen = (number)->
    note = GameSys.getSprite(_pool)
    note.number = number
    note.key = _key[number]
    note.destinationY = -_height + _fallDist  
    note.y = -_height
    note.x = note.key * (note.width+20) + 480
    note.frame  = 0
    note.timing = _timing[number]
    note.clear  = false
    note.opacity = 1
    note.tl.clear()
    note.tl.setTimeBased()
    note.tl.scaleTo(1, 1, 0)
    note.tl.moveY(note.destinationY, (_fallDist / _speed) * 1000)
    note.hasClearAnimationStarted = false
    _group.addChild(note)
    note.addEventListener "enterframe", _schedule

  _schedule = ->
    music = _game.music
    if @oldtime?
      @rotate((music.currentTime - @oldtime) * 500)
    @oldtime = music.currentTime

    if _timing[@number] - music.currentTime < -1
      @tl.fadeOut(300).then ()-> _group.removeChild(@)

    if @clear and not @hasClearAnimationStarted
      @tl.clear()
      @tl.scaleTo(1.5, 1.5, 200).and().fadeOut(200).then ()-> _group.removeChild(@)
      diffTime = _timing[@number] - @clearTime
      judgement = _judge(diffTime)
      @hasClearAnimationStarted = true

  _judge = (diffTime)->
    if -_threshold.great < diffTime < _threshold.great then judge = "Great"
    else if -_threshold.good < diffTime < _threshold.good then judge = "Good"
    else judge = "Bad"
    judgeLabel = new Label(judge)
    judgeLabel.x = 450
    judgeLabel.y = 450
    _game.rootScene.addChild(judgeLabel)
    judgeLabel.tl.setTimeBased()
    judgeLabel.tl.fadeOut(300).and().moveY(400, 300).then ()-> _game.rootScene.removeChild(judgeLabel)
    _cb(judge)

class Score
  _group = null
  _real = 0
  _display = 0
  constructor : (parms)->
    for name, value of parms
      @[name] = value

  init : ->
    i = 0
    _group = new Group()
    while i < @num
      score = new Sprite(@width, @height)
      score.image = @game.assets[@url]
      score.frame = i
      score.x = @offsetX + score.width * i
      score.y = @offsetY
      _group.addChild(score)   
      i++
    @game.rootScene.addChild(_group)
    @update 0

  update : (score)->
    base = Math.pow(10, @num - 1)
    for value in _group.childNodes
      value.frame = ~~(score / base)
      score = score % base
      base = base / 10

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
        @clearEventListener "enterframe"
        @active = false
