*** Settings ***
Library    Selenium2Screenshots
Library    String
Library    DateTime
Library    torgua_service.py
Library    DebugLibrary

*** Variables ***
${locator.tenderId}                                    xpath=//td[./text()='TenderID']//following-sibling::td[1]
${locator.title}                                         xpath=//div[@class = 'col-md-9']//h1
${locator.description}                             xpath=//div[@class = 'col-md-9']//h4
${locator.auctionUrl}                                xpath=//div[@class='btn-defauld-torg tender']//a

${locator.value.amount}                                 xpath=//span[@class = 'value_amount']
${locator.value.currency}                             xpath=//span[@class = 'value_curency']
${locator.value.valueAddedTaxIncluded}    xpath=//span[@class = 'value_tax']

${locator.minimalStep.amount}                xpath=//*[@class='ms_amount']
${locator.minimalStep.currency}                xpath=//*[@class='ms_currency']

${locator.tenderPeriod.startDate}                xpath=//*[@id='tenderPeriod_startDate']
${locator.enquiryPeriod.startDate}         xpath=//td[./text()='Дата початку періоду обговорень']//following-sibling::td[1]
${locator.enquiryPeriod.endDate}         xpath=//td[./text()='Завершення періоду обговорення']//following-sibling::td[1]
${locator.auctionPeriod.startDate}         xpath=//td[text()='Дата та час аукціону/редукціону']//following-sibling::td[1]
${locator.auctionPeriod.endDate}         xpath=//td[./text()='Кінець аукціону']//following-sibling::td[1]
${locator.tenderPeriod.endDate}            xpath=//td[./text()='Завершення періоду прийому пропозицій']//following-sibling::td[1]
${locator.items[0].deliveryDate.startDate}            xpath=//td[./text()='Почткова дата поставки']//following-sibling::td[1]
${locator.items[0].deliveryDate.endDate}            xpath=//td[./text()='Кінцева дата поставки']//following-sibling::td[1]
${locator.items[0].description}        xpath=//table[@class = 'tender_item_table']//tbody//tr[1]//td[2]
${locator.items[0].classification.scheme}        CPV
${locator.items[0].classification.id}                xpath=//*[@class='c_id']
${locator.items[0].classification.description}             xpath=//*[@class='c_desc']
${locator.items[0].additionalClassifications[0].scheme}     xpath=//*[@class='ac_s']
${locator.items[0].additionalClassifications[0].id}             xpath=//*[@class='ac_id']
${locator.items[0].additionalClassifications[0].description}             xpath=//*[@class='ac_desc']

${locator.items[0].deliveryLocation.latitude}                 xpath=//*[@class='dl_latitude']
${locator.items[0].deliveryLocation.longitude}                xpath=//*[@class='dl_longitude']

${locator.items[0].deliveryAddress.countryName}        xpath=//*[@class='da_countryName']
${locator.items[0].deliveryAddress.region}                xpath=//*[@class='da_region']
${locator.items[0].deliveryAddress.locality}                xpath=//*[@class='da_locality']
${locator.items[0].deliveryAddress.postalCode}                xpath=//*[@class='da_postalCode']
${locator.items[0].deliveryAddress.streetAddress}                xpath=//*[@class='da_streetAddress']

${locator.procuringEntity.name}                 xpath=//*[text()='ОРГАНІЗАТОР ЗАКУПІВЛІ']/following-sibling::*[1]//*[2]//*[2]

${locator.items[0].quantity}                 xpath=//td[./text()='Кількість']/following-sibling::td[1]
${locator.items[0].unit.code}                xpath=//*[@class='item_utit_code']
${locator.items[0].unit.name}                xpath=//*[@class='item_unit_name']
${locator.questions[0].title}                xpath = //*[@class='question-title-tender']
${locator.questions[0].description}    xpath = //*[@class='question-description-tender']
${locator.questions[0].date}                 xpath = //*[@class='date-comment']
${locator.questions[0].answer}             xpath=//*[@class='well']

#${locator.awards[1].complaintPeriod.endDate}
${locator.document.title}             xpath=//*[@class='doc_title']
*** Keywords ***

Підготувати дані для оголошення тендера
    [Arguments]    @{ARGUMENTS}
    Log Many    @{ARGUMENTS}
    [return]    ${ARGUMENTS[1]}

Підготувати клієнт для користувача
    [Arguments]    @{ARGUMENTS}
    [Documentation]    Відкрити браузер, створити об’єкт api wrapper, тощо
    ...            ${ARGUMENTS[0]} ==    username
    Open Browser
    ...            ${USERS.users['${ARGUMENTS[0]}'].homepage}
    ...            ${USERS.users['${ARGUMENTS[0]}'].browser}
    ...            alias=${ARGUMENTS[0]}
    Set Window Size             @{USERS.users['${ARGUMENTS[0]}'].size}
    Set Window Position     @{USERS.users['${ARGUMENTS[0]}'].position}
    Click Element    xpath= //a[@class="log"]
    Wait Until Page Contains Element    id=content
    Input text    name=login    ${USERS.users['${ARGUMENTS[0]}'].login}
    Input text    name=password    ${USERS.users['${ARGUMENTS[0]}'].password}
    Click Element    name=send_auth

    Run Keyword And Ignore Error        Click Element    //*[text()='Ознайомлений']

