use serde::Deserialize;

// Describe what settings can your policy be provided when
// loaded by the policy server.
#[derive(Deserialize, Default, Debug)]
pub(crate) struct Settings {}
