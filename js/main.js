// Generated by CoffeeScript 1.8.0
(function() {
  var GameSys, Note, Score;

  this.Game = (function() {
    var _endCallback, _endGameIfTimeOver, _endTime, _game, _hasLoaded, _judgeEndCallback, _loadCallback, _log, _mainLoop, _note, _score, _startCallback, _status;

    _endTime = 90;

    _game = null;

    _status = "stop";

    _score = {
      board: null,
      val: 0
    };

    _note = null;

    _loadCallback = null;

    _endCallback = null;

    _startCallback = null;

    _hasLoaded = false;

    _log = {
      key: [],
      timing: []
    };

    function Game() {
      enchant();
    }

    Game.prototype.start = function(music, loadCallback, startCallback, endCallback) {
      _loadCallback = loadCallback;
      _startCallback = startCallback;
      _endCallback = endCallback;
      _game = new Core(980, 600);
      _game.fps = 60;
      _game.preload.apply(_game, g_resouces);
      _game.preload(music.src, music.img);
      _game.start();
      return _game.onload = function() {
        _endTime = music.endTime;
        _game.music = _game.assets[music.src];
        _score.board = new Score({
          game: _game,
          offsetX: 20,
          offsetY: 360,
          url: g_res.score,
          num: 6,
          width: 36,
          height: 49.7
        });
        _score.board.init();
        _score.val = 0;
        _note = new Note(_game, music.note, _judgeEndCallback);
        _note.init();
        _game.rootScene.addEventListener("enterframe", function() {
          if (_status === "playing") {
            _note.create();
            return _endGameIfTimeOver();
          }
        });
        _loadCallback();
        return _hasLoaded = true;
      };
    };

    _mainLoop = function() {
      if (_status === "playing") {
        _note.create();
        return _endGameIfTimeOver();
      }
    };

    _judgeEndCallback = function(judge) {
      if (judge === "Great") {
        _score.val += 100000 / _note.getNum();
      } else if (judge === "Good") {
        _score.val += 70000 / _note.getNum();
      }
      if (_score.val > 100000) {
        _score.val = 100000;
      }
      return _score.board.update(Math.ceil(_score.val));
    };

    _endGameIfTimeOver = function() {
      var music;
      music = _game.music;
      if (music.currentTime >= _endTime || music.duration <= music.currentTime) {
        if (music.volume - 0.005 < 0) {
          music.volume = 0;
        } else {
          music.volume -= 0.005;
        }
        if (music.volume <= 0) {
          music.volume = 1;
          music.currentTime = 0;
          music.stop();
          _status = "stop";
          console.log(_log.key);
          console.log(_log.timing);
          return _endCallback(Math.ceil(_score.val), _log);
        }
      }
    };

    document.addEventListener("keydown", function(e) {
      var code, music;
      music = _game.music;
      if (_status === "stop") {
        if (_hasLoaded) {
          if (e.keyCode === 13) {
            _startCallback();
            _status = "playing";
            setTimeout(function() {
              return music.play();
            }, 1000);
          }
        }
      } else if (_status = "playing") {
        code = _note.seek(e.keyCode);
      }
      if ((0 <= code && code <= 4)) {
        _log.key.push(code);
        return _log.timing.push(_game.music.currentTime);
      }
    });

    return Game;

  })();

  Note = (function() {
    var JUDGE_LABEL_X, JUDGE_LABEL_Y, NOTE_MARGIN_RIGHT, NOTE_OFFSET_X, _cb, _fallDist, _game, _gen, _group, _height, _index, _judge, _key, _pool, _preAllocate, _renderDist, _schedule, _speed, _threshold, _timing, _width;

    NOTE_MARGIN_RIGHT = 20;

    NOTE_OFFSET_X = 480;

    JUDGE_LABEL_X = 500;

    JUDGE_LABEL_Y = 280;

    _game = null;

    _pool = [];

    _fallDist = 550;

    _width = 64;

    _height = 64;

    _index = 0;

    _group = null;

    _timing = [];

    _key = [];

    _speed = 0;

    _cb = null;

    _threshold = {
      great: 0.15,
      good: 0.3
    };

    function Note(game, params, cb) {
      _game = game;
      _timing = params.timing;
      _key = params.key;
      _speed = params.speed;
      _cb = cb;
    }

    Note.prototype.init = function() {
      _group = new Group();
      _index = 0;
      _renderDist();
      _preAllocate();
      return _game.rootScene.addChild(_group);
    };

    Note.prototype.create = function() {
      if (_timing[_index] != null) {
        if (_game.music.currentTime > (_timing[_index] - (_fallDist / _speed))) {
          return _gen(_index++);
        }
      }
    };

    Note.prototype.seek = function(keyCode) {
      var code, value, _i, _len, _ref, _ref1;
      switch (keyCode) {
        case 90:
          code = 0;
          break;
        case 88:
          code = 1;
          break;
        case 67:
          code = 2;
          break;
        case 86:
          code = 3;
          break;
        case 66:
          code = 4;
          break;
        default:
          code = null;
      }
      _ref = _group.childNodes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        value = _ref[_i];
        if (value.key === code) {
          if ((-1 < (_ref1 = value.timing - _game.music.currentTime) && _ref1 < 1)) {
            value.clear = true;
            value.clearTime = _game.music.currentTime;
            break;
          }
        }
      }
      return code;
    };

    Note.prototype.getNum = function() {
      return _timing.length;
    };

    _renderDist = function() {
      var i, noteDist, _i;
      for (i = _i = 0; _i < 5; i = ++_i) {
        noteDist = new Sprite(_width, _height);
        noteDist.y = -_height + _fallDist;
        noteDist.opacity = 0.6;
        noteDist.x = i * (_width + NOTE_MARGIN_RIGHT) + NOTE_OFFSET_X;
        noteDist.image = _game.assets[g_res.noteDist];
        _game.rootScene.addChild(noteDist);
      }
    };

    _preAllocate = function() {
      var note, v, _i, _len;
      for (_i = 0, _len = _timing.length; _i < _len; _i++) {
        v = _timing[_i];
        note = new Sprite(_width, _height);
        note.image = _game.assets[g_res.note];
        GameSys.poolSprite(_pool, note);
      }
    };

    _gen = function(number) {
      var note;
      note = GameSys.getSprite(_pool);
      note.number = number;
      note.key = _key[number];
      note.destinationY = -_height + _fallDist;
      note.y = -_height;
      note.x = note.key * (note.width + NOTE_MARGIN_RIGHT) + NOTE_OFFSET_X;
      note.frame = 0;
      note.timing = _timing[number];
      note.clear = false;
      note.opacity = 1;
      note.tl.clear();
      note.tl.setTimeBased();
      note.tl.scaleTo(1, 1, 0);
      note.tl.moveY(note.destinationY, (note.timing - _game.music.currentTime - 0.02) * 1000);
      note.hasClearAnimationStarted = false;
      _group.addChild(note);
      return note.addEventListener("enterframe", _schedule);
    };

    _schedule = function() {
      var diffTime, judgement, music;
      music = _game.music;
      this.tl.moveY(this.destinationY, (this.timing - _game.music.currentTime - 0.02) * 1000);
      if (this.oldtime != null) {
        this.rotate((music.currentTime - this.oldtime) * 500);
      }
      this.oldtime = music.currentTime;
      if (_timing[this.number] - music.currentTime < -0.3) {
        this.tl.clear();
        this.tl.fadeOut(300).then(function() {
          return _group.removeChild(this);
        });
      }
      if (this.clear && !this.hasClearAnimationStarted) {
        this.tl.clear();
        this.tl.scaleTo(1.5, 1.5, 200).and().fadeOut(200).then(function() {
          return _group.removeChild(this);
        });
        diffTime = _timing[this.number] - this.clearTime;
        judgement = _judge(diffTime);
        return this.hasClearAnimationStarted = true;
      }
    };

    _judge = function(diffTime) {
      var judge, judgeLabel;
      if ((-_threshold.great < diffTime && diffTime < _threshold.great)) {
        judge = "Great";
      } else if ((-_threshold.good < diffTime && diffTime < _threshold.good)) {
        judge = "Good";
      } else {
        judge = "Bad";
      }
      judgeLabel = new Label(judge);
      judgeLabel.x = JUDGE_LABEL_X;
      judgeLabel.y = JUDGE_LABEL_Y;
      judgeLabel.font = "32px Arial";
      _game.rootScene.addChild(judgeLabel);
      judgeLabel.tl.setTimeBased();
      judgeLabel.tl.fadeOut(300).and().moveY(240, 400).then(function() {
        return _game.rootScene.removeChild(judgeLabel);
      });
      return _cb(judge);
    };

    return Note;

  })();

  Score = (function() {
    var _display, _group, _real;

    _group = null;

    _real = 0;

    _display = 0;

    function Score(parms) {
      var name, value;
      for (name in parms) {
        value = parms[name];
        this[name] = value;
      }
    }

    Score.prototype.init = function() {
      var i, score;
      i = 0;
      _group = new Group();
      while (i < this.num) {
        score = new Sprite(this.width, this.height);
        score.image = this.game.assets[this.url];
        score.frame = i;
        score.x = this.offsetX + score.width * i;
        score.y = this.offsetY;
        _group.addChild(score);
        i++;
      }
      this.game.rootScene.addChild(_group);
      return this.update(0);
    };

    Score.prototype.update = function(score) {
      var base, value, _i, _len, _ref, _results;
      base = Math.pow(10, this.num - 1);
      _ref = _group.childNodes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        value = _ref[_i];
        value.frame = ~~(score / base);
        score = score % base;
        _results.push(base = base / 10);
      }
      return _results;
    };

    return Score;

  })();

  GameSys = (function() {
    function GameSys() {}

    GameSys.getSprite = function(pool) {
      var i, value, _i, _len;
      for (i = _i = 0, _len = pool.length; _i < _len; i = ++_i) {
        value = pool[i];
        if (!value.active) {
          value.active = true;
          return value;
        }
      }
      console.log("error sprite pool empty");
      return false;
    };

    GameSys.poolSprite = function(pool, sprite) {
      pool.push(sprite);
      sprite.active = false;
      if (sprite.addEventListener) {
        return sprite.addEventListener("removed", function() {
          this.clearEventListener("enterframe");
          return this.active = false;
        });
      }
    };

    return GameSys;

  })();

}).call(this);
