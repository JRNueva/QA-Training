*** Settings ***
Resource    ../Resources/App.resource
Resource    ../Resources/CustomerPage.resource

Suite Setup    Launch And Login
Suite Teardown    Close Browser

*** Variables ***
${URL}    https://marmelab.com/react-admin-demo
${USERNAME}    demo
${PASSWORD}    demo

*** Test Cases ***
TEST-000001
    Add And Verify First Five Customers

TEST-000002
    Update Last Five Customers

TEST-000003
    Log All Customer Table Data
    
TEST-000004
    Log Customers With Spending



*** Keywords ***
Launch Browser
    [Arguments]    ${url}    ${element_to_wait}
    Open Browser    ${url}    chrome    options=add_argument("--start-maximized")
    Wait Until Element Is Visible    ${element_to_wait}    timeout=20s

Login User
    [Arguments]    ${username}    ${password}
    Input Text    ${login_txt_username}    ${username}
    Input Text    ${login_txt_password}    ${password}
    Capture Page Screenshot
    Click Button   ${login_btn_submit}
    Wait Until Element Is Visible    ${dashboard_hdr}    error=Dashboard not found. Login Failed
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible    ${dashboard_hdr}
    IF    ${status}
        Log To Console    LOGIN SUCCESSFUL
    ELSE
        Log To Console    LOGIN FAILED
    END
    Sleep    3s

Launch And Login
    Launch Browser    ${URL}    ${login_txt_username}
    Login User    ${USERNAME}    ${PASSWORD}

