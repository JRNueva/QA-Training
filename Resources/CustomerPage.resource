*** Settings ***
Resource    ../Resources/App.resource
Variables    ../Variables/customerpage.py
# 

*** Variables ***
${SPACE}    

*** Keywords ***
Go To Customers Page
    Click Element     ${nav_btn_customers}
    Wait Until Element Is Visible    //table//tbody//tr

Create User
    [Arguments]    ${customer}
    Click Element    ${customers_btn_create}
    Wait Until Element Is Visible    ${customers_txt_firstname}

    ${first}    Evaluate    "${customer['name']}".split(" ")[0]
    ${last}     Evaluate    "${customer['name']}".split(" ")[1]

    Input Text    ${customers_txt_firstname}    ${first}
    Input Text    ${customers_txt_lastname}     ${last}
    Input Text    ${customers_txt_email}        ${customer["email"]}
    Input Text    ${customers_txt_birthday}    ${customer["birthday"]}
    Input Text    ${customers_txt_address}     ${customer["address"]["street"]} ${customer["address"]["suite"]}
    Input Text    ${customers_txt_city}        ${customer["address"]["city"]}
    Input Text    ${customers_txt_stateAbbr}  ${customer["stateAbbr"]}
    Input Text    ${customers_txt_zipcode}     ${customer["address"]["zipcode"]}
    Input Text    ${customers_txt_password}    ${customer["password"]}
    Input Text    ${customers_txt_confirm_password}    ${customer["password"]}

    Click Button    ${customers_btn_save}
    Wait Until Page Contains    Customer created

Add And Verify First Five Customers
    ${customers}    Get Random Users
    FOR    ${customer}    IN    @{customers}[:5]
        Go To Customers Page
        Create User    ${customer}
        Verify Customer Details Match    ${customer}
        Verify Customer Is Added        ${customer}
    END

Verify Customer Details Match
    [Arguments]    ${customer}

    Go To Customers Page 
    Refresh Current Page 
    Click Element    //a[.//div[contains(normalize-space(.),"${customer["name"]}")]] 
    Wait Until Element Is Visible    ${customers_txt_firstname}

    ${first}    Evaluate    "${customer['name']}".split(" ")[0]
    ${last}     Evaluate    "${customer['name']}".split(" ")[1]
    ${birthday}    Reformat Birthday    ${customer["birthday"]}
    
    ${firstname}    Get Element Attribute    ${customers_txt_firstname}    value
    Should Be Equal As Strings    ${firstname}    ${first}

    ${lastname}     Get Element Attribute    ${customers_txt_lastname}    value
    Should Be Equal As Strings    ${lastname}    ${last}

    ${email}        Get Element Attribute    ${customers_txt_email}    value
    Should Be Equal As Strings    ${email}    ${customer["email"]}

    ${bday}         Get Element Attribute    ${customers_txt_birthday}    value
    Should Be Equal As Strings    ${bday}    ${birthday}

    ${address}      Get Element Attribute    ${customers_txt_address}    value
    Should Be Equal As Strings    ${address}    ${customer["address"]["street"]} ${customer["address"]["suite"]}

    ${city}         Get Element Attribute    ${customers_txt_city}    value
    Should Be Equal As Strings    ${city}    ${customer["address"]["city"]}

    ${state}        Get Element Attribute    ${customers_txt_stateAbbr}    value
    Should Be Equal As Strings    ${state}    ${customer["stateAbbr"]}

    ${zipcode}      Get Element Attribute    ${customers_txt_zipcode}    value
    Should Be Equal As Strings    ${zipcode}    ${customer["address"]["zipcode"]}

    ${password}     Get Element Attribute    ${customers_txt_password}    value
    Should Be Equal As Strings    ${password}    ${customer["password"]}

