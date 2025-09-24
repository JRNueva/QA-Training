*** Settings ***
Library    SeleniumLibrary
Variables    ../Variables/variables.py
Library    ../Library/CustomLibrary.py
Library   Collections

*** Keywords ***
Refresh Current Page
    Click Button    ${btn_refresh}
    Wait Until Element Is Visible    ${loading_icon}   
    Wait Until Element Is Not Visible    ${loading_icon}    