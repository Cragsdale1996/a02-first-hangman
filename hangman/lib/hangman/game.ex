defmodule Hangman.Game do
    @moduledoc """
    Hangman game implementation.
    """

    ### Game state struct ###
    alias Hangman.Game
    defstruct(

        # DEFAULTS
        status:     :initializing,
        guessed:    %MapSet{},
        turns_left: 7,

        # PLACEHOLDERS (values will be determined during game)
        word:       "N/A", 
        last_guess: "N/A"

    )

    def new_game() do
        %Game{
            word: Dictionary.random_word() |> String.downcase()
        }
    end

    def tally(game = %Game{}) do
        %{
            # DIRECT FROM STRUCT
            game_state: game.status, 
            turns_left: game.turns_left, 
            last_guess: game.last_guess,

            # TRANSFORMED FROM STRUCT
            letters:    game.word |> mask_unguessed_letters(game.guessed),
            used:       game.guessed |> MapSet.to_list() |> Enum.sort()
        }
    end

    defp mask_unguessed_letters(word, guessed) do

        mask_letter_if_unguessed = fn 
            letter -> if MapSet.member?(guessed, letter), do: letter, else: "_"
        end

        word                                    # "hello"
        |> String.codepoints()                  # |> ["h", "e", "l", "l", "o"]
        |> Enum.map(mask_letter_if_unguessed)   # |> ["_", "e", "l", "l", "_"]

    end

    def make_move(game = %Game{status: status}, _guess) 
        when status in [:won, :lost]
    do
        { game, tally(game) }
    end 

    def make_move(game = %Game{}, guess) do

        new_state = game
                    |> check_for_duplicate(guess)
                    |> process_guess(guess)

        { new_state, tally(new_state) }

    end

    defp check_for_duplicate(game = %Game{} , guess) do 
        cond do
            MapSet.member?(game.guessed, guess) -> 
                %{ game | 
                    status: :already_used, 
                    last_guess: guess 
                }
            true ->
                %{ game |
                    status: :initializing
                }
        end
    end

    defp process_guess(game = %Game{ status: :already_used }, _guess), do: game
    defp process_guess(game = %Game{ status: :initializing }, guess) do
        game
        |> add_guess_to_set(guess)
        |> score_guess(guess)
        |> check_for_win_or_loss()
    end

    defp add_guess_to_set(game = %Game{}, guess) do
        %{ game |
            guessed: game.guessed |> MapSet.put(guess)
        }
    end

    defp score_guess(game = %Game{}, guess) do
        cond do 
            String.contains?(game.word, guess) -> 
                %{ game | 
                    status: :good_guess 
                }
            true -> 
                %{ game | 
                    status:     :bad_guess,
                    turns_left: game.turns_left-1
                }
        end
    end

    defp check_for_win_or_loss(game = %Game{turns_left: 0}), do: %{ game | status: :lost }
    defp check_for_win_or_loss(game = %Game{guessed: guessed, word: word}) do
        cond do
            won_game?(guessed, word) -> %{ game | status: :won }
            true                     -> game
        end
    end

    defp won_game?(guessed, word) do
        word
        |> mask_unguessed_letters(guessed)
        |> Enum.any?( &(&1 == "_") )
        |> Kernel.!
    end

end