Створити тендер
    [Arguments]    @{ARGUMENTS}
    [Documentation]
    ...            ${ARGUMENTS[0]} ==    username
    ...            ${ARGUMENTS[1]} ==    tender_data
    ${title}=                 Get From Dictionary     ${ARGUMENTS[1].data}                             title
    ${description}=     Get From Dictionary     ${ARGUMENTS[1].data}                             description
    ${procurementMethodType}=     Convert To String        belowThreshold


    ${value_amount}=                Get From Dictionary     ${ARGUMENTS[1].data.value}                 amount
    ${value_amount}=                            Format         ${value_amount}

    ${value_currency}=                Get From Dictionary     ${ARGUMENTS[1].data.value}                 currency
    ${minimalStep_amount}=         Get From Dictionary     ${ARGUMENTS[1].data.minimalStep}     amount
    ${minimalStep_amount}=         Convert To String         ${minimalStep_amount}

    #${minimalStep_currency}=         Get From Dictionary     ${ARGUMENTS[1].data.minimalStep}     currency
    ${items}=                 Get From Dictionary     ${ARGUMENTS[1].data}                             items
    ${items_description}=     Get From Dictionary     ${items[0]}                 description
    ${items_unit_quantity}=     Get From Dictionary     ${items[0]}                 quantity
    ${items_unit_code}=     Get From Dictionary     ${items[0].unit}                 code
    #Період поставки товару (початкова дата)
    #${items_items_deliveryDate_startDate}=     Get From Dictionary     ${items[0].unit}                 code
    #Період поставки товару (кінцева дата)
    ${items_items_deliveryDate_startDate}=     Get From Dictionary     ${items[0].deliveryDate}                 startDate
    ${items_items_deliveryDate_startDate}=                Convert Date To String     ${items_items_deliveryDate_startDate}
    
    ${items_items_deliveryDate_endDate}=     Get From Dictionary     ${items[0].deliveryDate}                 endDate
    ${items_items_deliveryDate_endDate}=                Convert Date To String     ${items_items_deliveryDate_endDate}

    ${items_deliveryAddress_postalCode}=     Get From Dictionary     ${items[0].deliveryAddress}                 postalCode
    ${items_deliveryAddress_countryName}=     Get From Dictionary     ${items[0].deliveryAddress}                 countryName
    ${items_deliveryAddress_region}=     Get From Dictionary     ${items[0].deliveryAddress}                 region
    ${items_deliveryAddress_locality}=     Get From Dictionary     ${items[0].deliveryAddress}                 locality
    ${items_deliveryAddress_streetAddress}=     Get From Dictionary     ${items[0].deliveryAddress}                 streetAddress
    
    ${items_deliveryLocation_latitude}=     Get From Dictionary     ${items[0].deliveryLocation}                 latitude
    ${items_deliveryLocation_latitude}=         Convert To Number         ${items_deliveryLocation_latitude}
    ${items_deliveryLocation_latitude}=         Format         ${items_deliveryLocation_latitude}
    ${items_deliveryLocation_longitude}=     Get From Dictionary     ${items[0].deliveryLocation}                 longitude
    ${items_deliveryLocation_longitude}=         Convert To Number         ${items_deliveryLocation_longitude}
    ${items_deliveryLocation_longitude}=         Format         ${items_deliveryLocation_longitude}

    ${enquiryPeriod_startDate}=                Get From Dictionary        ${ARGUMENTS[1].data.enquiryPeriod}                 startDate
    ${enquiryPeriod_startDate}=                Convert Date To String     ${enquiryPeriod_startDate}
    ${enquiryPeriod_endDate}=                Get From Dictionary        ${ARGUMENTS[1].data.enquiryPeriod}                 endDate
    ${enquiryPeriod_endDate}=                Convert Date To String     ${enquiryPeriod_endDate}

    ${tenderPeriod_startDate}=     Get From Dictionary        ${ARGUMENTS[1].data.tenderPeriod}                 startDate
    ${tenderPeriod_startDate}=                Convert Date To String     ${tenderPeriod_startDate}
    ${tenderPeriod_endDate}=     Get From Dictionary        ${ARGUMENTS[1].data.tenderPeriod}                 endDate
    ${tenderPeriod_endDate}=                Convert Date To String     ${tenderPeriod_endDate}
    #${quantity}=            Get From Dictionary     ${items[0]}                 quantity
    #${countryName}=     Get From Dictionary     ${ARGUMENTS[1].data.procuringEntity.address}             countryName
    #${delivery_end_date}=            Get From Dictionary     ${items[0].deliveryDate}     endDate
    #${delivery_end_date}=            convert_date_to_slash_format     ${delivery_end_date}
    ${cpv_id}=                Get From Dictionary     ${items[0].classification}                 id
    ${cpv_description}=                     Get From Dictionary     ${items[0].classification}                 description
    #${cpv_id1}=             Replace String                ${cpv_id}     -     _
    #${dkpp_desc}=         Get From Dictionary     ${items[0].additionalClassifications[0]}     description
    #${dkpp_id}=             Get From Dictionary     ${items[0].additionalClassifications[0]}     id
    #${dkpp_description}=            Get From Dictionary     ${items[0].additionalClassifications[0]}     description


	#${enquiry_end_date}=     Get From Dictionary                 ${ARGUMENTS[1].data.enquiryPeriod}     endDate
	#${enquiry_end_date}=     convert_date_to_slash_format     ${enquiry_end_date}
	#${end_date}=            Get From Dictionary     ${ARGUMENTS[1].data.tenderPeriod}     endDate
	#${end_date}=            convert_date_to_slash_format     ${end_date}

    Змінити персональні дані        ${ARGUMENTS[1]}

    Selenium2Library.Switch Browser         ${ARGUMENTS[0]}

    Wait Until Page Contains Element    id=content

    Click Element    xpath=//*[text()='Мої закупівлі']
    Click Element    xpath=//*[text()=' Cтворити закупівлю']

    Click Element         //*[@name='procurementMethodType']
    Click Element         //*[@value='${procurementMethodType}']

    Run Keyword And Ignore Error        Click Element    //*[@class='modal-header dialog-header-wait']//button

    Input text                                                    //*[@name='title']        ${title}
    Input text                                                    //textarea[@name='description']        ${description}

    Input text                                                    //*[@name='value:amount']     ${value_amount}
    Click Element                                             //*[@name='minimalStep:amount']

    #${minimalStep_amount}=     Convert To String         ${minimalStep_amount}

    Click Element                                             //*[@name='autocomplete']
    Input text                                                    //*[@name='minimalStep:amount']     ${minimalStep_amount}
    #Click Element                                             //*[@name='minimalStep:amount']

    #Dates
    Input text                                                    //*[@name='enquiryPeriod:startDate']     ${enquiryPeriod_startDate}
    Input text                                                    //*[@name='enquiryPeriod:endDate']     ${enquiryPeriod_endDate}

    Input text                                                    //*[@name='tenderPeriod:startDate']     ${tenderPeriod_startDate}
    Input text                                                    //*[@name='tenderPeriod:endDate']     ${tenderPeriod_endDate}
    #EndDates
    

    Click Element                                             //*[text()='Додати предмет закупiвлi']


    Input text                                                    //*[@name='items:description[]']        ${items_description}
    Click Element                                             //*[@name='items:classification:id[]']
    #Debug
    Sleep    2
        Input text                                                 //*[@name='cpv_search']        ${cpv_description}
        Sleep    2
        Click Element                                             //*[@value='${cpv_id}']

    #Click Element                                             //*[@class='ac_i form-control dkpp_list']
    #Sleep    2
