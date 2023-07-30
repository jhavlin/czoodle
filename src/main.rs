extern crate actix_files;
extern crate actix_web;
extern crate chrono;
extern crate serde;
extern crate serde_json;
extern crate sha2;

mod common;
mod key_utils;
mod v01;

use actix_web::{App, HttpServer, Result};
use std::env;

#[actix_web::main]
async fn main() -> Result<(), std::io::Error> {
    let host = env::var("CZOODLE_HOST").unwrap_or("127.0.0.1".to_string());
    let port = env::var("CZOODLE_PORT").unwrap_or("8088".to_string());
    let path = env::current_dir().expect("Cannot read current working directory.");
    println!(
        "Starting Czoodle server at working directory {}",
        path.display()
    );

    let app = || {
        let static_files_handler = actix_files::Files::new("/", "./static")
            .show_files_listing()
            .index_file("index.html");
        App::new()
            .service(v01::scope())
            .service(static_files_handler)
    };
    HttpServer::new(app)
        .bind(host + ":" + &port)?
        .workers(1)
        .run()
        .await
}
