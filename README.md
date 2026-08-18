# Switcher-Room-Combiner

Switcher Room Combiner lua plugin for the QSC Q-SYS platform. v0.98

This plugin mimics the room combiner component build into Q-SYS designer except that instead of mixing audio (combining audio sources) it combines (syncronises) switchers. In addition to this it features Input Restriction mode that allows each room to only have access to a user definable number of switcher inputs. When rooms are combined, their own allowed inputs are added to the group's allowed inputs, and each room is able to access the inputs of the other. When the rooms are separated again they will revert back to the lowest numbered allowed input in their list.

## Features

* Restrict inputs per room with 3 different modes (Restrict mode, Allow mode, Bypass). Combined rooms will also combine all allowed inputs from each room.
* Choose your own LED colours! If you use the room combiner component but want to use your own colours for the LEDs to match your palette, add them as a comma seperated string under properties.  Accepts any standard colour metadata strings in the form of "#RGB", "#RRGGBB", CSS Color Names, and HSV values using the format "!HHSSVV". EG `Black,White,#FFFFFF` - No spaces or quotes.
* New property - "Allow toggle off: Yes/No".  This allows a switcher input that is currently on to be toggled off.  This will also allow you to use the plugin with one input as a toggle-room-combiner, therefore syncronising toggle states across rooms.

## Known limits

* The room combine algorithm can hit the execution limit when numbers of rooms, walls or room/wall associations gets too large.

## To dos

* Break out each section to a seperate file as per Q-sys standard plugin
* Add debug info as per Q-Sys standard plugin
* Optimise findRoomGroups() function to allow more rooms to work without hitting execution limit.
* Algorithmically generate a unique set of colours for the room LEDs.
* New control - "Uncombine action" - will allow a default input to be set, or returning to previous value upon a room uncombining.
* Add an Auto Switch feature per room.
* Should switchdelay be a user editable field? (yes). Probably also per room.