#        Input text                                                    //*[@name='dkpp_search']        ${dkpp_description}
#        Sleep    2
#        Click Element                                             //*[@value='${dkpp_id}']
        
        #Click Element                                             //*[@class='ac_i form-control dkpp_list']
        #Input text                                                    //*[@name='items:additionalClassifications:description[0][]']        ${dkpp_description}

    # Select Код одиниці виміру (має відповідати стандарту UN/CEFACT, наприклад - KGM)
    #debug
    Select From List  xpath=//*[@name='items:unit:code[]']  ${items_unit_code}
    #debug
    #Click Element                                            //*[@name='items:unit:code[]']
    #    Sleep    2
    #    Click Element                                            //*[@name='items:unit:code[]']/option[@value='${items_unit_code}']
    #    Sleep    1
    Input text                                                    //*[@name='items:quantity[]']        ${items_unit_quantity}

    Input text                                                    //*[@name='items:deliveryAddress:postalCode[]']        ${items_deliveryAddress_postalCode}
    Input text                                                    //*[@name='items:deliveryAddress:countryName[]']        ${items_deliveryAddress_countryName}
    Input text                                                    //*[@name='items:deliveryAddress:region[]']        ${items_deliveryAddress_region}
    Input text                                                    //*[@name='items:deliveryAddress:locality[]']        ${items_deliveryAddress_locality}
    Input text                                                    //*[@name='items:deliveryAddress:streetAddress[]']     ${items_deliveryAddress_streetAddress}
    Input text                                                    //*[@name='items:deliveryLocation:latitude[]']        ${items_deliveryLocation_latitude}
    Input text                                                    //*[@name='items:deliveryLocation:longitude[]']        ${items_deliveryLocation_longitude}

    Input text                                                    //*[@name='items:deliveryDate:startDate[]']        ${items_items_deliveryDate_startDate}
    Input text                                                    //*[@name='items:deliveryDate:endDate[]']        ${items_items_deliveryDate_endDate}
    #333Run Keyword If     '${procurementMethodType}' == ''     Підготувати інформацію для belowThreshold @{ARGUMENTS}
    #Run Keyword If     '${procurementMethodType}' == 'reporting'     Підготувати інформацію для reporting ${ARGUMENTS}
    ##debug
    Click Element                                             //*[text()='Зберегти']
    Click Element                                             //*[@class='alert alert-info'][last()]//a[@data-original-title="Акцептувати чернетку"]
    Execute Javascript                                 window.scroll(9999,9999)
    Sleep    10

    Click Element                                             //*[text()="${ARGUMENTS[1]['data']['title']}"]/../../..//*[@class='glyphicon glyphicon-ok-sign']
    Execute Javascript                                 window.scroll(9999,9999)
    Sleep    20

    ${tender_UAid}=    Get Text                     //*[text()="${ARGUMENTS[1]['data']['title']}"]/..//*[@class='label label-primary']
    [return]    ${tender_UAid}

