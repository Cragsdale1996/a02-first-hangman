defmodule Hangman.Game do
    @moduledoc """
    Hangman game implementation.
    """

    defstruct(
        turns_left:                  6,
        status:          :initializing,
        letters_guessed:     %MapSet{},
        word:            "LedZeppelin"
    )

    def new_game() do
        %Game{
            word: Dictionary.random_word()
        }
    end
    
    def tally(game = %Game{}) do
        %{ 
            game_state: game.status, 
            turns_left: game.turns_left, 
            letters: mask_unguessed_letters(game.word, game.letters_guessed), 
            used: game.letters_guessed 
        }
    end

    defp mask_unguessed_letters(word, letters_guessed)

        mask_letter_if_unguessed = fn 
            letter -> if MapSet.member?(letters_guessed, letter), do: letter, else: "_"
        end

        word                                    # "hello"
        |> String.codepoints()                  # ["h", "e", "l", "l", "o"]
        |> Enum.map(mask_letter_if_unguessed)   # ["_", "e", "l", "l", "_"]

    end

    def make_move(_game, _guess) do
        :make_move
    end
    
end