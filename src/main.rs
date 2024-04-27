use std::fs;

fn pad_chunk(chunk: &mut Vec<u8>) {
    let rem = chunk.len() % 4;

    if rem != 0 {
        for _ in 0..4 - rem {
            chunk.push(0);
        }
    }
}

fn code_chunk() -> Vec<u8> {
    let sub_size: u32 = 16;
    let instruction_set: u32 = 0;
    let opcode_max: u32 = 0;
    let label_count: u32 = 0;
    let function_count: u32 = 0;

    let mut chunk: Vec<u8> = Vec::new();

    chunk.extend(sub_size.to_be_bytes());
    chunk.extend(instruction_set.to_be_bytes());
    chunk.extend(opcode_max.to_be_bytes());
    chunk.extend(label_count.to_be_bytes());
    chunk.extend(function_count.to_be_bytes());

    let mut result = Vec::new();
    result.extend("Code".as_bytes());
    result.extend((chunk.len() as u32).to_be_bytes());

    pad_chunk(&mut chunk);

    result.extend(chunk);

    return result;
}

fn main() {
    let mut beam = Vec::new();

    // NOTE: Magic "footer" to interpret as a beam file.
    beam.extend("BEAM".as_bytes());
    beam.extend(code_chunk());

    let mut bytes: Vec<u8> = Vec::new();

    // NOTE: Magic number to start the program
    bytes.extend("FOR1".as_bytes());

    // NOTE: The size of the whole file minus the FOR1, the BEAM and the SIZE itself.
    bytes.extend((beam.len() as u32).to_be_bytes());

    bytes.extend(beam);

    fs::write("cherry.beam", &bytes).unwrap();
}