Завантажити документ
    [Arguments]    @{ARGUMENTS}
    [Documentation]
    ...            ${ARGUMENTS[0]} ==    username
    ...            ${ARGUMENTS[1]} ==    ${filepath}
    ...            ${ARGUMENTS[2]} ==    ${TENDER_UAID}
    Selenium2Library.Switch Browser        ${ARGUMENTS[0]}
    Wait Until Page Contains Element    id=content
    #debug
    Click Element                                             //*[@class="glyphicon glyphicon-user"]
    Click Element                                             //*[text()='Мої закупівлі']
    Execute Javascript                                 window.scroll(9999,9999)
    Sleep    3
    Click Element                                             //*[text()='${ARGUMENTS[2]}']/../../..//*[@class='col-lg-4 text-right']//a[@data-original-title='Редагувати']
    Click Element                                             //*[text()='Додати файл']
    Завантажити документ до тендеру     ${ARGUMENTS[1]}
    Input Text                                                    //*[@name='document:description[]']         Test text
    #debug
    Click Element                                             //*[text()='Опублікувати']
    Execute Javascript                                 window.scroll(9999,9999)
    Sleep    5
    Click Element                                             //*[@class='panel panel-default'][1]//*[@class='glyphicon glyphicon-ok-sign']
    Sleep  10
    torgua.Пошук тендера по ідентифікатору     ${ARGUMENTS[0]}     ${ARGUMENTS[2]}
    Sleep  5

Завантажити документ до тендеру
    [Arguments]     ${file}
    Choose File             //*[@name='document:files[]']         ${file}

Додати документ до тендеру
    [Arguments]     ${file}
    #debug
    Click Element                                             //*[text()='Додати файл']
    Завантажити документ до тендеру     ${file}
    Input Text                                                    //*[@name='document:description[]']         Test text

Змінити персональні дані
    [Arguments]     ${ARG}

    ${country} =    Get From Dictionary        ${ARG.data.procuringEntity.address}                 countryName
    ${locality} =    Get From Dictionary        ${ARG.data.procuringEntity.address}                 locality
    ${region} =    Get From Dictionary        ${ARG.data.procuringEntity.address}                 region
    ${streetAddress} =    Get From Dictionary        ${ARG.data.procuringEntity.address}                 streetAddress
    ${postalCode} =    Get From Dictionary        ${ARG.data.procuringEntity.address}                 postalCode

    ${procuringEntity_name} =    Get From Dictionary        ${ARG.data.procuringEntity}                 name

    ${contactPointName} =    Get From Dictionary        ${ARG.data.procuringEntity.contactPoint}                 name
    ${contactPointTelephone} =    Get From Dictionary        ${ARG.data.procuringEntity.contactPoint}                 telephone

    #Click Element     //*[@class = 'log']
    Click Element     //*[@href = '#info']
    Click Element     //*[text() = ' Редагувати дані']

    Click Element                                                    //*[@name='CountryUa']
    Click Element                                                    //*[@value='${country}']

    #Click Element                                                    //*[@name='RegionUa']
    #Click Element                                                    //*[@value='${region}']

    Input text                                                    //*[@name='SettlementUa']        ${locality}

    Input text                                                    //*[@name='NameUa']        ${procuringEntity_name}
    #Input text                                                    //*[@name='RegionUa']        ${region}
    Input text                                                    //*[@name='AddressUa']        ${streetAddress}
    Input text                                                    //*[@name='ZipCode']        ${postalCode}

    Input text                                                    //*[@name='ContactPhoneNumber']        ${contactPointName}

    Input text                                                    //*[@name='ContactPhoneNumber']        ${contactPointTelephone}
    Input text                                                    //*[@name='ContactMobilePhoneNumber']        ${contactPointTelephone}
    Input text                                                    //*[@name='ContactFaxNumber']        ${contactPointTelephone}

    Click Element     //*[text() = 'Зберегти']
    Click Element     //*[@class='log']

Внести зміни в тендер
    [Arguments]    @{ARGUMENTS}
    [Documentation]
    ...            ${ARGUMENTS[0]} =    username
    ...            ${ARGUMENTS[1]} =    ${TENDER_UAID}
    Selenium2Library.Switch Browser         ${ARGUMENTS[0]}
#    debug
    torgua.Пошук тендера по ідентифікатору в кабінеті     ${ARGUMENTS[0]}     ${ARGUMENTS[1]}
    ${value}=  Run keyword if  '${ARGUMENTS[2]}' == 'tenderPeriod.endDate'  Convert Date To String     ${ARGUMENTS[3]}   ELSE   CONVERT TO STRING    ${ARGUMENTS[3]}
    ${prop}=  Evaluate  '${ARGUMENTS[2]}'.replace(".", ":")
    Input text                                                //textarea[@name='${prop}'] | //input[@name='${prop}']     ${value}
    Click Element                                             //*[text()='Опублікувати']
    Capture Page Screenshot
    Click Element                                             //*[text()='Мої закупівлі']
    Execute Javascript                                 window.scroll(9999,9999)
    Sleep  10
    Click Element                                             //*[@class='panel panel-default'][1]//*[@class='glyphicon glyphicon-ok-sign']
    Sleep  10
    torgua.Пошук тендера по ідентифікатору     ${ARGUMENTS[0]}     ${ARGUMENTS[1]}
    Sleep  5

