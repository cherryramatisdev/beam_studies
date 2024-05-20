defmodule BeamCherry.Tokenizer do
  @type t() :: %{func_name: String.t(), return_value: String.t() | integer()}

  @spec tokenize(content :: String.t()) :: list(t())
  def call(lines) do
    lines
    |> Enum.map(fn x -> String.split(x, "=") |> Enum.map(&String.trim/1) end)
    |> Enum.map(&tokenize/1)
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
