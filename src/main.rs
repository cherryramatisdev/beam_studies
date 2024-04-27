use std::fs;

#[repr(u8)]
enum OpCode {
    Label = 1,
    FuncInfo = 2,
    IntCodeEnd = 3,
    Return = 19,
    // Move = 64,
}

#[repr(u8)]
enum Tag {
    U = 0,
    // I = 1,
    A = 2,
    // X = 3,
}

fn encode(tag: Tag, n: i32) -> Vec<u8> {
    match n {
        n if n < 0 => todo!("negative"),
        0..=15 => {
            let tag = tag as u8;
            let n = n as u8;

            // << Is a bitwise shift, which moves the bit by 4 (multiply by 16)
            // | Is a bitwise or, it combines both bits.
            vec![(n << 4) | tag]
        }
        _ => todo!("large numbers"),
    }
}

fn pad_chunk(chunk: &mut Vec<u8>) {
    let rem = chunk.len() % 4;

    if rem != 0 {
        for _ in 0..4 - rem {
            chunk.push(0);
        }
    }
}

// CodeChunk = <<
//   ChunkName:4/unit:8 = "Code",
//   ChunkSize:32/big,
//   SubSize:32/big,
//   InstructionSet:32/big,        % Must match code version in the emulator
//   OpcodeMax:32/big,
//   LabelCount:32/big,
//   FunctionCount:32/big,
//   Code:(ChunkSize-SubSize)/binary,  % all remaining data
//   Padding4:0..3/unit:8
// >>
fn code_chunk() -> Vec<u8> {
    let sub_size: u32 = 16;
    let instruction_set: u32 = 0;
    let opcode_max: u32 = 0;
    let label_count: u32 = 3;
    let function_count: u32 = 1;

    let mut chunk: Vec<u8> = Vec::new();

    chunk.extend(sub_size.to_be_bytes());
    chunk.extend(instruction_set.to_be_bytes());
    chunk.extend(opcode_max.to_be_bytes());
    chunk.extend(label_count.to_be_bytes());
    chunk.extend(function_count.to_be_bytes());

    chunk.push(OpCode::Label as u8);
    chunk.extend(encode(Tag::U, 1));

    chunk.push(OpCode::FuncInfo as u8);
    chunk.extend(encode(Tag::A, 1));
    chunk.extend(encode(Tag::A, 1));
    chunk.extend(encode(Tag::U, 0));

    chunk.push(OpCode::Label as u8);
    chunk.extend(encode(Tag::U, 2));

    chunk.push(OpCode::Return as u8);

    chunk.push(OpCode::IntCodeEnd as u8);

    let mut result = Vec::new();
    result.extend("Code".as_bytes());
    result.extend((chunk.len() as u32).to_be_bytes());

    pad_chunk(&mut chunk);

    result.extend(chunk);

    return result;
}

// AtomChunk = <<
//   ChunkName:4/unit:8 = "Atom",
//   ChunkSize:32/big,
//   NumberOfAtoms:32/big,
//   [<<AtomLength:8, AtomName:AtomLength/unit:8>> || repeat NumberOfAtoms],
//   Padding4:0..3/unit:8
// >>
fn atom_chunk(atoms: &[&str]) -> Vec<u8> {
    let mut chunk = Vec::new();

    chunk.extend((atoms.len() as u32).to_be_bytes());

    for atom in atoms {
        chunk.extend((atom.len() as u8).to_be_bytes());
        chunk.extend(atom.as_bytes());
    }

    let mut result = Vec::new();

    // NOTE: This will only consider assembling in latin1, not utf-8, newer Erlang/OTP compiler
    // doesn't even support non utf-8 anymore.
    //
    // result.extend("Atom".as_bytes());

    result.extend("AtU8".as_bytes());
    result.extend((chunk.len() as u32).to_be_bytes());

    pad_chunk(&mut chunk);

    result.extend(chunk);

    return result;
}

// ImportChunk = <<
//   ChunkName:4/unit:8 = "ImpT",
//   ChunkSize:32/big,
//   ImportCount:32/big,
//   [ << ModuleName:32/big,
//        FunctionName:32/big,
//        Arity:32/big
//     >> || repeat ImportCount ],
//   Padding4:0..3/unit:8
// >>
fn imports_chunk() -> Vec<u8> {
    let mut chunk = Vec::new();

    let import_count: u32 = 0;
    chunk.extend(import_count.to_be_bytes());

    let mut result = Vec::new();
    result.extend("ImpT".as_bytes());
    result.extend((chunk.len() as u32).to_be_bytes());
    pad_chunk(&mut chunk);

    result.extend(chunk);

    return result;
}

// ExportChunk = <<
//   ChunkName:4/unit:8 = "ExpT",
//   ChunkSize:32/big,
//   ExportCount:32/big,
//   [ << FunctionName:32/big,
//        Arity:32/big,
//        Label:32/big
//     >> || repeat ExportCount ],
//   Padding4:0..3/unit:8
// >>
fn exports_chunk() -> Vec<u8> {
    let mut chunk = Vec::new();

    let export_count: u32 = 0;
    chunk.extend(export_count.to_be_bytes());

    let mut result = Vec::new();
    result.extend("ExpT".as_bytes());
    result.extend((chunk.len() as u32).to_be_bytes());
    pad_chunk(&mut chunk);

    result.extend(chunk);

    return result;
}

// StringChunk = <<
//   ChunkName:4/unit:8 = "StrT",
//   ChunkSize:32/big,
//   Data:ChunkSize/binary,
//   Padding4:0..3/unit:8
// >>
fn string_chunk() -> Vec<u8> {
    let mut chunk = Vec::new();

    chunk.extend("StrT".as_bytes());
    chunk.extend(0u32.to_be_bytes());

    return chunk;
}

fn main() {
    let mut beam = Vec::new();

    // NOTE: Magic "footer" to interpret as a beam file.
    beam.extend("BEAM".as_bytes());
    beam.extend(code_chunk());
    beam.extend(atom_chunk(&["cherry"]));
    beam.extend(imports_chunk());
    beam.extend(exports_chunk());
    beam.extend(string_chunk());

    let mut bytes: Vec<u8> = Vec::new();

    // NOTE: Magic number to start the program
    bytes.extend("FOR1".as_bytes());

    // NOTE: The size of the whole file minus the FOR1, the BEAM and the SIZE itself.
    bytes.extend((beam.len() as u32).to_be_bytes());

    bytes.extend(beam);

    fs::write("cherry.beam", &bytes).unwrap();
}
