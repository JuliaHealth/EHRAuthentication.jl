function authenticate_fhir_cerner(METADATA_URL, SYSTEM_ACCOUNT_CLIENT_ID, SYSTEM_ACCOUNT_CLIENT_SECRET)
    response = HTTP.request("GET", METADATA_URL*"?", ["Accept" => "application/json"])
    response_body = JSON3.read(String(response.body))
    ENDPOINT_LIST = response_body.rest[1].security.extension[1].extension
    local AUTHORIZE_ENDPOINT, TOKEN_ENDPOINT
    for k in ENDPOINT_LIST
        if k["url"] == "authorize"
            AUTHORIZE_ENDPOINT = k.valueUri
        end
        if k["url"] == "token"
            TOKEN_ENDPOINT = k.valueUri
        end
    end
    println("The authorize endpoint is: $AUTHORIZE_ENDPOINT")
    println("The token endpoint is: $TOKEN_ENDPOINT")

    base64encoded_client_id_secret = Base64.base64encode(SYSTEM_ACCOUNT_CLIENT_ID*":"*SYSTEM_ACCOUNT_CLIENT_SECRET)
    HTTP.request("POST"
        , TOKEN_ENDPOINT
        , ["Accept" => "application/json", "Authorization: Basic $base64encoded_client_id_secret", "Content-Type" => "application/x-www-form-urlencoded", "cache-control" => "no-cache"]
        , "grant_type=client_credentials&scope=system%2FObservation.read%20system%2FPatient.read"
    )
end
