# Beam studies - Rust implementation

## Usage

1. Checkout the `main` function to include new functions in the hash table in the line 278

```rust
fn main() {
    let mut program: Program = HashMap::new();
    program.insert("world", 420);
```

2. Run `cargo run`
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

## To-dos

- [ ] Implement a parser for a new language and accept a file as first argument.
