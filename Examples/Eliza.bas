' ============================================
' ELIZA - BazzBasic Edition
' Original: Joseph Weizenbaum, MIT 1966
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Classic DOCTOR script - Rogerian therapist
' ============================================

' Color constants
LET BLACK# = 0
LET GREEN# = 2
LET CYAN# = 11
LET YELLOW# = 14
LET WHITE# = 15
LET LGRAY# = 7
LET LGREEN# = 10
LET MAGENTA# = 13
LET response$

' Response arrays
DIM responses$
DIM reflections$
DIM generic$

GOSUB [initResponses]
GOSUB [initReflections]
GOSUB [initGeneric]
GOSUB [title]
GOSUB [mainLoop]
END

' ============================================
' TITLE SCREEN
' ============================================
[title]
    CLS
    COLOR YELLOW#, BLACK#
    PRINT "\n "; REPEAT("*", 44)
    PRINT " *"; REPEAT(" ", 42); "*"
    PRINT " *            ";
    COLOR WHITE#, BLACK#
    PRINT "E L I Z A";
    COLOR YELLOW#, BLACK#
    PRINT "                   *"
    PRINT " *"; REPEAT(" ", 42); "*"
    PRINT " *   Rogerian Psychotherapist Simulation   *"
    PRINT " *"; REPEAT(" ", 42); "*"
    PRINT " "; REPEAT("*", 44)
    
    COLOR LGRAY#, BLACK#
    PRINT "\n Original by Joseph Weizenbaum, MIT 1966"
    PRINT " BazzBasic Edition\n"
    
    COLOR CYAN#, BLACK#
    PRINT " Please tell me what's been troubling you."
    PRINT " Type 'bye' or 'quit' to end the session.\n"
    
    COLOR WHITE#, BLACK#
    PRINT REPEAT("-", 50)
RETURN

' ============================================
' MAIN CONVERSATION LOOP
' ============================================
[mainLoop]
    [conversation]
    COLOR LGREEN#, BLACK#
    PRINT "\n You: ";
    COLOR WHITE#, BLACK#
    INPUT "", userInput$
    
    ' Normalize input
    LET userInput$ = TRIM(userInput$)
    LET upperInput$ = UCASE(userInput$)
    
    ' Check for exit
    IF upperInput$ = "BYE" OR upperInput$ = "QUIT" OR upperInput$ = "EXIT" THEN
        GOTO [goodbye]
    END IF
    
    ' Empty input
    IF LEN(userInput$) = 0 THEN
        COLOR CYAN#, BLACK#
        PRINT "\n Eliza: Please, tell me something."
        GOTO [conversation]
    END IF
    
    ' Process and respond
    GOSUB [findResponse]
    
    COLOR CYAN#, BLACK#
    PRINT "\n Eliza: "; response$
    
    GOTO [conversation]

[goodbye]
    COLOR YELLOW#, BLACK#
    PRINT "\n"; REPEAT("-", 50)
    COLOR CYAN#, BLACK#
    PRINT "\n Eliza: Thank you for talking with me."
    PRINT "        I hope our session was helpful."
    PRINT "        Take care of yourself. Goodbye.\n"
    COLOR WHITE#, BLACK#
RETURN

