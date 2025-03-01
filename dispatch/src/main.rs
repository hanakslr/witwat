use actix_cors::Cors;
use actix_web::{get, App, HttpResponse, HttpServer, Responder};
use serde::Serialize;

#[derive(Serialize)]
pub struct LatLon {
    pub lat: f64,
    pub lon: f64,
}

#[derive(Serialize)]
pub struct Segment {
    pub id: i32,
    pub start: LatLon,
    pub end: LatLon,
}

#[get("/")]
async fn hello() -> impl Responder {
    HttpResponse::Ok().body("Hello world!")
}

#[get("/railways")]
async fn railways() -> impl Responder {
    let s = vec![
        Segment {
            id: 1,
            start: LatLon {
                lat: 44.385359,
                lon: -73.979919,
            },
            end: LatLon {
                lat: 41.308550,
                lon: -73.829527,
            },
        },
        Segment {
            id: 2,
            end: LatLon {
                lat: 38.155868,
                lon: -99.139451,
            },

            start: LatLon {
                lat: 41.308550,
                lon: -73.829527,
            },
        },
    ];

    HttpResponse::Ok().json(s)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    println!("Starting server at http://0.0.0.0:8080");
    HttpServer::new(|| {
        let cors = Cors::default().allowed_origin("http://localhost:5173");

        App::new().wrap(cors).service(hello).service(railways)
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}
