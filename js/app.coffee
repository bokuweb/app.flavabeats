_game = null
_gameId = 0
_loadCallback = -> console.log "load"
_endCallback = -> console.log "end"

flavaApp = angular.module('flavaApp', ['ngRoute','ngAnimate', 'ngSanitize'])

flavaApp.config ($routeProvider)->
  $routeProvider
  .when '/',
    templateUrl: 'splash.html'
  .when '/select',
    templateUrl: 'select.html'
  .when '/ouroboros/:id',
    controller: 'gameCtrl'
    templateUrl: 'ouroboros.html'    
  .otherwise
    redirectTo: '/'

flavaApp.controller 'splashCtrl', ($scope)->
  agent = navigator.userAgent
  if agent.search(/(iPhone|iPod|Android|Mobile)/) isnt -1 then $scope.isMobile = on else $scope.isMobile = off

flavaApp.controller 'gameCtrl', ($scope, $routeParams)->
  _gameId = $routeParams.id
  _game = new Game(_loadCallback, _endCallback)
  _game.play(g_music[$routeParams.id])

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
  level = 'Level '
  for i in [0..9] when i < $scope.music.level 
    level += '<i class="fa fa-star-o level"></i>'
  $scope.music.levelIcon = level

