#[derive(Debug)]
pub struct Ast {
    pub function_name: String,
    pub return_value: usize,
}

/// Basic grammar:
/// foo = 420
/// bar = 200
pub fn parse(content: Vec<&str>) -> Vec<Ast> {
    let mut result: Vec<Ast> = Vec::new();

    for line in content.iter() {
        let line = line.split('=').map(|world| world.trim()).collect::<Vec<&str>>();
        let function_name = line[0];
        let return_value = line[1].parse::<usize>().unwrap_or(0);

        result.push(Ast {function_name: function_name.to_string(), return_value});
    }

    return result;
}