Задати питання до лоту
    [Arguments]    @{ARGUMENTS}
    [Documentation]
    ...            ${ARGUMENTS[0]} = username
    ...            ${ARGUMENTS[1]} = tenderUaId
    ...            ${ARGUMENTS[2]} = lot_id
    ...            ${ARGUMENTS[3]} = question
    Selenium2Library.Switch Browser        ${ARGUMENTS[0]}
    torgua.Пошук тендера по ідентифікатору        ${ARGUMENTS[0]}     ${ARGUMENTS[1]}
    Click Element    xpath=//a[text()='Обговорення']
    Click Element     xpath=//select[@name='questionOf']//option[@value='lot']
    Input text    name=title    ${ARGUMENTS[3]}
    Input text    name=description    ${ARGUMENTS[3]}
    Click Element    name=add-question

Відповісти На Питання
    [Arguments]    @{ARGUMENTS}
    ${answer}=         Get From Dictionary    ${ARGUMENTS[3].data}    answer
    torgua.Пошук тендера по ідентифікатору        ${ARGUMENTS[0]}     ${ARGUMENTS[1]}
    Click Element                                                 xpath=//*[text()='Обговорення ']
    Sleep         4
    #Click Element                                                 xpath=//a[contains(@id, 'add_answer_btn_0')]
    #Sleep         4
    Input Text                                                        xpath=//*[@class='media well'][1]//*[@name='answer']                ${answer}
    Click Element                                                 xpath=//*[@class='media well'][1]//*[text()='Відповісти']

Задати запитання на тендер
    [Arguments]    @{ARGUMENTS}
    ${title}=                Get From Dictionary    ${ARGUMENTS[2].data}    title
    ${description}=    Get From Dictionary    ${ARGUMENTS[2].data}    description
    Selenium2Library.Switch Browser        ${ARGUMENTS[0]}
    torgua.Пошук тендера по ідентифікатору        ${ARGUMENTS[0]}     ${ARGUMENTS[1]}
    Sleep   10
    Click Element                                             xpath=//*[text()='Обговорення ']
    Input text                                                    xpath=//*[@name='title']                                 ${title}
    Input text                                                    xpath=//textarea[@name='description']                                 ${description}
    Click Element                                             xpath=//*[@name='add-question']
    torgua.Пошук тендера по ідентифікатору        ${ARGUMENTS[0]}     ${ARGUMENTS[1]}

