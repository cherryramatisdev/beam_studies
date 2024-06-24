# BEAM Studies in Elixir

## Getting started

1. Write a sample file, like the one found in `example/`
2. Run the mix task: `mix beam.compile example/number.be`
3. Load the module in erlang:

```erlang
❯ mix beam.compile example/number.be
Compiling 1 file (.ex)
❯ erl
Erlang/OTP 27 [erts-15.0] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit]

Eshell V15.0 (press Ctrl+G to abort, type help(). for help)
1> code:load_file(output).
{module,output}
2>
```

**Bonus tip**

You can run only the tokenizer:

```shell
❯ cat example/number.be
world = 420
hello = 777
❯ mix tokenize example/number.be
[
  %{func_name: "world", return_value: 420},
  %{func_name: "hello", return_value: 777}
]
```

## To dos

- [ ] Support defining the functions from the `be` file
- [ ] Support operations like + - * /
- [ ] Support strings
- [ ] Support functions
- [ ] Make the language turing complete
