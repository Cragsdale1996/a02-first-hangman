defmodule Hangman.Game.State do
    
    defstruct(
        turns_left:                  6,
        status:          :initializing,
        letters_guessed:            [],
        word:            "LedZeppelin"
    )

end