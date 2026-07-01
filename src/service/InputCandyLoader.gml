///@package com.la-game-studio.input-candy.service
show_debug_message("init InputCandyLoader.gml")


///@type {String}
#macro BeanInputCandyLoader "InputCandyLoader"

///@param {?Struct} [config]
function InputCandyLoader(config = null): Service(config) constructor {

  ///@type {Boolean}
  initialized = false

  ///@type {Boolean}
  sdlbInitialized = false

  ///@type {Boolean}
  enabled = true

  ///@type {EventPump}
  eventPump = new EventPump(this, new Map(String, Callable, {
    "init": function(event) {
      var loader = this
      var task = new Task("load-input-candy")
        .setTimeout(10.0)
        .setState({
          loaded: false,
          processed: false,
          loader: loader,
        })
        .whenUpdate(function(executor) {
          if (!this.state.loaded) {
            this.state.loaded = SDLDB_Load_Step()
            if (this.state.loaded) {
              var size = __INPUTCANDY.SDLDB_Read_Bytes
              Logger.info(BeanInputCandyLoader, $"SDLDB loaded: {size}")
              SDLDB_Process_Start()
            }
          }

          if (this.state.loaded && !this.state.processed) {
            this.state.processed = SDLDB_Process_Step()
            if (this.state.processed) {
              var size = array_length(global.SDLDB)
              Logger.info(BeanInputCandyLoader, $"SDLDB processed: {size}")
              this.state.loader.initialized = true
              this.fullfill()
            }
          }
        })

      Init_InputCandy_Advanced(event.data)
      if (!this.sdlbInitialized) {
        SDLDB_Load_Start()
        this.sdlbInitialized = true
      }

      this.executor.add(task)
      this.initialized = false
    }
  }), {
    enableLogger: Struct.getIfType(Struct.get(config, "eventPump"), "enableLogger", Boolean, false),
    loggerPrefix: Struct.getIfType(Struct.get(config, "eventPump"), "loggerPrefix", String, BeanInputCandyLoader),
    catchException: Struct.getIfType(Struct.get(config, "eventPump"), "catchException", Boolean, false),
    exceptionCallback: Struct.getIfType(Struct.get(config, "eventPump"), "exceptionCallback", Callable),
    freeStrategy: Struct.getIfEnum(Struct.get(config, "eventPump"), "freeStrategy", EventPumpFreeStrategyType, EventPumpFreeStrategyType.NONE),
  })

  ///@type {TaskExector}
  executor = new TaskExecutor(this, {
    enableLogger: Struct.getIfType(Struct.get(config, "executor"), "enableLogger", Boolean, false),
    loggerPrefix: Struct.getIfType(Struct.get(config, "executor"), "loggerPrefix", String, BeanInputCandyLoader),
    catchException: Struct.getIfType(Struct.get(config, "executor"), "catchException", Boolean, false),
    exceptionCallback: Struct.getIfType(Struct.get(config, "executor"), "exceptionCallback", Callable),
    freeStrategy: Struct.getIfEnum(Struct.get(config, "executor"), "freeStrategy", TaskExecutorFreeStrategyType, TaskExecutorFreeStrategyType.NONE),
  })

  ///@return {Boolean}
  isGamepadConnected = function() {
    return this.initialized
        && this.sdlbInitialized
        && array_length(__INPUTCANDY.devices) != 0
  }

  ///@return {Boolean}
  anykey = function() {
    var result = false
    var gamepads = gamepad_get_device_count()
    for (var index = 0; index < gamepads; index++) {
      if (gamepad_is_connected(index)) {
        for (var idx = gp_face1; idx < gp_axisrv; idx++) {
          result = gamepad_button_check(index, idx)
          if (result) {
            break
          }
        }

        if (!result) {
          result = abs(gamepad_axis_value(index, gp_axislh)) > 0.3
            || abs(gamepad_axis_value(index, gp_axislv)) > 0.3
          
          if (result) {
            break
          }
        }
      }

      if (result) {
        break
      }
    }

    return result
  }

  ///@param {Event} event
  ///@return {?Promise}
  send = function(event) {
    return this.eventPump.send(event)
  }

  ///@return {InputCandyLoader}
  updateIC = function() {
    if (this.initialized && this.enabled) {
      __IC.Step()
    }

    return this
  }
	
	///@return {InputCandyLoader}
	update = function() {
    this.eventPump.update()
    this.executor.update()
    this.updateIC()
		return this
	}

  free = function() {
    this.executor.free()
  }
}