' ============================================
' FIND APPROPRIATE RESPONSE
' ============================================
[findResponse]
    ' Add spaces for word boundary matching
    LET padded$ = " " + upperInput$ + " "
    
    ' Check keywords in priority order
    
    ' Family keywords (high priority)
    IF INSTR(padded$, " MOTHER ") > 0 OR INSTR(padded$, " MOM ") > 0 THEN
        LET keyword$ = "MOTHER"
        GOTO [getKeywordResponse]
    END IF
    
    IF INSTR(padded$, " FATHER ") > 0 OR INSTR(padded$, " DAD ") > 0 THEN
        LET keyword$ = "FATHER"
        GOTO [getKeywordResponse]
    END IF
    
    IF INSTR(padded$, " FAMILY ") > 0 OR INSTR(padded$, " SISTER ") > 0 OR INSTR(padded$, " BROTHER ") > 0 THEN
        LET keyword$ = "FAMILY"
        GOTO [getKeywordResponse]
    END IF
    
    ' Emotional states
    IF INSTR(padded$, " SAD ") > 0 OR INSTR(padded$, " UNHAPPY ") > 0 OR INSTR(padded$, " DEPRESSED ") > 0 THEN
        LET keyword$ = "SAD"
        GOTO [getKeywordResponse]
    END IF
    
    IF INSTR(padded$, " HAPPY ") > 0 OR INSTR(padded$, " GLAD ") > 0 OR INSTR(padded$, " JOY ") > 0 THEN
        LET keyword$ = "HAPPY"
        GOTO [getKeywordResponse]
    END IF
    
    IF INSTR(padded$, " ANGRY ") > 0 OR INSTR(padded$, " MAD ") > 0 OR INSTR(padded$, " HATE ") > 0 THEN
        LET keyword$ = "ANGRY"
        GOTO [getKeywordResponse]
    END IF
    
    IF INSTR(padded$, " AFRAID ") > 0 OR INSTR(padded$, " FEAR ") > 0 OR INSTR(padded$, " SCARED ") > 0 THEN
        LET keyword$ = "AFRAID"
        GOTO [getKeywordResponse]
    END IF
    
    IF INSTR(padded$, " LONELY ") > 0 OR INSTR(padded$, " ALONE ") > 0 THEN
        LET keyword$ = "LONELY"
        GOTO [getKeywordResponse]
    END IF
    
    ' Self-referential patterns
    IF INSTR(padded$, " I AM ") > 0 THEN
        LET keyword$ = "IAM"
        GOSUB [extractAfterPhrase]
        LET extracted$ = afterPhrase$
        GOTO [getKeywordResponseWithExtract]
    END IF
    
    IF INSTR(padded$, " I FEEL ") > 0 THEN
        LET keyword$ = "IFEEL"
        GOSUB [extractAfterPhrase]
        LET extracted$ = afterPhrase$
        GOTO [getKeywordResponseWithExtract]
    END IF
    
    IF INSTR(padded$, " I WANT ") > 0 OR INSTR(padded$, " I NEED ") > 0 THEN
        LET keyword$ = "IWANT"
        GOTO [getKeywordResponse]
    END IF
    
    IF INSTR(padded$, " I THINK ") > 0 THEN
        LET keyword$ = "ITHINK"
        GOTO [getKeywordResponse]
    END IF
    
    IF INSTR(padded$, " I CAN'T ") > 0 OR INSTR(padded$, " I CANNOT ") > 0 THEN
        LET keyword$ = "ICANT"
        GOTO [getKeywordResponse]
    END IF
    
    ' Questions and statements about Eliza
    IF INSTR(padded$, " YOU ") > 0 THEN
        LET keyword$ = "YOU"
        GOTO [getKeywordResponse]
    END IF
    
    ' Dreams
    IF INSTR(padded$, " DREAM ") > 0 OR INSTR(padded$, " DREAMS ") > 0 THEN
        LET keyword$ = "DREAM"
        GOTO [getKeywordResponse]
    END IF
    
    ' Computers
    IF INSTR(padded$, " COMPUTER ") > 0 OR INSTR(padded$, " MACHINE ") > 0 THEN
        LET keyword$ = "COMPUTER"
        GOTO [getKeywordResponse]
    END IF
    
    ' Yes/No
    IF INSTR(padded$, " YES ") > 0 THEN
        LET keyword$ = "YES"
        GOTO [getKeywordResponse]
    END IF
    
    IF INSTR(padded$, " NO ") > 0 THEN
        LET keyword$ = "NO"
        GOTO [getKeywordResponse]
    END IF
    
    ' Questions
    IF INSTR(padded$, "?") > 0 THEN
        LET keyword$ = "QUESTION"
        GOTO [getKeywordResponse]
    END IF
    
    ' "Because" explanations
    IF INSTR(padded$, " BECAUSE ") > 0 THEN
        LET keyword$ = "BECAUSE"
        GOTO [getKeywordResponse]
    END IF
    
    ' Sorry
    IF INSTR(padded$, " SORRY ") > 0 THEN
        LET keyword$ = "SORRY"
        GOTO [getKeywordResponse]
    END IF
    
    ' Hello/greetings
    IF INSTR(padded$, " HELLO ") > 0 OR INSTR(padded$, " HI ") > 0 THEN
        LET keyword$ = "HELLO"
        GOTO [getKeywordResponse]
    END IF
    
    ' Always/Never
    IF INSTR(padded$, " ALWAYS ") > 0 THEN
        LET keyword$ = "ALWAYS"
        GOTO [getKeywordResponse]
    END IF
    
    IF INSTR(padded$, " NEVER ") > 0 THEN
        LET keyword$ = "NEVER"
        GOTO [getKeywordResponse]
    END IF
    
    ' Maybe/Perhaps
    IF INSTR(padded$, " MAYBE ") > 0 OR INSTR(padded$, " PERHAPS ") > 0 THEN
        LET keyword$ = "MAYBE"
        GOTO [getKeywordResponse]
    END IF
    
    ' No keyword matched - use generic response
    GOTO [getGenericResponse]

