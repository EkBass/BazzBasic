' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Text-adventure game engine working with JSON
' CATEGORY: games
' TAGS: turn-based, adventure, game, json
' MINVERSION: 1.5
' License: MIT
' ============================================

' Here is a lots of comments. But blame me for that.
' This is also excellent tutorial how to build a textgame engine
' and use it for JSON adventure.

' So I asked Claude AI with 'bazzbasic-code' skill to analyze it and
' comment it as its a tutorial.
' It sometimes performs like 150%

' Original C++ game: Michael Denathorn (Dabzy)
' https://www.syntaxboom.net/forum/c-c/code-archives/1964-text-adventure


' HOW IT IS BUILT
'   This file is only the engine. Rooms, items, characters, dialogue,
'   the quest and all story text come from world.json, so the adventure
'   can be changed - or replaced with a new one - without touching code.
'
'   world$   The JSON file exactly as loaded, treated as READ ONLY.
'            Nested JSON becomes comma paths:  world$("items,sword,dmg")
'
'   State    Everything that changes during play lives in its own arrays,
'            keyed by id:  itemLoc$("sword"), chrHp$("dragon") ...
'            An item's location is ONE field: a room id, "player" (in the
'            inventory), "gone" (used up) or "none" (not in the world yet).
'            Taking, dropping and using an item only changes that field.
'
'   Ids      JSON names for rooms, items and characters must be lowercase
'            and contain no commas or spaces. Commas would break the key
'            paths, and player input is lowercased before it is used as a
'            key - array keys are case-sensitive.
'
' FIXES COMPARED TO THE ORIGINAL
'   1. The Crown of Light lay in the dragon's lair, where combat starts on
'      entry and the game ends when the dragon dies, so it could never be
'      taken. Now the skeleton carries it, and the crown's light is needed
'      to enter the lair.
'   2. Objectives were completed by one-shot events, so finding an artifact
'      before meeting the wizard lost that progress for good. Objectives
'      are now checked against the game state every time.
'   3. The Blessed Sword could not be equipped: setArtifact() overwrote its
'      "weapon" type. Here "artifact" is a separate flag.
'   4. The key and the locked-exit code were never used. The cave gate is
'      now locked, and exit locks are defined in world.json.
'   5. When one enemy died, the next hostile in the same room waited
'      quietly. It now attacks at once.
'   6. The dragon (100 HP, attack 25) was close to unbeatable. The Grimoire
'      and the Crown now ward off damage while carried.
'   7. "flee" ran to the alphabetically first exit; it now runs back the way
'      you came. Peaceful characters can no longer be attacked.
'
' No DEF FN functions here on purpose: a DEF FN cannot see global arrays,
' and almost every routine reads or changes the world state. GOSUB
' subroutines share the main scope, which is exactly what is needed.

[inits]
    LET WORLD_FILE# = PRG_ROOT# + "world.json"
    LET RULE#       = REPEAT("=", 40)

    ' The world as loaded (read only) and SPLIT work arrays
    DIM world$
    DIM part$                     ' pieces of one key path
    DIM raw$                      ' pieces of one input line
    DIM tok$                      ' input words, empty pieces removed

    ' Indexes built from world$ by [sub:buildIndex]
    DIM seen$                     ' seen$("item|book") = TRUE, de-duplicates ids
    DIM itemIds$, chrIds$         ' ids in file order, 0-based
    DIM exitDir$                  ' exitDir$("forest|0") = "south"
    DIM exitCount$                ' exitCount$("forest") = 3
    LET itemCount$ = 0, chrCount$ = 0

    ' Item fields and state, keyed by item id
    DIM itemLoc$, itemTake$, itemType$, itemDmg$, itemHeal$, itemArmor$, itemArtifact$
    DIM obtained$                 ' TRUE once the player has ever held the item

    ' Character fields and state, keyed by character id
    DIM chrLoc$, chrHostile$, chrHp$, chrAtk$, chrAlive$
    DIM chrState$, chrDlgIdx$, chrDrops$, chrEndsGame$, chrGivesQuest$, chrNewState$
    DIM talked$                   ' TRUE after the first conversation

    ' Exit locks that have been opened: unlocked$("forest|west") = TRUE
    DIM unlocked$

    ' Quest
    DIM objDone$
    LET objCount$ = 0
    LET questActive$ = FALSE, questDone$ = FALSE

    ' Player
    LET curRoom$ = "", prevRoom$ = ""
    LET hp$ = 0, maxHp$ = 0, baseAtk$ = 0
    LET equipped$ = ""
    LET totalArtifacts$ = 0, allArtifactsShown$ = FALSE

    ' Game loop
    LET running$ = TRUE, inCombat$ = FALSE, foe$ = ""

    ' Input
    LET inputLine$ = "", cmd$ = "", arg$ = "", tokCount$ = 0, pieceCount$ = 0

    ' Working variables. GOSUB shares one scope, so each subroutine uses
    ' its own names for loop counters and results to avoid clobbering.
    LET path$ = "", id$ = "", partCount$ = 0, fBase$ = ""
    LET linesKey$ = "", lnI$ = 0, n$ = 0
    LET where$ = "", chrWhere$ = "", text$ = ""
    LET dir$ = "", target$ = "", lockPath$ = "", lockKey$ = "", lockItem$ = ""
    LET canMove$ = FALSE
    LET dmg$ = 0, atkPower$ = 0, defense$ = 0
    LET artCount$ = 0, heldCount$ = 0, lineCount$ = 0, doneCount$ = 0
    LET objType$ = "", allOk$ = FALSE, qt$ = 0, targetName$ = ""

[init:world]
    IF FILEEXISTS(WORLD_FILE#) = FALSE THEN
        PRINT "World file not found: "; WORLD_FILE#
        END
    END IF
    LOADJSON world$, WORLD_FILE#
    GOSUB [sub:buildIndex]
    GOSUB [sub:initState]

[main]
    GOSUB [sub:showIntro]
    GOSUB [sub:showRoom]

    WHILE running$
        IF inCombat$ THEN
            GOSUB [sub:combatRound]
        ELSE
            PRINT ""
            LINE INPUT "> ", inputLine$
            GOSUB [sub:tokenize]
            IF tokCount$ > 0 THEN GOSUB [sub:processCommand]
        END IF
    WEND
END

' ============================================
' LOADING
' ============================================

[sub:buildIndex]
    ' Walks every key path of the loaded JSON once and collects the item
    ' and character ids (in file order) and each room's exit directions.
    ' A path looks like "items,book,desc" or "rooms,forest,exits,west".
    FOR ix$ = 0 TO LEN(world$()) - 1
        path$ = ARRKEY(world$(), ix$)
        partCount$ = SPLIT(part$, path$, ",")
        IF partCount$ >= 3 THEN
            id$ = part$(1)
            IF part$(0) = "rooms" THEN
                IF HASKEY(seen$("room|" + id$)) = FALSE THEN
                    seen$("room|" + id$) = TRUE
                    exitCount$(id$) = 0
                END IF
                IF partCount$ = 4 AND part$(2) = "exits" THEN
                    exitDir$(id$ + "|" + exitCount$(id$)) = part$(3)
                    exitCount$(id$) = exitCount$(id$) + 1
                END IF
            ELSEIF part$(0) = "items" THEN
                IF HASKEY(seen$("item|" + id$)) = FALSE THEN
                    seen$("item|" + id$) = TRUE
                    itemIds$(itemCount$) = id$
                    itemCount$ += 1
                END IF
            ELSEIF part$(0) = "characters" THEN
                IF HASKEY(seen$("chr|" + id$)) = FALSE THEN
                    seen$("chr|" + id$) = TRUE
                    chrIds$(chrCount$) = id$
                    chrCount$ += 1
                END IF
            END IF
        END IF
    NEXT
RETURN

[sub:initState]
    ' Copies the starting values out of world$ into the state arrays.
    ' Optional JSON fields get their default first and are overwritten
    ' only when the file actually has them.
    curRoom$ = world$("start")
    IF HASKEY(exitCount$(curRoom$)) = FALSE THEN
        PRINT "world.json: start room '"; curRoom$; "' does not exist."
        END
    END IF
    hp$      = world$("player,hp")
    maxHp$   = hp$
    baseAtk$ = world$("player,attack")

    FOR is$ = 0 TO itemCount$ - 1
        id$ = itemIds$(is$)
        fBase$ = "items," + id$ + ","

        itemLoc$(id$) = "none"
        IF HASKEY(world$(fBase$ + "loc")) THEN itemLoc$(id$) = world$(fBase$ + "loc")
        itemTake$(id$) = TRUE
        IF HASKEY(world$(fBase$ + "take")) THEN itemTake$(id$) = world$(fBase$ + "take")
        itemType$(id$) = "regular"
        IF HASKEY(world$(fBase$ + "type")) THEN itemType$(id$) = world$(fBase$ + "type")
        itemDmg$(id$) = 0
        IF HASKEY(world$(fBase$ + "dmg")) THEN itemDmg$(id$) = world$(fBase$ + "dmg")
        itemHeal$(id$) = 0
        IF HASKEY(world$(fBase$ + "heal")) THEN itemHeal$(id$) = world$(fBase$ + "heal")
        itemArmor$(id$) = 0
        IF HASKEY(world$(fBase$ + "armor")) THEN itemArmor$(id$) = world$(fBase$ + "armor")
        itemArtifact$(id$) = FALSE
        IF HASKEY(world$(fBase$ + "artifact")) THEN itemArtifact$(id$) = world$(fBase$ + "artifact")

        obtained$(id$) = FALSE
        IF itemLoc$(id$) = "player" THEN obtained$(id$) = TRUE
        IF itemArtifact$(id$) = TRUE THEN totalArtifacts$ += 1
    NEXT

    FOR ic$ = 0 TO chrCount$ - 1
        id$ = chrIds$(ic$)
        fBase$ = "characters," + id$ + ","

        chrLoc$(id$) = "none"
        IF HASKEY(world$(fBase$ + "loc")) THEN chrLoc$(id$) = world$(fBase$ + "loc")
        chrHostile$(id$) = FALSE
        IF HASKEY(world$(fBase$ + "hostile")) THEN chrHostile$(id$) = world$(fBase$ + "hostile")
        chrHp$(id$) = 50
        IF HASKEY(world$(fBase$ + "hp")) THEN chrHp$(id$) = world$(fBase$ + "hp")
        chrAtk$(id$) = 5
        IF HASKEY(world$(fBase$ + "attack")) THEN chrAtk$(id$) = world$(fBase$ + "attack")
        chrDrops$(id$) = ""
        IF HASKEY(world$(fBase$ + "drops")) THEN chrDrops$(id$) = world$(fBase$ + "drops")
        chrEndsGame$(id$) = FALSE
        IF HASKEY(world$(fBase$ + "endsGame")) THEN chrEndsGame$(id$) = world$(fBase$ + "endsGame")
        chrGivesQuest$(id$) = FALSE
        IF HASKEY(world$(fBase$ + "givesQuest")) THEN chrGivesQuest$(id$) = world$(fBase$ + "givesQuest")
        chrNewState$(id$) = ""
        IF HASKEY(world$(fBase$ + "newState")) THEN chrNewState$(id$) = world$(fBase$ + "newState")

        chrAlive$(id$)  = TRUE
        chrState$(id$)  = "initial"
        chrDlgIdx$(id$) = 0
        talked$(id$)    = FALSE
    NEXT

    ' Objectives are a JSON list: count them by probing index 0, 1, 2 ...
    WHILE HASKEY(world$("quest,objectives," + objCount$ + ",text"))
        objDone$(objCount$) = FALSE
        objCount$ += 1
    WEND
RETURN

' ============================================
' INPUT
' ============================================

[sub:tokenize]
    ' Lowercases the input line and splits it on spaces. Several spaces in
    ' a row give empty pieces, so those are skipped.
    ' out: tok$(0..tokCount$-1), cmd$ = first word, arg$ = second word
    tokCount$ = 0
    cmd$ = ""
    arg$ = ""
    pieceCount$ = SPLIT(raw$, LCASE(TRIM(inputLine$)), " ")
    IF pieceCount$ > 0 THEN
        FOR tk$ = 0 TO pieceCount$ - 1
            IF raw$(tk$) <> "" THEN
                tok$(tokCount$) = raw$(tk$)
                tokCount$ += 1
            END IF
        NEXT
    END IF
    IF tokCount$ > 0 THEN cmd$ = tok$(0)
    IF tokCount$ > 1 THEN arg$ = tok$(1)
RETURN

[sub:processCommand]
    IF cmd$ = "quit" OR cmd$ = "exit" THEN
        running$ = FALSE
        PRINT "Thanks for playing!"
    ELSEIF cmd$ = "look" OR cmd$ = "l" THEN
        GOSUB [sub:showRoom]
    ELSEIF cmd$ = "inventory" OR cmd$ = "i" THEN
        GOSUB [cmd:inventory]
    ELSEIF cmd$ = "stats" THEN
        GOSUB [cmd:stats]
    ELSEIF cmd$ = "quest" OR cmd$ = "quests" THEN
        GOSUB [cmd:quest]
    ELSEIF cmd$ = "go" THEN
        GOSUB [cmd:go]
    ELSEIF cmd$ = "take" THEN
        GOSUB [cmd:take]
    ELSEIF cmd$ = "drop" THEN
        GOSUB [cmd:drop]
    ELSEIF cmd$ = "examine" THEN
        GOSUB [cmd:examine]
    ELSEIF cmd$ = "use" THEN
        GOSUB [cmd:use]
    ELSEIF cmd$ = "equip" THEN
        GOSUB [cmd:equip]
    ELSEIF cmd$ = "attack" THEN
        GOSUB [cmd:attack]
    ELSEIF cmd$ = "talk" THEN
        GOSUB [cmd:talk]
    ELSEIF cmd$ = "help" THEN
        GOSUB [cmd:help]
    ELSE
        PRINT "I don't understand that command. Type 'help' for options."
    END IF
RETURN

' ============================================
' COMMANDS
' ============================================

[cmd:go]
    IF arg$ = "" THEN
        PRINT "Go where?"
    ELSEIF HASKEY(world$("rooms," + curRoom$ + ",exits," + arg$)) = FALSE THEN
        PRINT "You can't go that way."
    ELSE
        dir$ = arg$
        GOSUB [sub:tryMove]
    END IF
RETURN

[cmd:take]
    GOSUB [sub:locateItem]
    IF arg$ = "" THEN
        PRINT "Take what?"
    ELSEIF where$ <> curRoom$ THEN
        PRINT "There's no "; arg$; " here."
    ELSEIF itemTake$(arg$) = FALSE THEN
        PRINT "You can't take that."
    ELSE
        itemLoc$(arg$) = "player"
        PRINT "You take the "; arg$; "."
        IF obtained$(arg$) = FALSE THEN
            obtained$(arg$) = TRUE
            linesKey$ = "items," + arg$ + ",onTake"
            GOSUB [sub:printLines]
        END IF
        IF itemArtifact$(arg$) = TRUE AND allArtifactsShown$ = FALSE THEN
            GOSUB [sub:countArtifacts]
            IF artCount$ = totalArtifacts$ THEN
                allArtifactsShown$ = TRUE
                PRINT ""
                linesKey$ = "messages,allArtifacts"
                GOSUB [sub:printLines]
            END IF
        END IF
        GOSUB [sub:checkQuest]
    END IF
RETURN

[cmd:drop]
    GOSUB [sub:locateItem]
    IF arg$ = "" THEN
        PRINT "Drop what?"
    ELSEIF where$ <> "player" THEN
        PRINT "You don't have that item."
    ELSE
        itemLoc$(arg$) = curRoom$
        IF equipped$ = arg$ THEN equipped$ = ""
        PRINT "You drop the "; arg$; "."
    END IF
RETURN

[cmd:examine]
    ' Items in the room or the inventory, and characters in the room
    GOSUB [sub:locateItem]
    GOSUB [sub:locateChr]
    IF arg$ = "" THEN
        PRINT "Examine what?"
    ELSEIF where$ = curRoom$ OR where$ = "player" THEN
        PRINT world$("items," + arg$ + ",desc")
        IF itemType$(arg$) = "weapon" THEN PRINT "Damage bonus: +"; itemDmg$(arg$)
        IF itemType$(arg$) = "consumable" THEN PRINT "Heals: "; itemHeal$(arg$); " HP"
        IF itemArmor$(arg$) > 0 THEN PRINT "Wards off "; itemArmor$(arg$); " damage per blow while carried."
        IF itemArtifact$(arg$) = TRUE THEN PRINT "This is one of the legendary artifacts!"
    ELSEIF chrWhere$ = curRoom$ THEN
        PRINT world$("characters," + arg$ + ",desc")
    ELSE
        PRINT "You don't see that here."
    END IF
RETURN

[cmd:use]
    GOSUB [sub:locateItem]
    IF arg$ = "" THEN
        PRINT "Use what?"
    ELSEIF where$ <> "player" THEN
        PRINT "You don't have that item."
    ELSEIF itemType$(arg$) <> "consumable" THEN
        PRINT "You can't use that item."
    ELSE
        hp$ = MIN(hp$ + itemHeal$(arg$), maxHp$)
        itemLoc$(arg$) = "gone"
        PRINT "You use the "; arg$; " and restore "; itemHeal$(arg$); " HP!"
        PRINT "Current health: "; hp$; "/"; maxHp$
    END IF
RETURN

[cmd:equip]
    GOSUB [sub:locateItem]
    IF arg$ = "" THEN
        PRINT "Equip what?"
    ELSEIF where$ <> "player" THEN
        PRINT "You don't have that item."
    ELSEIF itemType$(arg$) <> "weapon" THEN
        PRINT "You can't equip that."
    ELSE
        equipped$ = arg$
        GOSUB [sub:attackPower]
        PRINT "You equip the "; arg$; "."
        PRINT "Attack power is now: "; atkPower$
    END IF
RETURN

[cmd:attack]
    GOSUB [sub:locateChr]
    IF arg$ = "" THEN
        PRINT "Attack whom?"
    ELSEIF chrWhere$ <> curRoom$ THEN
        PRINT "There's no one here to attack."
    ELSEIF chrHostile$(arg$) = FALSE THEN
        PRINT "The "; arg$; " means you no harm. You lower your weapon."
    ELSE
        PRINT "You engage "; arg$; " in combat!"
        foe$ = arg$
        inCombat$ = TRUE
    END IF
RETURN

[cmd:talk]
    GOSUB [sub:locateChr]
    IF arg$ = "" THEN
        PRINT "Talk to whom?"
    ELSEIF chrWhere$ <> curRoom$ THEN
        PRINT "There's no one here by that name."
    ELSEIF chrHostile$(arg$) = TRUE THEN
        PRINT arg$; " doesn't want to talk!"
    ELSE
        GOSUB [sub:speak]
        IF talked$(arg$) = FALSE THEN GOSUB [sub:firstTalk]
    END IF
RETURN

[cmd:inventory]
    heldCount$ = 0
    FOR iv$ = 0 TO itemCount$ - 1
        IF itemLoc$(itemIds$(iv$)) = "player" THEN heldCount$ += 1
    NEXT
    IF heldCount$ = 0 THEN
        PRINT "Your inventory is empty."
    ELSE
        PRINT "You are carrying:"
        FOR iv$ = 0 TO itemCount$ - 1
            id$ = itemIds$(iv$)
            IF itemLoc$(id$) = "player" THEN
                text$ = "  - " + id$
                IF id$ = equipped$ THEN text$ += " (equipped)"
                IF itemArtifact$(id$) = TRUE THEN text$ += " [ARTIFACT]"
                PRINT text$
            END IF
        NEXT
    END IF
RETURN

[cmd:stats]
    GOSUB [sub:attackPower]
    GOSUB [sub:defense]
    GOSUB [sub:countArtifacts]
    PRINT ""
    PRINT "--- Your Stats ---"
    PRINT "Health: "; hp$; "/"; maxHp$
    PRINT "Attack Power: "; atkPower$
    PRINT "Defense: "; defense$
    PRINT "Artifacts Collected: "; artCount$; "/"; totalArtifacts$
    IF equipped$ <> "" THEN PRINT "Equipped: "; equipped$
RETURN

[cmd:quest]
    IF questActive$ = FALSE OR questDone$ = TRUE THEN
        PRINT "You have no active quests."
    ELSE
        PRINT ""
        PRINT "=== "; world$("quest,name"); " ==="
        PRINT world$("quest,desc")
        PRINT ""
        PRINT "Objectives:"
        FOR qd$ = 0 TO objCount$ - 1
            IF objDone$(qd$) = TRUE THEN
                PRINT "  [X] "; world$("quest,objectives," + qd$ + ",text")
            ELSE
                PRINT "  [ ] "; world$("quest,objectives," + qd$ + ",text")
            END IF
        NEXT
    END IF
RETURN

[cmd:help]
    PRINT ""
    PRINT "Available commands:"
    PRINT "  look/l          - Look around the current room"
    PRINT "  go [direction]  - Move in a direction (north, south, east, west)"
    PRINT "  take [item]     - Pick up an item"
    PRINT "  drop [item]     - Drop an item"
    PRINT "  examine [thing] - Examine an item or a person closely"
    PRINT "  use [item]      - Use a consumable item"
    PRINT "  equip [weapon]  - Equip a weapon"
    PRINT "  inventory/i     - Check your inventory"
    PRINT "  stats           - View your stats"
    PRINT "  quest/quests    - View active quests"
    PRINT "  talk [name]     - Talk to a character"
    PRINT "  attack [name]   - Attack a character"
    PRINT "  help            - Show this help message"
    PRINT "  quit/exit       - Quit the game"
RETURN

' ============================================
' MOVEMENT AND DISPLAY
' ============================================

[sub:tryMove]
    ' in: dir$, a valid exit of curRoom$. Opens a lock if the player
    ' carries the item it needs; an opened lock stays open.
    canMove$ = TRUE
    lockPath$ = "rooms," + curRoom$ + ",locks," + dir$ + ","
    lockKey$  = curRoom$ + "|" + dir$
    IF HASKEY(world$(lockPath$ + "item")) THEN
        IF HASKEY(unlocked$(lockKey$)) = FALSE THEN
            lockItem$ = world$(lockPath$ + "item")
            IF itemLoc$(lockItem$) = "player" THEN
                unlocked$(lockKey$) = TRUE
                PRINT world$(lockPath$ + "openMsg")
            ELSE
                canMove$ = FALSE
                PRINT world$(lockPath$ + "msg")
            END IF
        END IF
    END IF
    IF canMove$ = TRUE THEN
        prevRoom$ = curRoom$
        curRoom$ = world$("rooms," + curRoom$ + ",exits," + dir$)
        GOSUB [sub:showRoom]
        GOSUB [sub:checkHostiles]
    END IF
RETURN

[sub:showRoom]
    PRINT ""
    PRINT "=== "; world$("rooms," + curRoom$ + ",name"); " ==="
    PRINT world$("rooms," + curRoom$ + ",desc")
    IF HASKEY(world$("rooms," + curRoom$ + ",story")) THEN
        PRINT ""
        PRINT world$("rooms," + curRoom$ + ",story")
    END IF

    text$ = ""
    FOR ri$ = 0 TO itemCount$ - 1
        id$ = itemIds$(ri$)
        IF itemLoc$(id$) = curRoom$ THEN
            IF text$ <> "" THEN text$ += ", "
            text$ += id$
        END IF
    NEXT
    IF text$ <> "" THEN
        PRINT ""
        PRINT "You can see: "; text$
    END IF

    text$ = ""
    FOR rc$ = 0 TO chrCount$ - 1
        id$ = chrIds$(rc$)
        IF chrLoc$(id$) = curRoom$ AND chrAlive$(id$) = TRUE THEN
            IF text$ <> "" THEN text$ += ", "
            text$ += id$
            IF chrHostile$(id$) = TRUE THEN text$ += " (hostile)"
        END IF
    NEXT
    IF text$ <> "" THEN
        PRINT ""
        PRINT "Present here: "; text$
    END IF

    IF exitCount$(curRoom$) > 0 THEN
        text$ = ""
        FOR re$ = 0 TO exitCount$(curRoom$) - 1
            text$ += exitDir$(curRoom$ + "|" + re$) + " "
        NEXT
        PRINT ""
        PRINT "Exits: "; text$
    END IF
RETURN

[sub:showIntro]
    PRINT ""
    PRINT RULE#
    PRINT "    "; world$("title")
    PRINT RULE#
    n$ = 0
    WHILE HASKEY(world$("intro," + n$))
        PRINT ""
        PRINT world$("intro," + n$)
        n$ += 1
    WEND
    PRINT ""
    PRINT "Type 'help' if you need assistance with commands."
    PRINT "Type 'quest' to check your objectives."
RETURN

[sub:printLines]
    ' in: linesKey$ = path of a JSON list of strings. Prints each one.
    ' A missing list prints nothing, so optional texts need no checks.
    lnI$ = 0
    WHILE HASKEY(world$(linesKey$ + "," + lnI$))
        PRINT world$(linesKey$ + "," + lnI$)
        lnI$ += 1
    WEND
RETURN

' ============================================
' COMBAT
' ============================================

[sub:checkHostiles]
    ' Starts combat with the first living hostile in the current room.
    foe$ = ""
    FOR fh$ = 0 TO chrCount$ - 1
        id$ = chrIds$(fh$)
        IF foe$ = "" AND chrLoc$(id$) = curRoom$ AND
           chrAlive$(id$) = TRUE AND chrHostile$(id$) = TRUE THEN
            foe$ = id$
        END IF
    NEXT
    IF foe$ <> "" THEN
        PRINT ""
        PRINT foe$; " attacks!"
        inCombat$ = TRUE
    END IF
RETURN

[sub:combatRound]
    PRINT ""
    PRINT "--- Combat ---"
    PRINT hp$; " HP | "; foe$; ": "; chrHp$(foe$); " HP"
    PRINT "Options: attack, flee"
    LINE INPUT "> ", inputLine$
    GOSUB [sub:tokenize]
    IF cmd$ = "attack" THEN
        GOSUB [sub:exchangeBlows]
    ELSEIF cmd$ = "flee" THEN
        GOSUB [sub:flee]
    ELSEIF tokCount$ > 0 THEN
        PRINT "There's no time for that - attack or flee!"
    END IF
RETURN

[sub:exchangeBlows]
    ' The player strikes first; a surviving foe strikes back.
    GOSUB [sub:attackPower]
    dmg$ = atkPower$ + RND(5) - 2
    PRINT "You attack "; foe$; " for "; dmg$; " damage!"
    chrHp$(foe$) = MAX(chrHp$(foe$) - dmg$, 0)
    IF chrHp$(foe$) = 0 THEN
        GOSUB [sub:foeDefeated]
    ELSE
        GOSUB [sub:defense]
        dmg$ = MAX(chrAtk$(foe$) + RND(5) - 2 - defense$, 1)
        PRINT foe$; " attacks you for "; dmg$; " damage!"
        hp$ = MAX(hp$ - dmg$, 0)
        IF hp$ = 0 THEN
            PRINT ""
            linesKey$ = "messages,gameOver"
            GOSUB [sub:printLines]
            running$ = FALSE
            inCombat$ = FALSE
        END IF
    END IF
RETURN

[sub:foeDefeated]
    PRINT foe$; " has been defeated!"
    chrAlive$(foe$) = FALSE
    chrLoc$(foe$) = "none"
    inCombat$ = FALSE
    linesKey$ = "characters," + foe$ + ",onDefeat"
    GOSUB [sub:printLines]
    IF chrDrops$(foe$) <> "" THEN
        id$ = chrDrops$(foe$)
        itemLoc$(id$) = curRoom$
        PRINT "The "; foe$; " dropped the "; id$; "."
    END IF
    GOSUB [sub:checkQuest]
    IF chrEndsGame$(foe$) = TRUE THEN
        PRINT ""
        linesKey$ = "messages,victory"
        GOSUB [sub:printLines]
        running$ = FALSE
    ELSE
        GOSUB [sub:checkHostiles]
    END IF
RETURN

[sub:flee]
    ' Runs back to the previous room. Only if there is none (a fight in the
    ' starting room) does it fall back to the room's first exit.
    target$ = prevRoom$
    IF target$ = "" AND exitCount$(curRoom$) > 0 THEN
        dir$ = exitDir$(curRoom$ + "|0")
        target$ = world$("rooms," + curRoom$ + ",exits," + dir$)
    END IF
    IF target$ = "" THEN
        PRINT "There's nowhere to run!"
    ELSE
        PRINT "You flee from combat!"
        inCombat$ = FALSE
        prevRoom$ = curRoom$
        curRoom$ = target$
        PRINT "You escaped to: "; world$("rooms," + curRoom$ + ",name")
        GOSUB [sub:checkHostiles]
    END IF
RETURN

' ============================================
' CHARACTERS AND QUEST
' ============================================

[sub:speak]
    ' Says the next line of arg$'s dialogue for its current state,
    ' wrapping around to the first line after the last.
    linesKey$ = "characters," + arg$ + ",dialogue," + chrState$(arg$)
    lineCount$ = 0
    WHILE HASKEY(world$(linesKey$ + "," + lineCount$))
        lineCount$ += 1
    WEND
    IF lineCount$ = 0 THEN
        PRINT arg$; " has nothing to say."
    ELSE
        IF chrDlgIdx$(arg$) >= lineCount$ THEN chrDlgIdx$(arg$) = 0
        PRINT arg$; " says: \""; world$(linesKey$ + "," + chrDlgIdx$(arg$)); "\""
        chrDlgIdx$(arg$) = (chrDlgIdx$(arg$) + 1) % lineCount$
    END IF
RETURN

[sub:firstTalk]
    talked$(arg$) = TRUE
    PRINT ""
    linesKey$ = "characters," + arg$ + ",onFirstTalk"
    GOSUB [sub:printLines]
    IF chrGivesQuest$(arg$) = TRUE AND questActive$ = FALSE THEN
        questActive$ = TRUE
        PRINT ""
        PRINT "*** New Quest: "; world$("quest,name"); " ***"
    END IF
    IF chrNewState$(arg$) <> "" THEN
        chrState$(arg$) = chrNewState$(arg$)
        chrDlgIdx$(arg$) = 0
    END IF
    GOSUB [sub:checkQuest]
RETURN

[sub:checkQuest]
    ' Re-checks every open objective against the current game state.
    ' A finished objective stays finished. Because this looks at state
    ' instead of reacting to single events, the order in which the
    ' player does things no longer matters (fix 2).
    '   talk - every target has been talked to
    '   has  - every target item has been held at some point
    '   kill - every target character is dead
    IF questActive$ = TRUE AND questDone$ = FALSE THEN
        FOR qo$ = 0 TO objCount$ - 1
            IF objDone$(qo$) = FALSE THEN
                objType$ = world$("quest,objectives," + qo$ + ",type")
                allOk$ = TRUE
                qt$ = 0
                WHILE HASKEY(world$("quest,objectives," + qo$ + ",targets," + qt$))
                    targetName$ = world$("quest,objectives," + qo$ + ",targets," + qt$)
                    IF objType$ = "talk" THEN
                        IF talked$(targetName$) = FALSE THEN allOk$ = FALSE
                    ELSEIF objType$ = "has" THEN
                        IF obtained$(targetName$) = FALSE THEN allOk$ = FALSE
                    ELSEIF objType$ = "kill" THEN
                        IF chrAlive$(targetName$) = TRUE THEN allOk$ = FALSE
                    ELSE
                        allOk$ = FALSE      ' unknown type never completes
                    END IF
                    qt$ += 1
                WEND
                IF allOk$ = TRUE THEN
                    objDone$(qo$) = TRUE
                    PRINT "*** Objective complete: "; world$("quest,objectives," + qo$ + ",text"); " ***"
                END IF
            END IF
        NEXT

        doneCount$ = 0
        FOR qo$ = 0 TO objCount$ - 1
            IF objDone$(qo$) = TRUE THEN doneCount$ += 1
        NEXT
        IF doneCount$ = objCount$ THEN
            questDone$ = TRUE
            PRINT ""
            PRINT "*** QUEST COMPLETED: "; world$("quest,name"); " ***"
        END IF
    END IF
RETURN

' ============================================
' HELPERS
' ============================================

[sub:locateItem]
    ' in: arg$   out: where$ = the item's location, "" if there is no
    ' such item. Checked first with HASKEY: reading a missing array key
    ' would stop the program, and AND/OR cannot be relied on to skip it.
    where$ = ""
    IF HASKEY(itemLoc$(arg$)) THEN where$ = itemLoc$(arg$)
RETURN

[sub:locateChr]
    ' in: arg$   out: chrWhere$ = the character's location, "" if unknown
    chrWhere$ = ""
    IF HASKEY(chrLoc$(arg$)) THEN chrWhere$ = chrLoc$(arg$)
RETURN

[sub:attackPower]
    ' out: atkPower$ = base attack + equipped weapon bonus
    atkPower$ = baseAtk$
    IF equipped$ <> "" THEN atkPower$ += itemDmg$(equipped$)
RETURN

[sub:defense]
    ' out: defense$ = sum of the armor of every carried item
    defense$ = 0
    FOR df$ = 0 TO itemCount$ - 1
        id$ = itemIds$(df$)
        IF itemLoc$(id$) = "player" THEN defense$ += itemArmor$(id$)
    NEXT
RETURN

[sub:countArtifacts]
    ' out: artCount$ = number of artifacts in the inventory
    artCount$ = 0
    FOR ca$ = 0 TO itemCount$ - 1
        id$ = itemIds$(ca$)
        IF itemLoc$(id$) = "player" AND itemArtifact$(id$) = TRUE THEN artCount$ += 1
    NEXT
RETURN

' Opening of a session (deterministic up to the first fight; combat
' damage is random):
'
' ========================================
'     THE DRAGON'S CURSE
' ========================================
'
' You awaken in your cottage with a pounding headache.
' Sunlight streams through the window, but something feels... wrong.
' The air is thick with an unnatural silence.
'
' You remember fragments of last night - a massive shadow passing
' overhead, screams from the village, and a deep, rumbling roar
' that shook the very foundations of your home.
'
' You must investigate what happened...
'
' Type 'help' if you need assistance with commands.
' Type 'quest' to check your objectives.
'
' === Your Cottage ===
' A cozy cottage with a fireplace. The wooden floor creaks beneath your feet.
'
' Your home feels emptier than usual. Something terrible has happened.
'
' You can see: key, fireplace, dagger, potion
'
' Exits: north
'
' > take key
' You take the key.
