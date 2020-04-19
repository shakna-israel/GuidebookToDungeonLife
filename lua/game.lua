local js = require "js"
local window = js.global
local document = window.document

local function sleep(delay)
    local co = assert(coroutine.running(), "Should be run in a coroutine")

    window:setTimeout(function()
        assert(coroutine.resume(co))
    end, delay*1000)

    coroutine.yield()
end

local Object
Object = function(t)
  local o = js.new(js.global.Object)
  for k, v in pairs(t) do
    assert(type(k) == "string" or js.typeof(k) == "symbol", "JavaScript only has string and symbol keys")
    o[k] = v
  end
  return o
end

local load_game = function()
  local r = {}
  
  local x = window.localStorage:getItem("game")
  if x ~= js.null then
    local o = window.JSON:parse(x)
    if o then

      for k, v in pairs(o) do
        r[k] = v
      end

    end

  end

  return r
end

local save_game = function(state)
  local s = window.JSON:stringify(Object(state))
  window.localStorage:setItem("game", s)
  print("Saved!")
end

local generate_world

local tick
tick = function(state)

  if not state.world then
    state = generate_world(state)
  end

  -- TODO: print descriptions of location

  -- TODO: print action options

  window:setTimeout(function()
    state = tick(state)
  end, 1000)

  -- Save the state
  save_game(state)

  return state
end

local generate_room = function()
  local r = {}

  r['name'] = '?' -- TODO: Randomise

  r['present'] = {} -- TODO: Random 1-2 NPCs (npcs can give factoids)

  r['market'] = {} -- TODO: Low chance of market stall owner

  r['description'] = '?' -- TODO: Randomise

  r['locations'] = {}

  return r
end