' Get response for keyword
[getKeywordResponse]
    LET count$ = responses$(keyword$ + "_COUNT")
    LET idx$ = RND(count$)
    response$ = responses$(keyword$ + "_" + STR(idx$))
RETURN

' Get response with extracted phrase
[getKeywordResponseWithExtract]
    LET count$ = responses$(keyword$ + "_COUNT")
    LET idx$ = RND(count$)
    LET template$ = responses$(keyword$ + "_" + STR(idx$))
    
    ' Replace placeholder with reflected phrase
    IF INSTR(template$, "*") > 0 THEN
        GOSUB [reflectPhrase]
        response$ = REPLACE(template$, "*", reflected$)
    ELSE
        response$ = template$
    END IF
RETURN

' Generic response when no keyword matches
[getGenericResponse]
    LET idx$ = RND(LEN(generic$()))
    response$ = generic$(idx$)
RETURN

' ============================================
' EXTRACT PHRASE AFTER KEYWORD
' ============================================
[extractAfterPhrase]
    LET afterPhrase$ = ""
    
    ' Find position after "I AM", "I FEEL", etc.
    LET pos$ = INSTR(padded$, " I AM ")
    IF pos$ > 0 THEN
        afterPhrase$ = MID(userInput$, pos$ + 5)
        RETURN
    END IF
    
    pos$ = INSTR(padded$, " I FEEL ")
    IF pos$ > 0 THEN
        afterPhrase$ = MID(userInput$, pos$ + 7)
        RETURN
    END IF
RETURN

' ============================================
' REFLECT PRONOUNS IN PHRASE
' ============================================
[reflectPhrase]
    LET reflected$ = " " + extracted$ + " "
    
    ' Apply reflections (order matters!)
    reflected$ = REPLACE(reflected$, " I ", " xyou ")
    reflected$ = REPLACE(reflected$, " ME ", " xyou ")
    reflected$ = REPLACE(reflected$, " MY ", " xyour ")
    reflected$ = REPLACE(reflected$, " MYSELF ", " xyourself ")
    reflected$ = REPLACE(reflected$, " AM ", " xare ")
    
    reflected$ = REPLACE(reflected$, " YOU ", " I ")
    reflected$ = REPLACE(reflected$, " YOUR ", " my ")
    reflected$ = REPLACE(reflected$, " YOURS ", " mine ")
    reflected$ = REPLACE(reflected$, " YOURSELF ", " myself ")
    reflected$ = REPLACE(reflected$, " ARE ", " am ")
    
    ' Remove temporary markers
    reflected$ = REPLACE(reflected$, "xyou", "you")
    reflected$ = REPLACE(reflected$, "xyour", "your")
    reflected$ = REPLACE(reflected$, "xyourself", "yourself")
    reflected$ = REPLACE(reflected$, "xare", "are")
    
    reflected$ = TRIM(reflected$)
RETURN

