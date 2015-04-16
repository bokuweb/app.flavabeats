flavaApp = angular.module('flavaApp', ['ngRoute','ngAnimate', 'ngSanitize'])

_gameId = 0
_game = null

flavaApp.config ($routeProvider)->
  $routeProvider
  .when '/',
    templateUrl: 'splash.html'
  .when '/select',
    templateUrl: 'select.html'
  .when '/help',
    templateUrl: 'help.html'
  .when '/game/:id',
    controller: 'GameCtrl'
    templateUrl: 'game.html'
  .otherwise
    redirectTo: '/'

flavaApp.controller 'SplashCtrl', ($scope)->
  agent = navigator.userAgent
  if agent.search(/(iPhone|iPod|Android|Mobile)/) isnt -1 then $scope.isMobile = on else $scope.isMobile = off


flavaApp.controller 'GameCtrl', ($scope, $routeParams)->
  $scope.end = off
  $scope.loaded = off
  $scope.start = off

  _loadCallback = ->
    console.log "load complete"
    $scope.$apply ()->
      $scope.loaded = on
      $scope.start = on

  _startCallback = ->
    $scope.$apply ()->
      $scope.start = off

  _endCallback = (score, log)->
    storage = localStorage
    console.log "end!!! " + score
    $scope.$apply ()->
      $scope.end = on
      $scope.score = score
      if score > 97500      then  $scope.rank ="SSS"
      else if score > 95000 then  $scope.rank ="SS"
      else if score > 92500 then  $scope.rank ="S"
      else if score > 90000 then  $scope.rank ="A"
      else if score > 80000 then  $scope.rank ="B"
      else if score > 70000 then  $scope.rank ="C"
      else $scope.rank ="D"

      if $scope.rank is "D" then $scope.result = "Failed" else
        if $scope.score >= 100000 then $scope.result = "Perfect!!" else $scope.result = "Clear!" 
      $scope.tweet = "http://twitter.com/?status="+g_music[_gameId].title+" "+$scope.result+" score "+$scope.score+" rank "+$scope.rank+" http://prototype.flavabeats.net/"

      if storage.getItem(_gameId)? or storage.getItem(_gameId) < score then storage.setItem _gameId, score
      $scope.key = ""
      $scope.timing = ""
      for v in log.key then $scope.key += v + ","
      for v, i in log.timing
        if i > 0
          diff = v - log.timing[i-1]
          v = log.timing[i-1] if diff < 0.05
        $scope.timing += v + ","

  _gameId = $routeParams.id
  unless _game? then _game = new Game()
  _game.start(g_music[$routeParams.id], _loadCallback, _startCallback, _endCallback)

flavaApp.controller 'SelectCtrl', ($scope)->
  $scope.desc = off
  $scope.music = g_music
  for value in $scope.music
    level = 'Level '
    for i in [0..9] when i < value.level
      level += '<i class="fa fa-star-o level"></i>'
    value.levelIcon = level
  $scope.changeSort =-> $scope.desc = not $scope.desc

flavaApp.controller 'GameInfoCtrl', ($scope)->
  $scope.music = g_music[_gameId]
  storage = localStorage
  level = 'Level '
  for i in [0..9] when i < $scope.music.level
    level += '<i class="fa fa-star-o level"></i>'
  $scope.music.levelIcon = level

  if storage.getItem(_gameId)? then $scope.music.highScore = storage.getItem(_gameId) else $scope.music.highScore = "none"

