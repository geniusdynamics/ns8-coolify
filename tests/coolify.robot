*** Settings ***
Library    SSHLibrary

*** Variables ***
${HOST}    coolify.example.org

*** Keywords ***
Coolify answers through Traefik
    ${code} =    Execute Command    curl -k -s -o /dev/null -w '\%{http_code}' --max-time 30 --resolve ${HOST}:443:127.0.0.1 https://${HOST}/
    Should Match Regexp    ${code}    ^(2[0-9][0-9]|3[0-9][0-9]|401|403)$

Realtime server answers
    # Coolify 4.4+ runs Reverb in the coolify-app container, on port 6001
    ${rc} =    Execute Command    runagent -m ${module_id} podman exec coolify-app curl -fsS -o /dev/null http://127.0.0.1:6001/up
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

*** Test Cases ***
Check if coolify is installed correctly
    ${output}  ${rc} =    Execute Command    add-module ${IMAGE_URL} 1
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    &{output} =    Evaluate    ${output}
    Set Suite Variable    ${module_id}    ${output.module_id}

Check if coolify can be configured
    ${rc} =    Execute Command    api-cli run module/${module_id}/configure-module --data '{"host":"${HOST}","http2https":true,"lets_encrypt":false,"ssh_host_key_checking":"enforce"}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Check if the configuration is read back
    ${output}  ${rc} =    Execute Command    api-cli run module/${module_id}/get-configuration
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    &{config} =    Evaluate    json.loads('''${output}''')    modules=json
    Should Be Equal    ${config.host}    ${HOST}
    Should Be True    ${config.http2https}
    Should Not Be True    ${config.lets_encrypt}
    Should Be Equal    ${config.ssh_host_key_checking}    enforce

Check if the secrets are private
    ${output}  ${rc} =    Execute Command    runagent -m ${module_id} stat -c '\%a \%n' coolify-db.env database.env redis.env
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    Should Be Equal    ${output}    600 coolify-db.env\n600 database.env\n600 redis.env
    ${output} =    Execute Command    runagent -m ${module_id} cat coolify.env
    Should Contain    ${output}    SSH_HOST_KEY_CHECKING=enforce
    Should Not Contain    ${output}    PASSWORD

Check if coolify works as expected
    Wait Until Keyword Succeeds    15 min    15 sec    Coolify answers through Traefik

Check if the realtime server works
    Wait Until Keyword Succeeds    5 min    10 sec    Realtime server answers
    ${output} =    Execute Command    runagent -m ${module_id} podman ps --format '{{.Names}}'
    Should Not Contain    ${output}    soketi-app

Check if coolify is removed correctly
    ${rc} =    Execute Command    remove-module --no-preserve ${module_id}
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0
