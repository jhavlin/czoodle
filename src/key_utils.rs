/**
 * Convert a number to string with radix 36.
 */
fn num_to_str_36(v: u32) -> String {
    let mut res: Vec<u32> = vec![];
    let mut c = v;
    while c > 0 {
        let div = c / 36;
        let rem = c % 36;
        res.push(rem);
        c = div;
    }
    if res.len() == 0 {
        res.push(0);
    }
    let mut s = String::new();
    res.into_iter().rev().for_each(|d| {
        s.push(core::char::from_digit(d, 36).unwrap());
    });
    s
}

/**
 * Get project key from year, month, day and sequence number in that day.
 */
pub fn get_project_key(year: i32, month: u32, day: u32, seq: u32) -> String {
    let y = (i32::max(year, 2001) - 2000) as u32;
    let m = core::char::from_digit(month, 36).unwrap();
    let d = core::char::from_digit(day, 36).unwrap();
    let s = num_to_str_36(seq);
    format!("{}{}{}{}", y, m, d, s)
}

pub fn key_to_path(project_key: &str) -> String {
    let mut y = String::new();
    let mut m = String::new();
    let mut d = String::new();
    let mut s = String::new();

    let mut iter = project_key.chars();

    y.push(iter.next().unwrap());
    y.push(iter.next().unwrap());
    m.push(iter.next().unwrap());
    d.push(iter.next().unwrap());

    iter.for_each(|c| {
        s.push(c);
    });

    let y = 2000 + u32::from_str_radix(&y, 10).unwrap();
    let m = u32::from_str_radix(&m, 36).unwrap();
    let d = u32::from_str_radix(&d, 36).unwrap();
    let s = u32::from_str_radix(&s, 36).unwrap();

    format!("{}/{}/{}/{}.dat", y, m, d, s)
}

/**
 * Tests
 */
#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn can_convert_to_radix_36() {
        assert_eq!(num_to_str_36(0), "0");
        assert_eq!(num_to_str_36(1), "1");
        assert_eq!(num_to_str_36(35), "z");
        assert_eq!(num_to_str_36(36), "10");
        assert_eq!(num_to_str_36(37), "11");
        assert_eq!(num_to_str_36(72), "20");
        assert_eq!(num_to_str_36(400000), "8kn4");
    }
}