Подати цінову пропозицію
    [Arguments]    @{ARGUMENTS}
    [Documentation]
    ...            ${ARGUMENTS[0]} ==    username
    ...            ${ARGUMENTS[1]} ==    ${TENDER_UAID}
    ...            ${ARGUMENTS[2]} ==    ${test_bid_data}
    #debug
    ${amount}=        Get From Dictionary         ${ARGUMENTS[2].data.value}                 amount
    ${amount}=        Convert To String         ${amount}
    torgua.Пошук тендера по ідентифікатору     ${ARGUMENTS[0]}     ${ARGUMENTS[1]}
    
    Click Element     xpath=//*[text()='Зареєструватися як учасник']
    Input text        xpath=//input[@placeholder="Ваша пропозицiя"]                                    ${amount}
    Click Element     xpath=//button[text()='Подати заявку']
    Click Element     xpath=(//*[text()='Активувати'])[1]
    Sleep  10
    torgua.Пошук тендера по ідентифікатору        ${ARGUMENTS[0]}     ${ARGUMENTS[1]}
    Sleep  10

Змінити цінову пропозицію
    [Arguments]    @{ARGUMENTS}
    [Documentation]
    ...            ${ARGUMENTS[0]} ==    username
    ...            ${ARGUMENTS[1]} ==    ${TENDER_UAID}
    ...            ${ARGUMENTS[2]} ==    ${fieldname}
    ...            ${ARGUMENTS[3]} ==    ${fieldvalue}
    #debug
    #torgua.Пошук тендера по ідентифікатору     ${ARGUMENTS[0]}     ${ARGUMENTS[1]}
    Click Element     //*[@class='log']
    Click Element     //*[text()='Мої пропозиції']
    Click Element     xpath=(//*[text()='Редагувати'])[1]
    ${ARGUMENTS[3]}=  Convert to String  ${ARGUMENTS[3]}
    Input text        xpath=//input[@placeholder="Ваша пропозицiя"]                ${ARGUMENTS[3]}
    Click Element     //*[text()='Зберегти']
    Sleep  5
    torgua.Пошук тендера по ідентифікатору        ${ARGUMENTS[0]}     ${ARGUMENTS[1]}

Відповісти на запитання
    [Arguments]    @{ARGUMENTS}
    torgua.Пошук тендера по ідентифікатору        ${ARGUMENTS[0]}     ${ARGUMENTS[1]}
    Click Element                                                 xpath=//*[text()='Обговорення ']
    Input Text   xpath=//*[@placeholder="Введіть відповідь на запитання"]          ${ARGUMENTS[2].data.answer}
    Click Element                                                 xpath=//*[@class='media well'][1]//*[text()='Відповісти']
    
Скасувати цінову пропозицію
    [Arguments]    @{ARGUMENTS}
    [Documentation]
    ...            ${ARGUMENTS[0]} ==    username
    ...            ${ARGUMENTS[1]} ==    ${TENDER_UAID}
    Click Element     //*[text()='Видалити'][1]

Завантажити документ в ставку
    [Arguments]    @{ARGUMENTS}
    [Documentation]
        ...        ${ARGUMENTS[0]} ==    username
        ...        ${ARGUMENTS[1]} ==    file
        ...        ${ARGUMENTS[2]} ==    tenderId
    Selenium2Library.Switch Browser         ${ARGUMENTS[0]}
    Click Element     //*[@class='log']
    Click Element     //*[text()='Мої пропозиції']
    Click Element     xpath=(//*[text()='Редагувати'])[1]
    Click Element     //*[text()='Додати документ']
    Choose File                                 //*[@name='documents:file[]']                    ${ARGUMENTS[1]}
    Click Element     //*[text()='Зберегти']
    Sleep  5
    torgua.Пошук тендера по ідентифікатору     ${ARGUMENTS[0]}     ${ARGUMENTS[2]}
    Sleep  5
    #Click Element     xpath=(//*[text()='Активувати'])[1]
    #sleep    10

Змінити документ в ставці
    [Arguments]    @{ARGUMENTS}
    [Documentation]
        ...        ${ARGUMENTS[0]} ==    username
        ...        ${ARGUMENTS[1]} ==    tenderId
        ...        ${ARGUMENTS[2]} ==    amount
        ...        ${ARGUMENTS[3]} ==    amount.value
    Selenium2Library.Switch Browser         ${ARGUMENTS[0]}
    Click Element     //*[@class='log']
    Click Element     //*[text()='Мої пропозиції']
    Click Element     xpath=(//*[text()='Редагувати'])[1]
    Choose File                                 //*[@name='exi_documents:file[]']                    ${ARGUMENTS[2]}
    Click Element     //*[text()='Зберегти']
    #Click Element     xpath=(//*[text()='Активувати'])[1]


Пошук тендера по ідентифікатору
    [Arguments]    @{ARGUMENTS}
        [Documentation]
    ...            ${ARGUMENTS[0]} ==    username
    ...            ${ARGUMENTS[1]} ==    tenderId
        Switch browser     ${ARGUMENTS[0]}
    Go To    ${USERS.users['${ARGUMENTS[0]}'].homepage}
    Wait Until Page Contains Element    id=content
    Click Element    xpath=.//*[@class='dropdown-toggle']
    Click Element    xpath=//a[text()='Закупівлі']
    Input text    name=q    ${ARGUMENTS[1]}
    Click Element    xpath=//button[contains(text(), 'Пошук')]
    Click Element    xpath=.//*[@class='row lots']/a
    Wait Until Page Contains Element    id=content

Пошук тендера по ідентифікатору в кабінеті
    [Arguments]    @{ARGUMENTS}
        [Documentation]
    ...            ${ARGUMENTS[0]} ==    username
    ...            ${ARGUMENTS[1]} ==    tenderId
    Wait Until Page Contains Element    id=content
    Click Element                                             //*[@class='log']
    Click Element                                             //*[text()='Мої закупівлі']
    Click Element                                             //*[@id="tendertab"]
    Execute Javascript                                 window.scroll(9999,9999)
    Sleep  3
    Click Element                                             //*[@id='tendersList']//*[text()='${ARGUMENTS[1]}']//ancestor::*[3]//*[@class='glyphicon glyphicon-pencil']

Отримати інформацію із тендера
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...      ${ARGUMENTS[0]} ==  tender_uaid
    ...      ${ARGUMENTS[1]} ==  field
    ${return_value}=  run keyword  Отримати інформацію про ${ARGUMENTS[2]}
    [return]  ${return_value}
Отримати інформацію із предмету
    [Arguments]  @{ARGUMENTS}
    ${return_value}=  run keyword  Отримати інформацію про items ${ARGUMENTS[3]}
    [return]  ${return_value}
Отримати інформацію із запитання
    [Arguments]  @{ARGUMENTS}
    #debug
    torgua.Пошук тендера по ідентифікатору        ${ARGUMENTS[0]}     ${ARGUMENTS[1]}
    Click Element                                             //*[@href='#questions']
    ${return_value}=  run keyword  Отримати інформацію про questions ${ARGUMENTS[3]}
    [return]  ${return_value}
Отримати інформацію із документа
    [Arguments]  @{ARGUMENTS}
    #debug
    ${return_value}=  run keyword  Отримати Інформацію Про document ${ARGUMENTS[3]}
    [return]  ${return_value}

Отримати інформацію із пропозиції
    [Arguments]  @{ARGUMENTS}
    ${return_value}=  run keyword  Отримати Інформацію Про ${ARGUMENTS[2]}
    [return]  ${return_value}
Отримати документ
    [Arguments]  @{ARGUMENTS}
    ${docName}=    Get Text         xpath=(//*[@class='doc_title'])
    ${docUrl}=     Get Element Attribute         xpath=(//*[@style='padding: 5px 0; display: block; border-bottom: 1px solid #fff; '])@href
    Download File From Url  ${docUrl}  ${OUTPUT_DIR}${/}${docName}
    [return]  ${docName}
Отримати Посилання На Аукціон Для Глядача
    [Arguments]    ${user}    ${tenderId}
    #${AuctionUrl}=     torgua.Отримати посилання на аукціон    ${user}    ${tenderId}
    torgua.Пошук тендера по ідентифікатору     ${user}     ${tenderId}
    ${AuctionUrl}=     Get Element Attribute         xpath=(//*[text()='Аукціон'])@href
    [return]    ${AuctionUrl}

Отримати посилання на аукціон для учасника
    [Arguments]    @{ARGUMENTS}
    torgua.Пошук тендера по ідентифікатору     ${ARGUMENTS[0]}     ${ARGUMENTS[1]}
    ${AuctionUrl}=     Get Element Attribute    xpath=(//*[text()='Аукціон для учасника'])@href
    [return]    ${AuctionUrl}

Отримати посилання на аукціон
    [Arguments]    ${user}    ${tenderId}
    torgua.Пошук тендера по ідентифікатору ${user} ${tenderId}
    ${AuctionUrl}=     Get Element Attribute         xpath=(//*[text()='Аукціон'])@href
    [return]    ${AuctionUrl}

Отримати Інформацію Про document title
    ${documentTitle}=     Отримати текст із поля і показати на сторінці     document.title
    [return]    ${documentTitle}
Оновити сторінку з тендером
    [Arguments]    @{ARGUMENTS}
    [Documentation]
    ...            ${ARGUMENTS[0]} = username
    ...            ${ARGUMENTS[1]} = tenderUaId

    Selenium2Library.Switch Browser        ${ARGUMENTS[0]}
    torgua.Пошук тендера по ідентифікатору        ${ARGUMENTS[0]}     ${ARGUMENTS[1]}
    Reload Page

Отримати текст із поля і показати на сторінці
    [Arguments]     ${fieldname}
    sleep    1
    ${return_value}=     Get Text    ${locator.${fieldname}}
    [return]    ${return_value}

Отримати Інформацію Про Title

    ${title}=     Отримати текст із поля і показати на сторінці     title
    [return]    ${title}
отримати інформацію про AuctionUrl
    ${auctionUrl}=     Отримати текст із поля і показати на сторінці     auctionUrl
    [return]    ${auctionUrl}

отримати інформацію про description
    ${description}=     Отримати текст із поля і показати на сторінці     description
    [return]    ${description}

отримати інформацію про tenderId
    ${tenderId}=    Отримати текст із поля і показати на сторінці  tenderId
    [return]    ${tenderId}

отримати інформацію про value.amount
    #debug
    ${valueAmount}=     Отримати текст із поля і показати на сторінці     value.amount
    #debug
    ${valueAmount}=      Convert To Number     ${valueAmount.split(' ')[0]}
    [return]    ${valueAmount}

отримати інформацію про minimalStep.amount
    ${minimalStepAmount}=     Отримати текст із поля і показати на сторінці     minimalStep.amount
    #debug
    ${minimalStepAmount}=      Convert To Number     ${minimalStepAmount.split(' ')[0]}
    [return]    ${minimalStepAmount}

Отримати інформацію про awards[1].complaintPeriod.endDate
    ${awardComplaintPeriodEndDate}=     Отримати текст із поля і показати на сторінці awards[1].complaintPeriod.endDate
    ${awardComplaintPeriodEndDate}=     parse_date     ${awardComplaintPeriodEndDate}
    [return]    ${awardComplaintPeriodEndDate}

отримати інформацію про enquiryPeriod.endDate
    ${enquiryPeriodEndDate}=     Отримати текст із поля і показати на сторінці     enquiryPeriod.endDate
    ${enquiryPeriodEndDate}=     parse_date     ${enquiryPeriodEndDate}
    [return]    ${enquiryPeriodEndDate}

отримати інформацію про tenderPeriod.endDate
    ${tenderPeriodEndDate}=     Отримати текст із поля і показати на сторінці         tenderPeriod.endDate
    ${tenderPeriodEndDate}=     parse_date        ${tenderPeriodEndDate}
    [return]    ${tenderPeriodEndDate}

отримати інформацію про items deliveryAddress.countryName
    ${countryName}=     Отримати текст із поля і показати на сторінці     items[0].deliveryAddress.countryName
    [return]    ${countryName}

отримати інформацію про items classification.scheme
    #${classificationScheme}=     Отримати текст із поля і показати на сторінці     items[0].classification.scheme
    [return]    ДК021

отримати інформацію про items additionalClassifications[0].id
    ${additionalClassificationsId}=     Отримати текст із поля і показати на сторінці         items[0].additionalClassifications[0].id
    [return]    ${additionalClassificationsId}

отримати інформацію про items additionalClassifications[0].description
    ${additionalClassificationsDescription}=     Отримати текст із поля і показати на сторінці        items[0].additionalClassifications[0].description
    [return]    ${additionalClassificationsDescription}

отримати інформацію про items additionalClassifications[0].scheme
    ${additionalClassificationsScheme}=     Отримати текст із поля і показати на сторінці     items[0].additionalClassifications[0].scheme
    [return]    ${additionalClassificationsScheme}

Отримати інформацію про questions title
    ${questionsTitle}=     Отримати текст із поля і показати на сторінці         questions[0].title
    [return]    ${questionsTitle}

Отримати інформацію про questions[0].title
    ${questionsTitle}=     Отримати текст із поля і показати на сторінці         questions[0].title
    [return]    ${questionsTitle}

отримати інформацію про questions description
    
    ${questionsDescription}=     Отримати текст із поля і показати на сторінці         questions[0].description
    [return]    ${questionsDescription}

отримати інформацію про questions date
    
    ${questionsDate}=     Отримати текст із поля і показати на сторінці         questions[0].date
    ${questionsDate}=     convert_date_for_compare         ${questionsDate}
    [return]    ${questionsDate}

отримати інформацію про questions answer
    Click Element                                             xpath=//*[text() = 'Обговорення ']
    ${questionsAnswer}=     Отримати текст із поля і показати на сторінці         questions[0].answer
    [return]    ${questionsAnswer}

отримати інформацію про items deliveryDate.startDate
    ${deliveryDateStartDate}=     Отримати текст із поля і показати на сторінці         items[0].deliveryDate.startDate
    ${deliveryDateStartDate}=     parse_date        ${deliveryDateStartDate}
    [return]    ${deliveryDateStartDate}

отримати інформацію про items deliveryDate.endDate
    ${deliveryDateEndDate}=     Отримати текст із поля і показати на сторінці     items[0].deliveryDate.endDate
    ${deliveryDateEndDate}=     parse_date        ${deliveryDateEndDate}
    [return]    ${deliveryDateEndDate}

отримати інформацію про items classification.id
    ${classificationId}=     Отримати текст із поля і показати на сторінці     items[0].classification.id
    [return]    ${classificationId}

отримати інформацію про items classification.description
    ${classificationDescription}=     Отримати текст із поля і показати на сторінці         items[0].classification.description
    Run Keyword And Return If    '${classificationDescription}' == 'Картонки'        Convert To String    Cartons
    [return]    ${classificationDescription}

отримати інформацію про items quantity
    ${itemsQuantity}=     Отримати текст із поля і показати на сторінці         items[0].quantity
    ${itemsQuantity}=     Convert To Integer        ${itemsQuantity}
    [return]    ${itemsQuantity}

отримати інформацію про items unit.code
    ${unitCode}=     Отримати текст із поля і показати на сторінці         items[0].unit.code
    Run Keyword And Return If    '${unitCode}'== 'KGM (кілограми)'     Convert To String    KGM
    [return]    ${unitCode}

отримати інформацію про items unit.name
    ${unitName}=     Отримати текст із поля і показати на сторінці         items[0].unit.name
    Run Keyword And Return If    '${unitName}' == 'KGM (кілограми)'        Convert To String    кілограми
    [return]    ${unitName}

Отримати інформацію про value.currency
    ${valueCurrency}=     Отримати текст із поля і показати на сторінці         value.currency
    [return]    ${valueCurrency}

Отримати інформацію про value.valueAddedTaxIncluded
    ${valueAddedTaxIncluded}=     Отримати текст із поля і показати на сторінці         value.valueAddedTaxIncluded
    Run Keyword And Return If    '${valueAddedTaxIncluded}'=='з ПДВ'     Convert To boolean    True
    [return]    ${valueAddedTaxIncluded}

Отримати інформацію про items description
    ${itemsDescription}=     Отримати текст із поля і показати на сторінці         items[0].description
    [return]    ${itemsDescription}

отримати інформацію про procuringEntity.name
    ${procuringEntityName}=     Отримати текст із поля і показати на сторінці         procuringEntity.name
    [return]    ${procuringEntityName}

отримати інформацію про enquiryPeriod.startDate
    ${enquiryPeriodStartDate}=     Отримати текст із поля і показати на сторінці         enquiryPeriod.startDate
    ${enquiryPeriodStartDate}=     parse_date        ${enquiryPeriodStartDate}
    
    [return]    ${enquiryPeriodStartDate}

отримати інформацію про tenderPeriod.startDate
    ${tenderPeriodStartDate}=     Отримати текст із поля і показати на сторінці         tenderPeriod.startDate
    ${tenderPeriodStartDate}=     parse_date        ${tenderPeriodStartDate}
    [return]    ${tenderPeriodStartDate}

отримати інформацію про items deliveryLocation.longitude    
    ${deliveryLocationLongitude}=     Отримати текст із поля і показати на сторінці         items[0].deliveryLocation.longitude
    ${deliveryLocationLongitude}=    Convert To Number   ${deliveryLocationLongitude}
    [return]    ${deliveryLocationLongitude}

отримати інформацію про items deliveryLocation.latitude
    ${deliveryLocationLatitude}=     Отримати текст із поля і показати на сторінці         items[0].deliveryLocation.latitude
    ${deliveryLocationLatitude}=    Convert To Number   ${deliveryLocationLatitude}
    [return]    ${deliveryLocationLatitude}


отримати інформацію про items deliveryAddress.postalCode
    ${deliveryAddressPostalCode}=     Отримати текст із поля і показати на сторінці         items[0].deliveryAddress.postalCode
    [return]    ${deliveryAddressPostalCode}

отримати інформацію про items deliveryAddress.locality
    ${deliveryAddressLocality}=     Отримати текст із поля і показати на сторінці         items[0].deliveryAddress.locality
    [return]    ${deliveryAddressLocality}

отримати інформацію про items deliveryAddress.streetAddress
    ${deliveryAddressStreetAddress}=     Отримати текст із поля і показати на сторінці         items[0].deliveryAddress.streetAddress
    [return]    ${deliveryAddressStreetAddress}

отримати інформацію про items deliveryAddress.region
    ${deliveryAddressRegion}=     Отримати текст із поля і показати на сторінці         items[0].deliveryAddress.region
    [return]    ${deliveryAddressRegion}

Отримати Інформацію Про Status
    #${status}=     Get Element Attribute     //*[@name='tender-status']@value
    ${status}=     Get Element Attribute         xpath=(//*[@name='tender-status'])@value
    [return]    ${status}
