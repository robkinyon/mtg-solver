pub fn print_secret(secret : &i32) -> bool {
    println!("Secret: {secret}");
    true
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let v = print_secret(&5);
        assert_eq!(v, true);
    }
}
