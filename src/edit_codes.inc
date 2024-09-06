!> EDIT_CODES.INC -- Declare constants for EDTI$ codes.
! In theory this is a nice idea.  In practice the names are too long. :(
    declare long constant                                                     &
        EDIT_DISCARD_PARITY = 1,                                              &
        EDIT_DISCARD_ALL_WHITESPACE = 2,                                      &
        EDIT_DISCARD_SOME_CTRLS = 4,                                          &
        EDIT_DISCARD_LEADING_WHITESPACE = 8,                                  &
        EDIT_COMPRESS_WHITESPACE = 16,                                        &
        EDIT_CONVERT_TO_UPPERCASE = 32 = 32,                                  &
        EDIT_CONVERT_BRACKETS_TO_PARENS = 64,                                 &
        EDIT_DISCARD_TRAILING_WHITESPACE = 128,                               &
        EDIT_SUPRESS_IN_QUOTES = 256
        
