defmodule BeamCherryTest do
  use ExUnit.Case
  doctest BeamCherry

  test "tokenize" do
    sample = """
    world = 420
    hello = 777
    """

    assert BeamCherry.tokenize(sample) ==
             [
               %{func_name: "world", return_value: 420},
               %{func_name: "hello", return_value: 777}
             ]
  end
end
