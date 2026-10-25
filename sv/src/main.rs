//! `epitome-sv [flags] file.sv...`: for now, tokenises each file and
//! reports the first lexical error with its line and column.

use epitome_sv::lexer::tokenize;
use epitome_sv::source::Source;
use std::process::ExitCode;

fn main() -> ExitCode {
    let mut failed = false;
    let mut files = 0;
    for arg in std::env::args().skip(1) {
        if arg.starts_with('-') || arg.starts_with('+') {
            continue;
        }
        files += 1;
        let text = match std::fs::read_to_string(&arg) {
            Ok(text) => text,
            Err(e) => {
                eprintln!("{arg}: error: {e}");
                failed = true;
                continue;
            }
        };
        let src = Source::new(arg, text);
        if let Err(e) = tokenize(&src.text) {
            eprint!("{}", e.render(&src));
            failed = true;
        }
    }
    if files == 0 {
        eprintln!("usage: epitome-sv [flags] file.sv...");
        return ExitCode::from(2);
    }
    if failed { ExitCode::FAILURE } else { ExitCode::SUCCESS }
}
