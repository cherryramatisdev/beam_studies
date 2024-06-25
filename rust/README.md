# Beam studies - Rust implementation

## Usage

1. Write a sample module file, such as the one found in `examples/foo.be`

```shell
❯ cat examples/foo.be
hello = 400
world = 420
```

2. Run `cargo run examples/foo.be` where `examples/foo.be` is the path for your file of choice.
3. Load the code in the erlang REPL as the following:

```erlang
❯ erl
Erlang/OTP 27 [erts-15.0] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit]

Eshell V15.0 (press Ctrl+G to abort, type help(). for help)
1> code:load_file(cherry).
{module,cherry}
2> cherry:world().
420
3>
```