' ============================================
' INITIALIZE KEYWORD RESPONSES
' ============================================
[initResponses]
    ' MOTHER
    responses$("MOTHER_0") = "Tell me more about your mother."
    responses$("MOTHER_1") = "How do you feel about your mother?"
    responses$("MOTHER_2") = "What comes to mind when you think of your mother?"
    responses$("MOTHER_3") = "Does your relationship with your mother trouble you?"
    responses$("MOTHER_COUNT") = 4
    
    ' FATHER
    responses$("FATHER_0") = "Tell me more about your father."
    responses$("FATHER_1") = "How does your father make you feel?"
    responses$("FATHER_2") = "How do you feel about your father?"
    responses$("FATHER_3") = "Does your relationship with your father concern you?"
    responses$("FATHER_COUNT") = 4
    
    ' FAMILY
    responses$("FAMILY_0") = "Tell me more about your family."
    responses$("FAMILY_1") = "How do you get along with your family?"
    responses$("FAMILY_2") = "Is your family important to you?"
    responses$("FAMILY_3") = "What else comes to mind when you think of your family?"
    responses$("FAMILY_COUNT") = 4
    
    ' SAD
    responses$("SAD_0") = "I'm sorry to hear you're feeling sad. Can you tell me more?"
    responses$("SAD_1") = "What do you think is making you feel this way?"
    responses$("SAD_2") = "How long have you been feeling sad?"
    responses$("SAD_3") = "Do you often feel this way?"
    responses$("SAD_COUNT") = 4
    
    ' HAPPY
    responses$("HAPPY_0") = "I'm glad you're feeling happy. What's bringing you joy?"
    responses$("HAPPY_1") = "That's wonderful. Tell me more about it."
    responses$("HAPPY_2") = "What do you think is making you feel this way?"
    responses$("HAPPY_3") = "How does that happiness feel?"
    responses$("HAPPY_COUNT") = 4
    
    ' ANGRY
    responses$("ANGRY_0") = "What's making you feel angry?"
    responses$("ANGRY_1") = "Does feeling angry disturb you?"
    responses$("ANGRY_2") = "Do you often feel angry?"
    responses$("ANGRY_3") = "What would help you feel less angry?"
    responses$("ANGRY_COUNT") = 4
    
    ' AFRAID
    responses$("AFRAID_0") = "What frightens you the most about it?"
    responses$("AFRAID_1") = "How long have you felt this fear?"
    responses$("AFRAID_2") = "What would help you feel less afraid?"
    responses$("AFRAID_3") = "Do you often feel afraid?"
    responses$("AFRAID_COUNT") = 4
    
    ' LONELY
    responses$("LONELY_0") = "I understand. Loneliness can be difficult."
    responses$("LONELY_1") = "What do you think contributes to your loneliness?"
    responses$("LONELY_2") = "How long have you felt this way?"
    responses$("LONELY_3") = "What would help you feel less alone?"
    responses$("LONELY_COUNT") = 4
    
    ' I AM
    responses$("IAM_0") = "How long have you been *?"
    responses$("IAM_1") = "Do you believe it's normal to be *?"
    responses$("IAM_2") = "Do you enjoy being *?"
    responses$("IAM_3") = "Why do you think you are *?"
    responses$("IAM_COUNT") = 4
    
    ' I FEEL
    responses$("IFEEL_0") = "Tell me more about feeling *."
    responses$("IFEEL_1") = "Do you often feel *?"
    responses$("IFEEL_2") = "What makes you feel *?"
    responses$("IFEEL_3") = "How does being * affect you?"
    responses$("IFEEL_COUNT") = 4
    
    ' I WANT / I NEED
    responses$("IWANT_0") = "What would it mean to you if you got what you want?"
    responses$("IWANT_1") = "Why do you want that?"
    responses$("IWANT_2") = "What would getting that do for you?"
    responses$("IWANT_3") = "What if you never got what you want?"
    responses$("IWANT_COUNT") = 4
    
    ' I THINK
    responses$("ITHINK_0") = "Do you really think so?"
    responses$("ITHINK_1") = "But you're not sure?"
    responses$("ITHINK_2") = "What makes you think that?"
    responses$("ITHINK_3") = "Do you doubt that?"
    responses$("ITHINK_COUNT") = 4
    
    ' I CAN'T
    responses$("ICANT_0") = "What makes you think you can't?"
    responses$("ICANT_1") = "Have you tried?"
    responses$("ICANT_2") = "Perhaps you could if you tried."
    responses$("ICANT_3") = "What would it take for you to be able to?"
    responses$("ICANT_COUNT") = 4
    
    ' YOU (about Eliza)
    responses$("YOU_0") = "We should be discussing you, not me."
    responses$("YOU_1") = "Why do you say that about me?"
    responses$("YOU_2") = "Why does what I do matter to you?"
    responses$("YOU_3") = "Let's focus on your feelings instead."
    responses$("YOU_COUNT") = 4
    
    ' DREAM
    responses$("DREAM_0") = "What do you think that dream means?"
    responses$("DREAM_1") = "Do you dream often?"
    responses$("DREAM_2") = "What persons appear in your dreams?"
    responses$("DREAM_3") = "Are you disturbed by your dreams?"
    responses$("DREAM_COUNT") = 4
    
    ' COMPUTER
    responses$("COMPUTER_0") = "Do computers worry you?"
    responses$("COMPUTER_1") = "Why do you mention computers?"
    responses$("COMPUTER_2") = "Do you think machines can think?"
    responses$("COMPUTER_3") = "What about machines concerns you?"
    responses$("COMPUTER_COUNT") = 4
    
    ' YES
    responses$("YES_0") = "You seem quite positive about that."
    responses$("YES_1") = "Are you sure?"
    responses$("YES_2") = "I see. Please go on."
    responses$("YES_3") = "I understand. Tell me more."
    responses$("YES_COUNT") = 4
    
    ' NO
    responses$("NO_0") = "Why not?"
    responses$("NO_1") = "Are you saying no just to be negative?"
    responses$("NO_2") = "You're being a bit negative."
    responses$("NO_3") = "Why are you so definite about that?"
    responses$("NO_COUNT") = 4
    
    ' QUESTION
    responses$("QUESTION_0") = "Why do you ask that?"
    responses$("QUESTION_1") = "Does that question interest you?"
    responses$("QUESTION_2") = "What answer would please you most?"
    responses$("QUESTION_3") = "What do you think?"
    responses$("QUESTION_COUNT") = 4
    
    ' BECAUSE
    responses$("BECAUSE_0") = "Is that the real reason?"
    responses$("BECAUSE_1") = "Are you sure that's why?"
    responses$("BECAUSE_2") = "What other reasons might there be?"
    responses$("BECAUSE_3") = "Does that reason explain anything else?"
    responses$("BECAUSE_COUNT") = 4
    
    ' SORRY
    responses$("SORRY_0") = "Please don't apologize."
    responses$("SORRY_1") = "Apologies are not necessary."
    responses$("SORRY_2") = "What feelings does apologizing bring up?"
    responses$("SORRY_3") = "Don't be sorry, tell me more."
    responses$("SORRY_COUNT") = 4
    
    ' HELLO
    responses$("HELLO_0") = "Hello. How are you feeling today?"
    responses$("HELLO_1") = "Hi there. What's on your mind?"
    responses$("HELLO_2") = "Hello. What would you like to talk about?"
    responses$("HELLO_3") = "Greetings. Tell me what's troubling you."
    responses$("HELLO_COUNT") = 4
    
    ' ALWAYS
    responses$("ALWAYS_0") = "Can you think of a specific example?"
    responses$("ALWAYS_1") = "Really, always?"
    responses$("ALWAYS_2") = "When was the first time?"
    responses$("ALWAYS_3") = "What does 'always' remind you of?"
    responses$("ALWAYS_COUNT") = 4
    
    ' NEVER
    responses$("NEVER_0") = "Really, never?"
    responses$("NEVER_1") = "Why do you say never?"
    responses$("NEVER_2") = "That's a very strong word. Are you sure?"
    responses$("NEVER_3") = "What would it take for that to change?"
    responses$("NEVER_COUNT") = 4
    
    ' MAYBE
    responses$("MAYBE_0") = "You don't seem very certain."
    responses$("MAYBE_1") = "Why the uncertainty?"
    responses$("MAYBE_2") = "Can't you be more definite?"
    responses$("MAYBE_3") = "What would make you more sure?"
    responses$("MAYBE_COUNT") = 4
