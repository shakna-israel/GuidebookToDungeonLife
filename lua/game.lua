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
    el:appendChild(x)
    x:scrollIntoView()
    sleep(2)

    local x = document:createElement("button")
    x.textContent = 'Confirm'
    x.classList:add("highlight")
    -- TODO: link to save button
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

local load_game = function()
  local r = {}
  -- TODO: localStorage
  return r
end

local save_game = function(state)
  -- TODO: localStorage
end

local main = function()
  local state = load_game()

  if state.intro_complete ~= "true" then
    state = intro(state)
  end

  save_game(state)
end

main()