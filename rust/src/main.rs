pub mod ast;
pub mod compiler;

use std::{collections::HashMap, env, fs, path::PathBuf};

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() > 1 {
        let path = &args[1];
        let path = PathBuf::from(path);

        let content = fs::read_to_string(&path).unwrap();
        let lines = content.trim().split('\n').collect::<Vec<&str>>();

        let ast = ast::parse(lines);
        let mut program: compiler::Program = HashMap::new();

        for code in ast.iter() {
            program.insert(&code.function_name, code.return_value);
        }

        let module_name = path.file_stem().unwrap().to_str().unwrap();

        let bytes = compiler::compile(module_name, program);

        fs::write(format!("{}.beam", module_name), &bytes).unwrap();
    } else {
        println!("Usage: {} <file_name>", args[0]);
    }
}
