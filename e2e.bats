#!/usr/bin/env bats

@test "Accept a valid name" {
	run kwctl run  --request-path test_data/pod_creation.json  annotated-policy.wasm

  # this prints the output when one the checks below fails
  echo "output = ${output}"

	[ "$status" -eq 0 ]
	[ $(expr "$output" : '.*"allowed":true.*') -ne 0 ]
}

@test "Accept requests involving a non-Pod resource" {
	run kwctl run  --request-path test_data/ingress_creation.json  annotated-policy.wasm

  # this prints the output when one the checks below fails
  echo "output = ${output}"

	[ "$status" -eq 0 ]
	[ $(expr "$output" : '.*"allowed":true.*') -ne 0 ]
}

@test "Reject invalid name" {
	run kwctl run  --request-path test_data/pod_creation_invalid_name.json annotated-policy.wasm

  # this prints the output when one the checks below fails
  echo "output = ${output}"

	[ "$status" -eq 0 ]
	[ $(expr "$output" : '.*"allowed":false.*') -ne 0 ]
	[ $(expr "$output" : '.*"message":"pod name invalid-pod-name is not accepted".*') -ne 0 ]
}
