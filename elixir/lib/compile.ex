defmodule BeamCherry.Compile do
  @spec call(ast :: list(BeamCherry.Tokenizer.t())) :: {:ok} | {:err}
  def call(_ast) do
    beam_content = ["BEAM"] ++ code_chunk() ++ atom_chunk(["output", "hello", "world"])

    bytes =
      ["FOR1", <<arr_byte_length(beam_content)::size(32)-big-integer>>] ++
        beam_content

    File.write(
      "output.beam",
      bytes |> Enum.join()
    )

    {:ok}
  end

  @spec code_chunk() :: [binary()]
  def code_chunk() do
    instruction_set = 0
    sub_size = 16
    opcode_max = 169
    label_count = 0
    function_count = 0

    chunk = [
      <<sub_size::size(32)-big-integer>>,
      <<instruction_set::size(32)-big-integer>>,
      <<opcode_max::size(32)-big-integer>>,
      <<label_count::size(32)-big-integer>>,
      <<function_count::size(32)-big-integer>>
    ]

    ["Code", <<arr_byte_length(chunk)::size(32)-big-integer>>] ++ pad_chunk(chunk)
  end

  @spec atom_chunk([String.t()]) :: [binary()]
  def atom_chunk(atoms) do
    chunk =
      [<<length(atoms)::size(32)-big-integer>>] ++
        Enum.map(atoms, fn atom -> <<byte_size(atom)::size(32)-big-integer>> end) ++ atoms

    ["AtU8", <<arr_byte_length(chunk)::size(32)-big-integer>>] ++ pad_chunk(chunk)
  end

  def pad_chunk(chunk) do
    total_bytes = Enum.reduce(chunk, 0, fn x, acc -> acc + byte_size(x) end)
    chunk_rem = rem(total_bytes, 4)

    if chunk_rem != 0 do
      chunk ++ [:binary.copy(<<0>>, 4 - chunk_rem)]
    else
      chunk
    end
  end

  @spec arr_byte_length([binary()]) :: integer()
  defp arr_byte_length(chunks), do: chunks |> Enum.join() |> byte_size()
end
