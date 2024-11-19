use rand::Rng;
use std::cmp::Ordering;
use std::io;

fn main() {
    println!("Input your guess.");

    let secret_number = rand::thread_rng().gen_range(1..=100);
    println!("Secret: {secret_number}");

    loop {
        let mut guess = String::new();

        io::stdin()
            .read_line(&mut guess)
            .expect("Failed to read line");

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
