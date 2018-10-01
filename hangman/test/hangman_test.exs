defmodule HangmanTest do
  use ExUnit.Case
  doctest Hangman

  test "Dictionary module seccessfully imported" do
    assert Dictionary.random_word() |> is_binary()
  end

  test "new_game returns default state" do

    game = Hangman.new_game()

    assert game.turns_left      == 7
    assert game.status          == :initializing
    assert game.guessed         == %MapSet{}
    assert game.word            |> is_binary()

  end

  test "Default tally" do

    game  = Hangman.new_game()
    tally = Hangman.tally(game)

    assert tally.game_state == :initializing
    assert tally.turns_left == 7
    assert tally.last_guess == "N/A"
    assert tally.letters    == game.word |> String.codepoints |> Enum.map( fn x -> "_" end )
    assert tally.used       == []

  end



end
