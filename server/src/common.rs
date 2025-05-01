use crate::key_utils;
use actix_web::{web, web::Json, Result};
use chrono::prelude::*;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::fs::File;
use std::io::prelude::*;
use std::path::PathBuf;

const REQUIRED_HASH_PREFIX: &'static str = "777"; // todo make configurable

#[derive(Serialize, Deserialize)]
pub struct PersistedDataV1 {
    encrypted_data: String,
    iv: String,
    evidence: String,
    version: u32,
}

#[derive(Serialize)]
pub struct RequestProjectKeyOutputData {
    #[serde(rename = "projectKey")]
    project_key: String,
    #[serde(rename = "requiredHashPrefix")]
    required_hash_prefix: String,
}

#[derive(Deserialize, Debug)]
pub struct CreateInputData {
    #[serde(rename = "encryptedData")]
    encrypted_data: String,
    iv: String,
    evidence: String,
    #[serde(rename = "projectKey")]
    project_key: String,
    #[serde(rename = "keyVerification")]
    key_verification: String,
}

#[derive(Serialize)]
pub struct CreateOutputData {
    result: String,
    #[serde(rename = "projectKey")]
    project_key: String,
}

#[derive(Serialize)]
pub struct GetOutputData {
    success: bool,
    #[serde(rename = "encryptedData")]
    encrypted_data: Option<String>,
    iv: Option<String>,
    version: Option<u32>,
}

#[derive(Deserialize)]
pub struct UpdateInputData {
    #[serde(rename = "projectKey")]
    project_key: String,
    evidence: String,
    #[serde(rename = "encryptedData")]
    encrypted_data: String,
    iv: String,
    #[serde(rename = "previousVersion")]
    previous_version: u32,
}

#[derive(Serialize)]
pub struct UpdateOutputData {
    success: bool,
    #[serde(rename = "encryptedData")]
    encrypted_data: Option<String>,
    iv: Option<String>,
    version: Option<u32>,
    error: Option<String>,
}

pub struct NextKeyInfo {
    next: u32,
    key: String,
    path_str: String,
}

fn next_key_info(version: &str) -> NextKeyInfo {
    let today = Local::now();
    let year = today.year();
    let month = today.month();
    let day = today.day();
    let path_str = format!("./data/{}/{}/{:02}/{:02}", version, year, month, day);
    let path = PathBuf::from(&path_str);
    std::fs::create_dir_all(&path).expect("Cannot create directory");
    let dir_contents = std::fs::read_dir(&path);

    let next: u32 = dir_contents
        .expect("Cannot read directory")
        .into_iter()
        .map(|e| {
            e.unwrap()
                .path()
                .file_stem()
                .unwrap()
                .to_str()
                .unwrap()
                .to_owned()
        })
        .map(|n| u32::from_str_radix(&n, 10).unwrap())
        .max()
        .map(|max| max + 1)
        .unwrap_or(0);

    let key = key_utils::get_project_key(year, month, day, next);
    return NextKeyInfo {
        next,
        key,
        path_str,
    };
}

fn sha256(str: &str) -> String {
    let mut hasher = Sha256::new();
    // write input message
    hasher.update(str.as_bytes());
    // read hash digest and consume hash helper
    let result = hasher.finalize();
    let strings: Vec<String> = result.iter().map(|b| format!("{:02x}", b)).collect();
    strings.join("")
}

pub async fn request_project_key(version: &str) -> Result<Json<RequestProjectKeyOutputData>> {
    let NextKeyInfo {
        next: _,
        key,
        path_str: _,
    } = next_key_info(version);
    Ok(Json(RequestProjectKeyOutputData {
        project_key: key,
        required_hash_prefix: REQUIRED_HASH_PREFIX.to_string(),
    }))
}

pub async fn create(info: Json<CreateInputData>, version: &str) -> Result<Json<CreateOutputData>> {
    let NextKeyInfo {
        next,
        key,
        path_str,
    } = next_key_info(version);
    if key != info.project_key {
        return Ok(Json(CreateOutputData {
            result: "key_used".to_string(),
            project_key: key,
        }));
    }
    if !sha256(&format!("{}{}", info.project_key, info.key_verification))
        .starts_with(REQUIRED_HASH_PREFIX)
    {
        return Ok(Json(CreateOutputData {
            result: "verification_failed".to_string(),
            project_key: "".to_string(),
        }));
    }

    let mut file = File::create(format!("{}/{}.dat", path_str, next)).expect("Cannot create file");
    let persisted_data = PersistedDataV1 {
        encrypted_data: info.encrypted_data.to_owned(),
        iv: info.iv.to_owned(),
        evidence: info.evidence.to_owned(),
        version: 1,
    };
    let store_str = serde_json::to_string(&persisted_data).unwrap();
    file.write_all(store_str.as_bytes())
        .expect("Unable to write to file");
    Ok(Json(CreateOutputData {
        result: "created".to_string(),
        project_key: key,
    }))
}

pub async fn update(input: Json<UpdateInputData>, version: &str) -> Result<Json<UpdateOutputData>> {
    let path = key_utils::key_to_path(&input.project_key);
    let path = format!("./data/{}/{}", version, path);
    let data = std::fs::read_to_string(&path).expect("Cannot read file");
    let data: PersistedDataV1 = serde_json::from_str(&data).unwrap();
    if data.evidence != input.evidence {
        return Ok(Json(UpdateOutputData {
            success: false,
            error: Some(String::from("Invalid evidence")),
            encrypted_data: None,
            iv: None,
            version: None,
        }));
    } else if input.previous_version != data.version {
        return Ok(Json(UpdateOutputData {
            success: false,
            error: None,
            encrypted_data: Some(data.encrypted_data),
            iv: Some(data.iv),
            version: Some(data.version),
        }));
    } else {
        let version = data.version + 1;
        let persisted_data = PersistedDataV1 {
            encrypted_data: input.encrypted_data.to_owned(),
            iv: input.iv.to_owned(),
            evidence: data.evidence.to_owned(),
            version,
        };
        let store_str = serde_json::to_string(&persisted_data).unwrap();
        std::fs::write(&path, store_str.as_bytes()).expect("Unable to write to file");
        Ok(Json(UpdateOutputData {
            success: true,
            error: None,
            encrypted_data: None,
            iv: None,
            version: Some(version),
        }))
    }
}

pub async fn get(project_key: web::Path<String>, version: &str) -> Result<Json<GetOutputData>> {
    let path = key_utils::key_to_path(&project_key);
    let path = format!("./data/{}/{}", version, path);
    let data = std::fs::read_to_string(&path).expect("Cannot read file");
    let data: PersistedDataV1 = serde_json::from_str(&data).unwrap();
    Ok(Json(GetOutputData {
        success: true,
        encrypted_data: Some(data.encrypted_data),
        iv: Some(data.iv),
        version: Some(data.version),
    }))
}
