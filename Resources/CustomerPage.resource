*** Settings ***
Resource    ../Resources/App.resource
Variables    ../Variables/customerpage.py

*** Variables ***
${SPACE}    

*** Keywords ***
Go To Customers Page
    [Documentation]    Navigate to the customers page and wait until the customer table is visible

    Click Element     ${nav_btn_customers}
    Wait Until Element Is Visible    //table//tbody//tr

Create User
    [Documentation]    Create a new customer using the provided customer dictionary.

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
    [Documentation]    Creation of First Five customers and verify each information. Then Check the display on table.

    ${customers}    Get Random Users
    FOR    ${customer}    IN    @{customers}[:5]
        Go To Customers Page
        Create User    ${customer}
        Verify Customer Details Match    ${customer}
    END
    Verify Customers Are Added

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

Verify Customers Are Added
    [Arguments]    @{customers}
    Go To Customers Page
    Refresh Current Page

    @{expected_names}    Create List
    FOR    ${customer}    IN    @{customers}
        ${full_name}    Set Variable    ${customer["name"].split(" ")[0]} ${customer["name"].split(" ")[1]}
        Append To List    ${expected_names}    ${full_name}
    END

    ${num_rows}    Get Length    ${expected_names}
    ${last_index}  Evaluate    ${num_rows} + 1

    @{fetched_names}    Create List
    FOR    ${i}    IN RANGE    1    ${last_index}
        ${fetched_name}    Get Text    ((${table_row})[${i}]//td)[2]
        IF    "\\n" in """${fetched_name}"""
            ${fetched_name}    Evaluate    """${fetched_name}""".replace("\\n","").strip()
        END
        Append To List    ${fetched_names}    ${fetched_name}
    END

    Lists Should Be Equal    ${expected_names}    ${fetched_names}

Update Last Five Customers
    [Documentation]    Update Customers' Information from 6 to 10
    ${customers}    Get Random Users
    FOR    ${index}    ${customer}    IN ENUMERATE    @{customers}[5:10]    start=6
        Go To Customers Page

        Click Element    (//table//tbody//tr)[${index}]//td[2]//a
        Wait Until Element Is Visible    ${customers_txt_firstname}
        
        ${first}    Evaluate    "${customer['name']}".split(" ")[0]
        ${last}     Evaluate    "${customer['name']}".split(" ")[1]

        # Change To CTRL+A for Windows, MAC COMMAND+A

        Press Keys    ${customers_txt_firstname}       CTRL+A    BACKSPACE
        Input Text    ${customers_txt_firstname}       ${first}

        Press Keys    ${customers_txt_lastname}        CTRL+A    BACKSPACE
        Input Text    ${customers_txt_lastname}        ${last}

        Press Keys    ${customers_txt_email}           CTRL+A    BACKSPACE
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
        Log To Console    ${SPACE}
        Log To Console    ========== USER ${index} ==========


        ${fetched_name}       Get Text    (${table_row})[${index}]//td[2][1]
        ${formatted_name}=    Run Keyword If    True    Evaluate    """'${fetched_name}'.replace('\n','').strip()"""

        ${last_seen}          Get Text    (${table_row})[${index}]//td[3]
        ${orders}             Get Text    (${table_row})[${index}]//td[4]
        ${total_spent}        Get Text    (${table_row})[${index}]//td[5]
        ${latest_purchase}    Get Text    (${table_row})[${index}]//td[6]
        ${newsletter}         Get Element Attribute    (${table_row})[${index}]//td[7]/span/*[local-name()="svg"]   aria-label
        ${segments}           Get Text    (${table_row})[${index}]//td[8]
        ${formatted_segments}=   Evaluate    """${segments}""".replace("\\n", ", ") if """${segments}""".strip() else "N/A"

        ${latest_purchase}    Run Keyword If    '${latest_purchase}' == ''    Set Variable    N/A    ELSE    Set Variable    ${latest_purchase}

        IF    "\\n" in """${fetched_name}"""
            ${fetched_name}    Evaluate    """${fetched_name}""".replace("\\n","")[1:]
        END

        Log To Console    Name : ${fetched_name}
        Log To Console    Last Seen : ${last_seen}
        Log To Console    Orders : ${orders}
        Log To Console    Total Spent : ${total_spent}
        Log To Console    Latest Purchase : ${latest_purchase}
        Log To Console    Newsletter : ${newsletter}
        Log To Console    Segments : ${formatted_segments}
        Log To Console    ${SPACE}
    END


Analyze User Spending
    [Arguments]    ${end}
    Go To Customers Page
    Log To Console    \n
    Fetch Spent Details    ${end}
   
Fetch Spent Details
    [Arguments]    ${end}
    ${counter}    Set Variable    1
    ${users_total}    Set Variable    0

    FOR    ${i}    IN RANGE    1    ${end}
        ${fetched_name}               Get Text    ((${table_row})[${i}]//td)[2]
        ${total_spent}        Get Text    ((${table_row})[${i}]//td)[5]

        ${formatted_name}=    Run Keyword If    True    Evaluate    """${fetched_name}"""
        ${clean_amount}    Evaluate    """${total_spent}""".replace("$", "").replace(",", "")
        
        IF    "${clean_amount}" != "0.00"
            ${users_total}    Evaluate    ${users_total} + float("${clean_amount}")
            Log To Console    ${counter}. ${formatted_name}: ${total_spent}
            ${counter}    Evaluate    ${counter} + 1
        END
    END
    
    ${formatted_total}    Evaluate    "{:.2f}".format(${users_total})
    Log To Console    \n=======================================
    Log To Console    Total Customer Spending: $${formatted_total}
    Log To Console    =======================================
    Verify Spent Amount    ${formatted_total}


Verify Spent Amount
    [Arguments]    ${formatted_total}

    IF    ${formatted_total} < 3500    
         Log to Console    "FAIL: Total spending($${formatted_total}) is below minimum ($3,500)"
         Fail
    ELSE
        Log To Console    "PASS: Total spending ($${formatted_total}) meets minimum threshold ($3,500)"
    END