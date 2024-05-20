defmodule BeamCherry.Compile do
  @spec call(ast :: list(BeamCherry.Tokenizer.t())) :: {:ok} | {:err}
  def call(_ast) do
    beam =
      [to_charlist("BEAM")]
      |> Enum.concat(code_chunk())

    padded_beam = pad_chunk(beam)

    bytes =
      [to_charlist("FOR1")]
      |> Enum.concat([<<ceil((length(padded_beam) + 3) / 4)::size(32)>> | padded_beam])

    File.write(
      "output.beam",
      bytes |> IO.iodata_to_binary()
    )

    {:ok}
  end

  @spec atom_chunk(atoms :: list()) :: list()
  def atom_chunk(atoms) do
    formatted_atoms =
      Enum.flat_map(atoms, fn atom ->
        [<<to_charlist(atom) |> length()::size(32)>>, to_charlist(atom)]
      end)

    chunk = [<<length(atoms)::size(32)>>] |> Enum.concat(formatted_atoms)

    [to_charlist("Atom"), <<length(chunk)::size(32)>>] |> Enum.concat(pad_chunk(chunk))
  end

  @spec code_chunk() :: list()
  defp code_chunk() do
    sub_size = 16
    instruction_set = 0
    opcode_max = 169
    label_count = 0
    function_count = 0

    chunk =
      [
        <<sub_size::size(32)>>,
        <<instruction_set::size(32)>>,
        <<opcode_max::size(32)>>,
        <<label_count::size(32)>>,
        <<function_count::size(32)>>
      ]

    result = [to_charlist("Code"), <<length(chunk)::size(32)>>]

    Enum.concat(result, pad_chunk(chunk))
  end

  @spec pad_chunk(chunk :: list()) :: list()
  defp pad_chunk(chunk) do
    chunk_rem = length(chunk) |> rem(4)

    if chunk_rem != 0 do
      Enum.concat(chunk, List.duplicate(0, 4 - chunk_rem))
    else
      chunk
    end
  end
end
