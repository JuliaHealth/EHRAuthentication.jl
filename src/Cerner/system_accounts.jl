Base.@kwdef struct CernerConfig
    base_url::String
    headers::Dict{String, String} = Dict{String, String}()
    scope::String = "grant_type=client_credentials&scope=system%2FObservation.read%20system%2FPatient.read"
    system_account_client_id::String
    system_account_client_secret::String
end

Base.@kwdef struct CernerSystemAccountAuthResult
    token::String
    token_dict::Dict{Symbol, Any}
    endpoints::Dict{String, String}
end

function authenticate_fhir_cerner(config::CernerConfig)
    base_url                     = config.base_url
    headers                      = config.headers
    scope                        = config.scope
    system_account_client_id     = config.system_account_client_id
    system_account_client_secret = config.system_account_client_secret

    metadata_url = base_url * "/metadata"
    metadata_response = HTTP.request(
        "GET",
        metadata_url,
        ["Accept" => "application/json"],
    )
    metadata_response_body = JSON3.read(String(metadata_response.body))
    endpoint_list = metadata_response_body.rest[1].security.extension[1].extension # TODO: loop over all
    endpoints = Dict{String, String}()
    for k in endpoint_list
        url = k["url"]
        new_value = k.valueUri
        if haskey(endpoints, url)
            msg = "Duplicate keys found for url $(url)"
            old_value = endpoints[url]
            @error msg url old_value new_value
            throw(ErrorException(msg))
        end
        endpoints[url] = new_value
    end
    endpoints["authorize"]
    endpoints["token"]
    @info "The authorize endpoint is: $(endpoints["authorize"])"
    @info "The token endpoint is: $(endpoints["token"])"

    base64encoded_client_id_secret = Base64.base64encode(system_account_client_id * ":" * system_account_client_secret)
    current_headers = [
        "Accept"        => "application/json",
        "Authorization" => "Basic $(base64encoded_client_id_secret)",
        "Content-Type"  => "application/x-www-form-urlencoded",
        "cache-control" => "no-cache",
    ]
    for (k, v) in headers
        current_headers[k] = v
    end
    token_response = HTTP.request("POST",
        endpoints["token"],
        current_headers,
        scope,
    )
    token_response_body = JSON3.read(String(token_response.body))
    token_dict = copy(token_response_body)
    token = token_dict[:access_token]
    result = CernerSystemAccountAuthResult(; token, token_dict, endpoints)
    return result
end
    
