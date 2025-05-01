use crate::common::{
    self, CreateInputData, CreateOutputData, GetOutputData, RequestProjectKeyOutputData,
    UpdateInputData, UpdateOutputData,
};
use actix_web::{web, web::Json, Result, Scope};

const VERSION: &'static str = "v02";

pub fn scope() -> Scope {
    web::scope("/data/v02")
        .route("/requestProjectKey", web::get().to(request_project_key)) // <- use `with` extractor)
        .route("/create", web::post().to(create)) // <- use `with` extractor)
        .route("/get/{project_key}", web::get().to(get))
        .route("/update", web::post().to(update))
}

async fn request_project_key() -> Result<Json<RequestProjectKeyOutputData>> {
    common::request_project_key(VERSION).await
}

async fn create(info: Json<CreateInputData>) -> Result<Json<CreateOutputData>> {
    common::create(info, VERSION).await
}

pub async fn update(input: Json<UpdateInputData>) -> Result<Json<UpdateOutputData>> {
    common::update(input, VERSION).await
}

pub async fn get(project_key: web::Path<String>) -> Result<Json<GetOutputData>> {
    common::get(project_key, VERSION).await
}
