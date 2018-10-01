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

    ### Public Functions (Called from API) ###

    @spec new_game(binary()) :: struct()
    def new_game(word), do: %Game{ word: word |> String.downcase() }

    @spec new_game() :: struct()
    def new_game(), do: %Game{ word: Dictionary.random_word() |> String.downcase() }

    @spec tally(struct()) :: map()
    def tally(game = %Game{}) do
        %{
            # DIRECT FROM STRUCT
            game_state: game.status, 
            turns_left: game.turns_left, 
            last_guess: game.last_guess,

            # TRANSFORMED FROM STRUCT
            letters:    game.word |> mask_unguessed_letters(game.guessed, game.status),
            used:       game.guessed |> MapSet.to_list() |> Enum.sort()
        }
    end

    @spec make_move(struct(), binary()) :: tuple()
    def make_move(game = %Game{ status: status }, _guess) 
        when status in [:won, :lost]
    do
        { game, tally(game) }
    end 

    def make_move(game = %Game{}, guess) do

        new_state = game
                    |> check_for_duplicate_guess(guess)
                    |> process_guess(guess)

        { new_state, tally(new_state) }

    end

    ### Helper Functions ###

    defp mask_unguessed_letters(word, _guessed, status) 
        when status in [:won, :lost] 
    do
        word |> String.codepoints()
    end

    defp mask_unguessed_letters(word, guessed, _status) do

        mask_letter_if_unguessed = fn 
            letter -> if MapSet.member?(guessed, letter), do: letter, else: "_"
        end

        word                                    # "hello"
        |> String.codepoints()                  # |> ["h", "e", "l", "l", "o"]
        |> Enum.map(mask_letter_if_unguessed)   # |> ["_", "e", "l", "l", "_"]

    end

    defp check_for_duplicate_guess(game = %Game{} , guess) do 
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
        |> add_guess_to_state(guess)
        |> score_guess(guess)
        |> check_for_win_or_loss()
    end


    defp add_guess_to_state(game = %Game{}, guess) do
        %{ game |
            guessed:    game.guessed |> MapSet.put(guess),
            last_guess: guess
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

    defp check_for_win_or_loss(game = %Game{ turns_left: 0 }), do: %{ game | status: :lost }
    defp check_for_win_or_loss(game = %Game{ guessed: guessed, word: word, status: status }) do
        cond do
            won_game?(guessed, word, status) -> %{ game | status: :won }
            true                             -> game
        end
    end

    defp won_game?(guessed, word, status) do
        word
        |> mask_unguessed_letters(guessed, status)
        |> Enum.any?( &(&1 == "_") )
        |> Kernel.!
    end

end