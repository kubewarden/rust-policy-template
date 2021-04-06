extern crate wapc_guest as guest;
use guest::prelude::*;

use k8s_openapi::api::core::v1 as apicore;

extern crate kubewarden_policy_sdk as kubewarden;
use kubewarden::request::ValidationRequest;

mod settings;
use settings::Settings;

#[no_mangle]
pub extern "C" fn wapc_init() {
    register_function("validate", validate);
}

fn validate(payload: &[u8]) -> CallResult {
    let validation_request: ValidationRequest<Settings> = ValidationRequest::new(payload)?;

    // TODO: you can unmarshal any Kubernetes API type you are interested in
    match serde_json::from_value::<apicore::Pod>(validation_request.request.object) {
        Ok(pod) => {
            // TODO: your logic goes here
            if pod.metadata.name == Some("invalid-pod-name".to_string()) {
                kubewarden::reject_request(
                    Some(format!("pod name {:?} is not accepted", pod.metadata.name)),
                    None,
                )
            } else {
                kubewarden::accept_request()
            }
        }
        Err(_) => {
            // TODO: handle as you wish
            // We were forwarded a request we cannot unmarshal or
            // understand, just accept it
            kubewarden::accept_request()
        }
    }
}