generate_world = function(state)
  -- generate world rooms
  state.world = {}

  state.world[1] = generate_room()
  state.world[1].name = 'Reception'
  state.world[1].description = 'A somewhat rough looking room, filled with rougher looking people uninterested in talking to you.'
  state.world[1].present[#state.world[1].present + 1] = 'Mr. Receptionist'
  state.world[1].locations[#state.world[1].locations + 1] = 2

  for i=2, 100 do
    -- Generate a single room
    state.world[i] = generate_room()
    -- Link it to the previous room
    state.world[i].locations[#state.world[i].locations + 1] = i-1

    -- Generate adjoining rooms
    for i2=1, 10 do
      state.world[i*2 + i2] = generate_room()
      state.world[i].locations[#state.world[i].locations + 1] = i*2 + i2
    end

  end

  return state
end

local new_player = function(state)
  local el = document:getElementById("gamecontent")
  el.textContent = ''
  el:scrollIntoView()

  coroutine.wrap(function()
    local x = document:createElement("p")
    x.textContent = 'Write your name here:'
    x.classList:add("highlight")
    el:appendChild(x)
    x:scrollIntoView()
    sleep(2)

    local x = document:createElement("input")
    x.classList:add("highlight")

    if state.idiot and state.idiot > 0 then
      x.value = "X"
    end

    if state.etiquette and state.etiquette > 0 then
      x.value = "Lord Valance Ostentatious VII"
    end

    if state.drunk and state.drunk > 0 then
      x.value = "I̴͕̔̂̓̀̓̌͐̋͆̆͒̚̚͠A̵͙̩̍́̏͘m̴͉͉̦̹̲̰̬̭̹̼͔̫͚͍̘̎͋̆̈́̕D̷̢͇̫͉̫̗̤͓̦̮̝̣̟͉̍͛́̆͂͜͝͝r̷̻̪̻͆̅̿̏̂̀̓͊̿̍̚͘ù̶͖͕̤̰͔̤̦̩͙̬́̋͌̌̌̌͆ǹ̷̡̰̞͍̩̩͇̙̉̆̚k̵̡̜̳̪͉̳͖͙̞̝̳̟͉͖̎̿̐̋̋͛̓͛͜"
    end

    el:appendChild(x)
    x:scrollIntoView()
    sleep(2)

    local x = document:createElement("button")
    x.textContent = 'Confirm'
    x.classList:add("highlight")

    x:addEventListener("click", function()
      -- TODO: state.world doesn't seem to be saved by Object(t)
      state = generate_world(state)
      state.intro_complete = true
      -- TODO: Get user name and store it
      tick(state)
    end)
    el:appendChild(x)
    x:scrollIntoView()
    sleep(2)
  end)()
end

local intro = function(state)
  local el = document:getElementById("gamecontent")

  local intro_sentences = {"A new adventurer seeks to claim victory.",
  "That's the dream of every adventurer. To conquer the dungeon.",
  "Oh, they're dead.",
  "That's just how the world is, really.",
  "New adventurers! Step on up!",
  "Wait...",
  "What exactly are you?",
  "You don't look like an adventurer.",
  "What's with the scrapbook?",
  "Reading is just going to get you killed."}

  state.relationships = {}

  coroutine.wrap(function()
    for _, v in ipairs(intro_sentences) do
      local x = document:createElement("p")
      x.textContent = v
      x.classList:add("highlight")
      el:appendChild(x)
      x:scrollIntoView()
      sleep(2)
    end

    state.relationships['Mr. Receptionist'] = 0

    local choices = { {"I'm a researcher, my good sir.",
      function()
        coroutine.wrap(function()
          local el = document:getElementById("gamecontent")
          el.textContent = ''
          el:scrollIntoView()

          local x = document:createElement("p")
          x.textContent = 'A... Researcher... Never heard of it.'
          x.classList:add("highlight")
          el:appendChild(x)
          x:scrollIntoView()
          sleep(2)
          local x = document:createElement("p")
          x.textContent = 'Not a warrior class, any way. How about you not waste my time?'
          x.classList:add("highlight")
          el:appendChild(x)
          x:scrollIntoView()
          sleep(2)

          state.relationships['Mr. Receptionist'] = state.relationships['Mr. Receptionist'] - 1

          if state.etiquette then
            state.etiquette = state.etiquette + 1
          else
            state.etiquette = 1
          end

          x = document:createElement("p")
          x.textContent = '1) I want to sign up.'
          x.classList:add("highlight")
          x.classList:add("choice")
          x:addEventListener("click", function() new_player(state) end)
          el:appendChild(x)
          x:scrollIntoView()
          sleep(2)

        end)()
      end },
    {"The pen is mightier than the sword!",
      function()
        local el = document:getElementById("gamecontent")
        el.textContent = ''
        el:scrollIntoView()

        local x = document:createElement("p")
        x.textContent = 'You been sniffing cactus weed, son?'
        x.classList:add("highlight")
        el:appendChild(x)
        x:scrollIntoView()
        sleep(2)
        local x = document:createElement("p")
        x.textContent = "If you aren't here to fight, move along."
        x.classList:add("highlight")
        el:appendChild(x)
        x:scrollIntoView()
        sleep(2)

        state.relationships['Mr. Receptionist'] = state.relationships['Mr. Receptionist'] - 2
        
        if state.nerd then
          state.nerd = state.nerd + 1
        else
          state.nerd = 1
        end
        
        x = document:createElement("p")
        x.textContent = "1) I've got a fight for you. Right here."
        x.classList:add("highlight")
        x.classList:add("choice")
        x:addEventListener("click", function() new_player(state) end)
        el:appendChild(x)
        x:scrollIntoView()
        sleep(2)

      end },
    {"Uh...",
      function()
        local el = document:getElementById("gamecontent")
        el.textContent = ''
        el:scrollIntoView()

        local x = document:createElement("p")
        x.textContent = "Oh."
        x.classList:add("highlight")
        el:appendChild(x)
        x:scrollIntoView()
        sleep(2)
        local x = document:createElement("p")
        x.textContent = "You're kinda special, aren't you?"
        x.classList:add("highlight")
        el:appendChild(x)
        x:scrollIntoView()
        sleep(2)

        state.relationships['Mr. Receptionist'] = 0

        if state.idiot then
          state.idiot = state.idiot + 1
        else
          state.idiot = 1
        end

        x = document:createElement("p")
        x.textContent = '1) I want to sign up.'
        x.classList:add("highlight")
        x.classList:add("choice")
        x:addEventListener("click", function() new_player(state) end)
        el:appendChild(x)
        x:scrollIntoView()
        sleep(2)

      end},
    {"Where am I?",
      function()
        local el = document:getElementById("gamecontent")
        el.textContent = ''
        el:scrollIntoView()

        local x = document:createElement("p")
        x.textContent = "The library."
        x.classList:add("highlight")
        el:appendChild(x)
        x:scrollIntoView()
        sleep(2)
        local x = document:createElement("p")
        x.textContent = "Where the gorram hell do you think you are?"
        x.classList:add("highlight")
        el:appendChild(x)
        x:scrollIntoView()
        sleep(2)

        state.relationships['Mr. Receptionist'] = state.relationships['Mr. Receptionist'] - 2
        
        x = document:createElement("p")
        x.textContent = '1) If this is a gorram library, give me a gorram library card!'
        x.classList:add("highlight")
        x.classList:add("choice")
        x:addEventListener("click", function() new_player(state) end)
        el:appendChild(x)
        x:scrollIntoView()
        sleep(2)

      end},
    {"Dude, I have the biggest hangover. What are you on about?",
      function()
        local el = document:getElementById("gamecontent")
        el.textContent = ''
        el:scrollIntoView()

        local x = document:createElement("p")
        x.textContent = "Not again."
        x.classList:add("highlight")
        el:appendChild(x)
        x:scrollIntoView()
        sleep(2)
        local x = document:createElement("p")
        x.textContent = "Just... Get out of here. Please."
        x.classList:add("highlight")
        el:appendChild(x)
        x:scrollIntoView()
        sleep(2)

        state.relationships['Mr. Receptionist'] = 0

        if state.drunk then
          state.drunk = state.drunk + 1
        else
          state.drunk = 1
        end
        
        x = document:createElement("p")
        x.textContent = "1) Don't tell me what to do!"
        x.classList:add("highlight")
        x.classList:add("choice")
        x:addEventListener("click", function() new_player(state) end)
        el:appendChild(x)
        x:scrollIntoView()
        sleep(2)

      end}
    }

    for idx, v in ipairs(choices) do
      local x = document:createElement("p")
      x.textContent = string.format("%d) %s", idx, v[1])
      x.classList:add("highlight")
      x.classList:add("choice")
      x:addEventListener("click", 
        function()
          coroutine.wrap(function()
            v[2]()
          end)()
        end)
      el:appendChild(x)
      x:scrollIntoView()
    end
    sleep(2)

  end)()

  return state
end

local main = function()
  local el = document:getElementById("logout")
  el:addEventListener("click", function()
    if window:confirm("DESTROY YOUR SAVEFILE??") then
      tick = function() end
      window.localStorage:clear()
      window.location:reload()
    end
  end)

  local el = document:getElementById("gamecontent")
  el.textContent = ''

  local state = load_game()

  if state.intro_complete ~= true then
    state = intro(state)
  else
    tick(state)
  end

end

main()