Verify Customer Is Added
    [Arguments]    ${customer}
    Go To Customers Page
    Refresh Current Page
    ${fetched_name}    Get Text    ((${table_row})[1]//td)[2]     
    IF    "\\n" in """${fetched_name}"""
        ${fetched_name}    Evaluate    """${fetched_name}""".replace("\\n","")[1:]
    END
    Should Be Equal As Strings    ${customer["name"].split(" ")[0]} ${customer["name"].split(" ")[1]}    ${fetched_name} 

# 

Update Last Five Customers
    ${customers}    Get Random Users
    FOR    ${index}    ${customer}    IN ENUMERATE    @{customers}[5:10]    start=6
        Go To Customers Page

        Click Element    (//table//tbody//tr)[${index}]//td[2]//a
        Wait Until Element Is Visible    ${customers_txt_firstname}

        ${first}    Evaluate    "${customer['name']}".split(" ")[0]
        ${last}     Evaluate    "${customer['name']}".split(" ")[1]

        # Change To CTRL+A for Windows

        Press Keys    ${customers_txt_firstname}       COMMAND+A    BACKSPACE
        Input Text    ${customers_txt_firstname}       ${first}

        Press Keys    ${customers_txt_lastname}        COMMAND+A    BACKSPACE
        Input Text    ${customers_txt_lastname}        ${last}

        Press Keys    ${customers_txt_email}           COMMAND+A    BACKSPACE
        Input Text    ${customers_txt_email}           ${customer["email"]}

        Input Text      ${customers_txt_birthday}    ${customer["birthday"]}
        Input Text    ${customers_txt_address}         ${customer["address"]["street"]} ${customer["address"]["suite"]}
        Input Text    ${customers_txt_city}            ${customer["address"]["city"]}
        Input Text    ${customers_txt_stateAbbr}      ${customer["stateAbbr"]}
        Input Text    ${customers_txt_zipcode}        ${customer["address"]["zipcode"]}
        Input Text    ${customers_txt_password}       ${customer["password"]}
        Input Text    ${customers_txt_confirm_password}     ${customer["password"]}

        Click Button    ${customers_btn_save}
        Wait Until Page Contains    Customer updated
    END

Log All Customer Table Data
    Go To Customers Page
    Wait Until Element Is Visible    ${table_row}

    ${row_count}    Get Element Count    ${table_row}
    FOR    ${index}    IN RANGE    1    ${row_count + 1}
        Log To Console    ========== USER ${index} ==========

        ${fetched_name}       Get Text    (${table_row})[${index}]//td[2][1]
        ${last_seen}          Get Text    (${table_row})[${index}]//td[3]
        ${orders}             Get Text    (${table_row})[${index}]//td[4]
        ${total_spent}        Get Text    (${table_row})[${index}]//td[5]
        ${latest_purchase}    Get Text    (${table_row})[${index}]//td[6]
        ${newsletter}         Get Element Attribute    (${table_row})[${index}]//td[7]   aria-label
        ${segments}           Get Text    (${table_row})[${index}]//td[8]//div
   
        ${latest_purchase}    Run Keyword If    '${latest_purchase}' == ''    Set Variable    N/A    ELSE    Set Variable    ${latest_purchase}
        ${segment_element}    Run Keyword And Ignore Error    Get WebElement    (${table_row})[${index}]//td[8]//span
        ${segments}           Run Keyword If    '${segment_element[0]}' == 'FAIL'    Set Variable    N/A    ELSE    Get Text    ${segment_element[1]}

        IF    "\\n" in """${fetched_name}"""
            ${fetched_name}    Evaluate    """${fetched_name}""".replace("\\n","")[1:]
        END

        Log To Console    Name : ${fetched_name}
        Log To Console    Last Seen : ${last_seen}
        Log To Console    Orders : ${orders}
        Log To Console    Total Spent : ${total_spent}
        Log To Console    Latest Purchase : ${latest_purchase}
        Log To Console    Newsletter : ${newsletter}
        Log To Console    Segments : ${segments}
        Log To Console    ${SPACE}
    END

Log Customers With Spending
    Go To Customers Page
    Wait Until Element Is Visible    ${table_row}

    ${row_count}=    Get Element Count    ${table_row}
    ${users_with_spending}=    Create List

    FOR    ${index}    IN RANGE    1    ${row_count + 1}
        ${fetched_name}=    Get Text    (${table_row})[${index}]//td[2][1]
        ${total_spent_text}=    Get Text    (${table_row})[${index}]//td[5]
        ${amount}=    Parse Total Spent    ${total_spent_text}

        ${user_dict}=    Evaluate    {'name': '${fetched_name}', 'spent': '${amount}'}

        Run Keyword If    ${amount} > 0    Append To List    ${users_with_spending}    ${user_dict}

    END

    ${counter}=    Set Variable    1
   
    FOR    ${user}    IN    @{users_with_spending}
        ${name}=    Get From Dictionary    ${user}    name
        ${spent}=   Get From Dictionary    ${user}    spent
        Log To Console    ${counter}. ${name}: $${spent:,.0f}
        ${counter}=    Evaluate    ${counter} + 1
    END

    RETURN    ${users_with_spending}