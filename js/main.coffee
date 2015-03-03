class window.Game
  _game =
    core :null
    playMusic : null
    status : "stop"
    pool :
      note : []
    score :
      board: null
      actual:0
      shown:0

  constructor : (parms)->
    for name, value of parms
      _game[name] = value

    enchant()
    _game.core = new Core(980, 600)
    _game.core.fps = 36
    _game.core.preload("img/chara1.png", "img/chara1_shadow.png", "img/logo.png", "img/score.png")
    _game.note.group = new Group()
    _game.note.index = 0

  load : (music)->
    _game.core.preload(music.src, music.img)
    _game.core.start()

    _game.core.onload = ->
      _game.playMusic = _game.core.assets[music.src]

      for i in [0..6]
        noteShadow = new Sprite(_game.note.width, _game.note.height)
        if i % 2
          noteShadow.y = -_game.note.height - 80 + _game.note.fallDistance  
        else
          noteShadow.y = -_game.note.height + _game.note.fallDistance  
        noteShadow.opacity = 0.6
        noteShadow.x = i * _game.note.width + 480
        noteShadow.image = _game.core.assets["img/chara1_shadow.png"]
        _game.core.rootScene.addChild(noteShadow)

      _renderLogo()
    
      info = new Entity()
      info._element = document.createElement('div')
      infoHtml = '<div id="info"><img src="' + music.img + '" class="music-image">
                    <div class="music-description"><span><i class="fa fa-headphones"></i>' + music.title + '</span><br>
                      <span class="author">' + music.by + '</span><br>
                      <span class="license">' + music.license + '</span><br>
                      <span class="level">Level</span>'
      for i in [0..9]
        if i < music.level 
          infoHtml += '<i class="fa fa-star-o level"></i>'
      infoHtml += '</p></div>'

      info._element.innerHTML = infoHtml
      info.width = 560
      info.x = 20
      info.y = 160
        
      _game.score.board = new Score(
        game : _game.core
        offsetX : 20
        offsetY : 360
        url : "img/score.png"  
        num : 6  
        width: 36
        height: 49.7
        )
      _game.score.board.generate()
      _game.score.board.update(0)

      _game.core.rootScene.addChild(info) 
      _game.core.rootScene.addChild(_game.note.group)

      # create and pool note sprite
      for i in [0.._game.note.timing.length - 1]
        note = new Sprite(_game.note.width, _game.note.height)
        note.image = _game.core.assets["img/chara1.png"]
        _poolSprite(_game.pool.note, note)      

      #
      # main animation frame
      # check should notes be generated
      # check game end timng
      #
      _game.core.rootScene.addEventListener "enterframe", ->
        music = _game.playMusic
        note  = _game.note
        if _game.status is "playing"
          if note.timing[note.index]?
            if music.currentTime > (note.timing[note.index] - (note.fallDistance / note.speed)) - (1 / _game.core.fps)
              _generateNote(note.index++)

          # score update
          if _game.score.actual > _game.score.shown
            _game.score.shown += 100000 / _game.note.timing.length / 6
            if _game.score.actual < _game.score.shown then _game.score.shown = _game.score.actual
            _game.score.board.update(Math.ceil(_game.score.shown))

        # game end timing
        if music.currentTime >= _game.time.end or music.duration <= music.currentTime
          if music.volume - 0.1 < 0 then music.volume = 0 else music.volume -= 0.1

          if music.volume <= 0
            music.stop()
            music.volume = 1
            music.currentTime = 0
            _game.status = "stop"
            #_game.callback.end()

  _renderLogo = ()->
    logo = new Sprite(200, 50)
    logo.image = _game.core.assets["img/logo.png"]
    logo.y = 40
    logo.x = 10  
    _game.core.rootScene.addChild(logo)  

  _generateNote = (number)->
    note = _getSprite(_game.pool.note)
    note.number = number
    note.key = _game.note.key[number]
    if note.key % 2
      note.destinationY = -_game.note.height - 80 + _game.note.fallDistance  
      note.y = -_game.note.height - 80
    else
      note.destinationY = -_game.note.height + _game.note.fallDistance  
      note.y = -_game.note.height

    note.x = note.key * note.width + 480
    note.frame  = 0
    note.timing = _game.note.timing[number]
    note.clear  = false
    note.opacity = 1
    note.tl.clear()
    note.tl.setTimeBased()
    note.tl.scaleTo(1, 1, 0)
    note.tl.moveY(note.destinationY, (_game.note.fallDistance / _game.note.speed) * 1000)
    note.hasClearAnimationStarted = false
    _game.note.group.addChild(note)

    #
    # note animation frame
    # monitor whether there is outdated notes
    #
    note.addEventListener "enterframe", ->
      music = _game.playMusic
      note  = _game.note
      threshold = _game.threshold
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
        if -threshold.great < (note.timing[@number] - @clearTime) < threshold.great
          judge = "great"
          _game.score.actual += 100000 / _game.note.timing.length
        else if -threshold.good < (note.timing[@number] - @clearTime) < threshold.good
          judge = "good"
          _game.score.actual += 70000 / _game.note.timing.length
        else
          judge = "bad"

        judgeLabel = new Label(judge)
        judgeLabel.x = 450
        judgeLabel.y = 450
        _game.core.rootScene.addChild(judgeLabel)

        judgeLabel.tl.setTimeBased()
        judgeLabel.tl.fadeOut(300).and().moveY(400, 300).then(()->
          _game.core.rootScene.removeChild(judgeLabel)
        )
        @hasClearAnimationStarted = true

  _poolSprite = (pool, sprite)->
    pool.push(sprite)
    sprite.active = false
    if sprite.addEventListener
      sprite.addEventListener "removed", ()->
        @active = false

  _getSprite = (pool)->
    for value, i in pool
      unless value.active
        value.active = true
        return value
    console.log "error sprite pool empty"
    return false

  # keydown event detected
  document.addEventListener "keydown", (e)->

    music = _game.playMusic
    if _game.status is "stop"
      if e.keyCode is 13
        music.play()
        _game.status = "playing"




    else if _game.status = "playing"
      console.log "timing = " + music.currentTime    
      for value in _game.note.group.childNodes
        switch e.keyCode
          when 90 then code = 0 # Z
          when 83 then code = 1 # S
          when 88 then code = 2 # X
          when 68 then code = 3 # D
          when 67 then code = 4 # C
          when 70 then code = 5 # F
          when 86 then code = 6 # V
          else code = null
        if value.key is code
          if -1 < value.timing - music.currentTime < 1
            value.clear = true
            value.clearTime = music.currentTime
            console.log value.clearTime
            break
