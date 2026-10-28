        -- 25. MESSAGING > VIBER (SUPER+M, V)
        hl.define_submap("messaging-viber", "reset", function()
          hl.bind("D", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel viber && xdg-open $HOME/Documents/ViberDownloads"), { description = "Open Viber downloads" })
          hl.bind("escape", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel viber && hyprctl dispatch \"hl.dsp.submap('reset')\""), { description = "Exit viber mode" })
        end)
        -- 26. MESSAGING > WHATSAPP (SUPER+M, W)
        hl.define_submap("messaging-whatsapp", "reset", function()
          hl.bind("D", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel whatsapp && xdg-open $HOME/Downloads"), { description = "Open WhatsApp downloads" })
          hl.bind("escape", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel whatsapp && hyprctl dispatch \"hl.dsp.submap('reset')\""), { description = "Exit whatsapp mode" })
        end)

        -- 27. WINDOWS (SUPER+W)
        hl.define_submap("windows", "reset", function()
          -- Toggle between scrolling and monocle layouts, flashing the Keymap bar
          -- so the switch is visible. Monocle tiles windows edge to edge, so its
          -- gaps are disabled (restored to 8/16 when leaving it).
          local toggLay = { "scrolling", "monocle" }
          local function applyGaps(gapsIn, gapsOut)
            hl.config({ general = { ["gaps_in"] = gapsIn, ["gaps_out"] = gapsOut } })
          end
          local function toggleLayout()
            local ws = hl.get_active_workspace()
            local cur = (ws and ws.tiled_layout) or toggLay[1]
            local nextName = cur ~= toggLay[1] and toggLay[1] or toggLay[2]
            hl.config({ general = { layout = nextName } })
            if nextName == "monocle" then
              applyGaps(0, 0)
            else
              applyGaps(8, 16)
            end
            hl.dispatch(hl.dsp.exec_cmd("noctalia msg bar-show Keymap"))
            hl.timer(function()
              hl.dispatch(hl.dsp.exec_cmd("noctalia msg bar-hide Keymap"))
            end, { timeout = 2000, type = "oneshot" })
          end
          hl.bind("F", hl.dsp.window.fullscreen(), { description = "Toggle fullscreen" })
          hl.bind("ALT + F", function()
            hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
            remToggle("float")
          end, { description = "Toggle floating (remembered)" })
          hl.bind("T", function()
            local nextMode = not transReadMode()
            transSet(nextMode)
            hl.dispatch(hl.dsp.exec_cmd("noctalia msg bar-show Keymap"))
            hl.timer(function()
              hl.dispatch(hl.dsp.exec_cmd("noctalia msg bar-hide Keymap"))
            end, { timeout = 2000, type = "oneshot" })
          end, { description = "Toggle all-window transparency" })
          hl.bind("M", toggleLayout, { description = "Toggle tiling layout (mode W)" })
          hl.bind("C", hl.dsp.window.close(), { description = "Close window (mode W)" })
          hl.bind("P", function()
            hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
            hl.dispatch(hl.dsp.window.pin())
            remToggle("float")
          end, { description = "Pin to all workspaces (floating)" })
          hl.bind("ALT + P", function()
            hl.dispatch(hl.dsp.window.pseudo())
            remToggle("pseudo")
          end, { description = "Toggle pseudo (remembered)" })
          hl.bind("S", hl.dsp.workspace.toggle_special("scratchpad"), { description = "Toggle scratchpad" })
          hl.bind("SHIFT + S", hl.dsp.window.move({ workspace = "special:scratchpad" }), { description = "Move to scratchpad" })
          hl.bind("V", hl.dsp.exec_cmd(scripts .. "/session-save.sh"), { description = "Save session" })
          hl.bind("SHIFT + V", hl.dsp.exec_cmd(scripts .. "/session-restore.sh"), { description = "Restore session (mode W)" })
          hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit windows mode" })
        end)
  