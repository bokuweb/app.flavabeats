flavaApp = angular.module('flavaApp', ['ngRoute','ngAnimate'])

flavaApp.config ($routeProvider)->
  $routeProvider
  .when '/',
    templateUrl: 'splash.html'
  .when '/select',
    templateUrl: 'select.html'
  .when '/ouroboros',
    controller: 'gameCtrl'
    templateUrl: 'ouroboros.html'    
  .otherwise
    redirectTo: '/'

flavaApp.controller 'gameCtrl', ($http, $scope)->
  console.log "game"
  game = new Game(
    note:
      timing : [2.317,4.521,6.759,8.982,11.269,13.500,15.731,18.002,20.242,22.448,24.753,26.960,29.180,31.455,33.730,35.899,38.170,40.377,42.665,44.886,47.127,49.354,51.654,53.825,56.081,58.306,60.544,62.781,65.039,67.278,69.498,71.773,74.010,76.216,80.793,83.015,85.224,89.752,92.022,94.294]
      key : [0, 1, 2, 3 , 4 , 5, 6, 5 , 4 , 3 , 2 , 1, 1, 2, 3 , 4 , 5, 6, 5 , 4 , 3 , 2 , 1, 1, 2, 3 , 4 , 5, 6, 5 , 4 , 3 , 2 , 1, 1, 2, 3 , 4 , 5, 6, 5 , 4 , 3 , 2 , 1, 1, 2, 3 , 4 , 5, 6, 5 , 4 , 3 , 2 , 1]
      speed : 500
      fallDistance : 550
      width : 64
      height : 64
    threshold:
      great: 0.2
      good: 0.4
    time:
      end: 20
  )  
  game.load(
    src : "music/Ouroboros.mp3"
    img : "music/ouroboros.jpg"
    title : "ouroboros"
    by : "2Mello"
    license : "Licensed under Creative Commons<br>By Attribution-NonCommercial 3.0"
    level : 5
  )

flavaApp.controller 'MainCtrl', ($scope)->
  console.log "main"
  $scope.desc = off
  $scope.music = [
    {title: 'ouroboros',  level: 30}
    {title: 'ouroboros',  level: 29}
    {title: 'ouroboros',  level: 11}
    {title: 'ouroboros',  level: 19}
  ]

  $scope.changeSort =->
    console.log "change"
    $scope.desc = not $scope.desc