RETURN

' ============================================
' INITIALIZE REFLECTION WORDS
' ============================================
[initReflections]
    ' These are used in [reflectPhrase]
    reflections$("I") = "you"
    reflections$("ME") = "you"
    reflections$("MY") = "your"
    reflections$("AM") = "are"
    reflections$("YOU") = "I"
    reflections$("YOUR") = "my"
    reflections$("ARE") = "am"
RETURN

' ============================================
' INITIALIZE GENERIC RESPONSES
' ============================================
[initGeneric]
    generic$(0) = "Please tell me more."
    generic$(1) = "Can you elaborate on that?"
    generic$(2) = "That's interesting. Please continue."
    generic$(3) = "I see. Go on."
    generic$(4) = "How does that make you feel?"
    generic$(5) = "What does that suggest to you?"
    generic$(6) = "I'm not sure I understand. Can you explain?"
    generic$(7) = "Let's explore that further."
    generic$(8) = "Why do you say that?"
    generic$(9) = "That's quite interesting."
    generic$(10) = "Can you tell me more about it?"
    generic$(11) = "What comes to mind when you say that?"
    generic$(12) = "And how does that relate to your feelings?"
    generic$(13) = "Please continue, I'm listening."
    generic$(14) = "What else would you like to discuss?"
RETURN
