extern crate wapc_guest as guest;
use guest::prelude::*;

use k8s_openapi::api::core::v1 as apicore;

extern crate kubewarden_policy_sdk as kubewarden;
use kubewarden::{protocol_version_guest, request::ValidationRequest, validate_settings};

mod settings;
use settings::Settings;

#[no_mangle]
pub extern "C" fn wapc_init() {
    register_function("validate", validate);
    register_function("validate_settings", validate_settings::<Settings>);
    register_function("protocol_version", protocol_version_guest);
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

#[cfg(test)]
mod tests {
    use super::*;

    use kubewarden_policy_sdk::test::Testcase;

    #[test]
    fn accept_pod_with_valid_name() -> Result<(), ()> {
        let request_file = "test_data/pod_creation.json";
        let tc = Testcase {
            name: String::from("Valid name"),
            fixture_file: String::from(request_file),
            expected_validation_result: true,
            settings: Settings {},
        };

        let res = tc.eval(validate).unwrap();
        assert!(
            res.mutated_object.is_none(),
            "Something mutated with test case: {}",
            tc.name,
        );

        Ok(())
    }

    #[test]
    fn reject_pod_with_invalid_name() -> Result<(), ()> {
        let request_file = "test_data/pod_creation_invalid_name.json";
        let tc = Testcase {
            name: String::from("Bad name"),
            fixture_file: String::from(request_file),
            expected_validation_result: false,
            settings: Settings {},
        };

        let res = tc.eval(validate).unwrap();
        assert!(
            res.mutated_object.is_none(),
            "Something mutated with test case: {}",
            tc.name,
        );

        Ok(())
    }

    #[test]
    fn accept_request_with_non_pod_resource() -> Result<(), ()> {
        let request_file = "test_data/ingress_creation.json";
        let tc = Testcase {
            name: String::from("Ingress creation"),
            fixture_file: String::from(request_file),
            expected_validation_result: true,
            settings: Settings {},
        };

        let res = tc.eval(validate).unwrap();
        assert!(
            res.mutated_object.is_none(),
            "Something mutated with test case: {}",
            tc.name,
        );

        Ok(())
    }
}
