defmodule BeamCherry do
  @moduledoc """
  This module will serve as the entry point for the whole tokeniser, parser and
  binary BEAM transpiler
  """

  @spec tokenize(content :: String.t()) :: list(any())
  def tokenize(content) when is_binary(content) do
    content
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn x -> String.split(x, "=") |> Enum.map(&String.trim/1) end)
    |> Enum.map(&BeamCherry.tokenize/1)
  end

  def tokenize([func_name, return_value]) do
    return_value =
      if numeric?(return_value) do
        String.to_integer(return_value)
      else
        return_value
      end

    %{func_name: func_name, return_value: return_value}
  end

  defp numeric?(string) do
    case Integer.parse(string) do
      {_, ""} -> true
      _ -> false
    end
  end
end
