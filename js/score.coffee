class window.Score
  _group = null
  constructor : (parms)->
    for name, value of parms
      @[name] = value
      console.log value

  generate : ()->
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

  update : (score)->
    base = Math.pow(10, @num - 1)
    for value in _group.childNodes
      value.frame = ~~(score / base)
      score = score % base
      base = base / 10

       		
