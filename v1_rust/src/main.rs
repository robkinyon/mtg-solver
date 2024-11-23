use rand::Rng;
use std::cmp::Ordering;
use std::io;

mod lib1;

fn main() {
    println!("Input your guess.");

    let secret_number = rand::thread_rng().gen_range(1..=100);
    //println!("Secret: {secret_number}");
    lib1::print_secret(&secret_number);


    loop {
        let mut guess = String::new();

        io::stdin()
            .read_line(&mut guess)
            .expect("Failed to read line");

        if guess.trim().to_lowercase() == "exit" {
            break;
        }

        let guess: i32 = match guess.trim().parse() {
            Ok(num) => num,
            Err(_) => continue,
        };

        println!("You guess {guess}");

        match guess.cmp(&secret_number) {
            Ordering::Less => println!("Small"),
            Ordering::Greater => println!("Big"),
            Ordering::Equal => {
                println!("Same");
                break;
            },
        }
    }
    println!("Ok")
}
