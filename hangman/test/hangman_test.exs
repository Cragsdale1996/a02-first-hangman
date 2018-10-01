defmodule HangmanTest do
  use ExUnit.Case
  doctest Hangman

  test "Dictionary module seccessfully imported" do
    assert Dictionary.random_word() |> is_binary()
  end

  test "new_game returns default state" do

    game = Hangman.new_game()

    assert game.status          == :initializing
    assert game.guessed         == %MapSet{}
    assert game.turns_left      == 7
    assert game.word            |> is_binary()
    assert game.last_guess      == "N/A"

  end

  test "Default tally" do

    game  = Hangman.new_game()
    tally = Hangman.tally(game)

    assert tally.game_state == :initializing
    assert tally.turns_left == 7
    assert tally.last_guess == "N/A"
    assert tally.letters    == game.word |> String.codepoints |> Enum.map( fn _x -> "_" end )
    assert tally.used       == []

  end

  test "make_move: :bad_guess, :good_guess, :already_used" do

    game = Hangman.new_game("hello")
    
    { game, tally } = Hangman.make_move(game, "a")

    assert game.status      == :bad_guess
    assert game.guessed     |> MapSet.member?("a")
    assert game.turns_left  == 6
    assert game.word        == "hello"
    assert game.last_guess  == "a"

    assert tally.game_state == :bad_guess
    assert tally.turns_left == 6
    assert tally.last_guess == "a"
    assert tally.letters    == ["_", "_", "_", "_", "_"]
    assert tally.used       == ["a"]

    { game, tally } = Hangman.make_move(game, "a")

    assert game.status      == :already_used
    assert game.guessed     |> MapSet.member?("a")
    assert game.turns_left  == 6
    assert game.word        == "hello"
    assert game.last_guess  == "a"

    assert tally.game_state == :already_used
    assert tally.turns_left == 6
    assert tally.last_guess == "a"
    assert tally.letters    == ["_", "_", "_", "_", "_"]
    assert tally.used       == ["a"]

    { game, tally } = Hangman.make_move(game, "h")

    assert game.status      == :good_guess
    assert game.guessed     |> MapSet.member?("h")
    assert game.turns_left  == 6
    assert game.word        == "hello"
    assert game.last_guess  == "h"

    assert tally.game_state == :good_guess
    assert tally.turns_left == 6
    assert tally.last_guess == "h"
    assert tally.letters    == ["h", "_", "_", "_", "_"]
    assert tally.used |> Enum.sort() == ["a", "h"]

  end

  test "make_move: :won" do

    game = Hangman.new_game("hello")
    
    { game, _tally } = Hangman.make_move(game, "h")
    { game, _tally } = Hangman.make_move(game, "e")
    { game, _tally } = Hangman.make_move(game, "l")
    { game, tally } = Hangman.make_move(game, "o")

    assert game.status      == :won
    assert game.turns_left  == 7

    assert tally.game_state == :won
    assert tally.turns_left == 7
    assert tally.last_guess == "o"
    assert tally.letters    == ["h", "e", "l", "l", "o"]
    assert tally.used |> Enum.sort() == ["e", "h", "l", "o"]

  end

  test "make_move: :lost" do

    game = Hangman.new_game("hello")
    
    { game, _tally } = Hangman.make_move(game, "a")
    { game, _tally } = Hangman.make_move(game, "b")
    { game, _tally } = Hangman.make_move(game, "c")
    { game, _tally } = Hangman.make_move(game, "d")
    { game, _tally } = Hangman.make_move(game, "f")
    { game, _tally } = Hangman.make_move(game, "g")
    { game, tally } = Hangman.make_move(game, "i")

    assert game.status      == :lost
    assert game.turns_left  == 0

    assert tally.game_state == :lost
    assert tally.turns_left == 0
    assert tally.letters    == ["h", "e", "l", "l", "o"]
    assert tally.used |> Enum.sort() == ["a", "b", "c", "d", "f", "g", "i"]

  end

end
