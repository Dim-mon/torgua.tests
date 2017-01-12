*** Settings ***
Library  Selenium2Screenshots
Library  String
Library  DateTime
Library  torgua_service.py
Library  DebugLibrary

*** Variables ***
${locator.tenderId}                  xpath=//td[./text()='TenderID']//following-sibling::td[1]
${locator.title}                     xpath=//div[@class = 'tender_head col-md-9']//h1
${locator.description}               xpath=//div[@class = 'tender_head col-md-9']//h4
${locator.auctionUrl}                xpath=//div[@class='btn-defauld-torg tender']//a

${locator.value.amount}                 xpath=//span[@class = 'value_amount']
${locator.value.currency}               xpath=//span[@class = 'value_curency']
${locator.value.valueAddedTaxIncluded}  xpath=//span[@class = 'value_tax']

${locator.minimalStep.amount}        xpath=//*[@class='ms_amount']
${locator.minimalStep.currency}        xpath=//*[@class='ms_currency']

${locator.tenderPeriod.startDate}        xpath=//*[@id='tenderPeriod_startDate']
${locator.enquiryPeriod.startDate}     xpath=//td[./text()='Дата початку періоду обговорень']//following-sibling::td[1]
${locator.enquiryPeriod.endDate}     xpath=//td[./text()='Завершення періоду обговорення']//following-sibling::td[1]
${locator.auctionPeriod.startDate}     xpath=//td[text()='Дата та час аукціону/редукціону']//following-sibling::td[1]
${locator.auctionPeriod.endDate}     xpath=//td[./text()='Кінець аукціону']//following-sibling::td[1]
${locator.tenderPeriod.endDate}      xpath=//td[./text()='Завершення періоду прийому пропозицій']//following-sibling::td[1]
${locator.items[0].deliveryDate.endDate}     xpath=//td[./text()='Кінцева дата поставки']//following-sibling::td[1]
${locator.items[0].description}    xpath=//table[@class = 'tender_item_table']//tbody//tr[1]//td[2]
${locator.items[0].classification.scheme}    CPV
${locator.items[0].classification.id}        xpath=//*[text()='Клас: CPV']/parent::tr//td[2]/*[@class='c_id']
${locator.items[0].classification.description}       xpath=//*[text()='Клас: CPV']/parent::tr//td[2]/*[@class='c_desc']
#${locator.items[0].additionalClassifications[0].scheme}   ДКПП
${locator.items[0].additionalClassifications[0].id}       xpath=//*[text()='Клас: ДКПП']/parent::tr//td[2]/*[@class='ac_id']
${locator.items[0].additionalClassifications[0].description}       xpath=//*[text()='Клас: ДКПП']/parent::tr//td[2]/*[@class='ac_desc']

${locator.items[0].deliveryLocation.latitude}         xpath=//*[@name='items:deliveryLocation:latitude[]']
${locator.items[0].deliveryLocation.longitude}        xpath=//*[@name='items:deliveryLocation:longitude[]']

${locator.items[0].deliveryAddress.countryName}    xpath=//*[@class='da_countryName']
${locator.items[0].deliveryAddress.region}        xpath=//*[@class='da_region']
${locator.items[0].deliveryAddress.locality}        xpath=//*[@class='da_locality']
${locator.items[0].deliveryAddress.postalCode}        xpath=//*[@class='da_postalCode']
${locator.items[0].deliveryAddress.streetAddress}        xpath=//*[@class='da_streetAddress']

#${locator.items[0].deliveryAddress.region}        xpath=//*[@class='da_region']
#${locator.items[0].deliveryAddress.region}        xpath=//*[@class='da_region']
#${locator.items[0].deliveryAddress.region}        xpath=//*[@class='da_region']

${locator.procuringEntity.name}         xpath=//*[text()='ОРГАНІЗАТОР ЗАКУПІВЛІ']/following-sibling::*[1]//*[2]//*[2]

${locator.items[0].quantity}         xpath=//td[./text()='Кількість']/following-sibling::td[1]
${locator.items[0].unit.code}        xpath=//td[./text()='Одиниця виміру']/following-sibling::td[1]
${locator.items[0].unit.name}        xpath=//td[./text()='Одиниця виміру']/following-sibling::td[1]
${locator.questions[0].title}        xpath = //*[@class='question-title-tender']
${locator.questions[0].description}  xpath = //*[@class='question-description-tender']
${locator.questions[0].date}         xpath = //*[@class='date-comment']
${locator.questions[0].answer}       xpath=//*[@class='well']

${locator.awards[1].complaintPeriod.endDate}

*** Keywords ***

Підготувати дані для оголошення тендера
  [Arguments]  @{ARGUMENTS}
  Log Many  @{ARGUMENTS}
  [return]  ${ARGUMENTS[1]}

Підготувати клієнт для користувача
  [Arguments]  @{ARGUMENTS}
  [Documentation]  Відкрити браузер, створити об’єкт api wrapper, тощо
  ...      ${ARGUMENTS[0]} ==  username
  Open Browser
  ...      ${USERS.users['${ARGUMENTS[0]}'].homepage}
  ...      ${USERS.users['${ARGUMENTS[0]}'].browser}
  ...      alias=${ARGUMENTS[0]}
  Set Window Size       @{USERS.users['${ARGUMENTS[0]}'].size}
  Set Window Position   @{USERS.users['${ARGUMENTS[0]}'].position}
  Click Element  xpath= //a[@class="log"]
  Wait Until Page Contains Element  id=content
  Input text  name=login  ${USERS.users['${ARGUMENTS[0]}'].login}
  Input text  name=password  ${USERS.users['${ARGUMENTS[0]}'].password}
  Click Element  name=send_auth

  Run Keyword And Ignore Error    Click Element  //*[text()='Ознайомлений']

Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data
  ${title}=         Get From Dictionary   ${ARGUMENTS[1].data}               title
  ${description}=   Get From Dictionary   ${ARGUMENTS[1].data}               description
  ${procurementMethodType}=   Convert To String    belowThreshold


  ${value_amount}=        Get From Dictionary   ${ARGUMENTS[1].data.value}         amount
  ${value_amount}=              Convert To String     ${value_amount}

  ${value_currency}=        Get From Dictionary   ${ARGUMENTS[1].data.value}         currency
  ${minimalStep_amount}=     Get From Dictionary   ${ARGUMENTS[1].data.minimalStep}   amount
  ${minimalStep_amount}=     Convert To String     ${minimalStep_amount}

  #${minimalStep_currency}=     Get From Dictionary   ${ARGUMENTS[1].data.minimalStep}   currency
  ${items}=         Get From Dictionary   ${ARGUMENTS[1].data}               items
  ${items_description}=   Get From Dictionary   ${items[0]}         description
  ${items_unit_quantity}=   Get From Dictionary   ${items[0]}         quantity
  ${items_unit_code}=   Get From Dictionary   ${items[0].unit}         code

  #Період поставки товару (початкова дата)
  #${items_items_deliveryDate_startDate}=   Get From Dictionary   ${items[0].unit}         code
  #Період поставки товару (кінцева дата)
  ${items_items_deliveryDate_endDate}=   Get From Dictionary   ${items[0].deliveryDate}         endDate
  ${items_items_deliveryDate_endDate}=        polonex_convertdate   ${items_items_deliveryDate_endDate}

  ${items_deliveryAddress_postalCode}=   Get From Dictionary   ${items[0].deliveryAddress}         postalCode
  ${items_deliveryAddress_countryName}=   Get From Dictionary   ${items[0].deliveryAddress}         countryName
  ${items_deliveryAddress_region}=   Get From Dictionary   ${items[0].deliveryAddress}         region
  ${items_deliveryAddress_locality}=   Get From Dictionary   ${items[0].deliveryAddress}         locality
  ${items_deliveryAddress_streetAddress}=   Get From Dictionary   ${items[0].deliveryAddress}         streetAddress

  ${items_deliveryLocation_latitude}=   Get From Dictionary   ${items[0].deliveryLocation}         latitude
  ${items_deliveryLocation_latitude}=     Convert To String     ${items_deliveryLocation_latitude}
  ${items_deliveryLocation_longitude}=   Get From Dictionary   ${items[0].deliveryLocation}         longitude
  ${items_deliveryLocation_longitude}=     Convert To String     ${items_deliveryLocation_longitude}

  ${enquiryPeriod_startDate}=        Get From Dictionary    ${ARGUMENTS[1].data.enquiryPeriod}         startDate
  ${enquiryPeriod_startDate}=        polonex_convertdate   ${enquiryPeriod_startDate}
  ${enquiryPeriod_endDate}=        Get From Dictionary    ${ARGUMENTS[1].data.enquiryPeriod}         endDate
  ${enquiryPeriod_endDate}=        polonex_convertdate   ${enquiryPeriod_endDate}

  ${tenderPeriod_startDate}=   Get From Dictionary    ${ARGUMENTS[1].data.tenderPeriod}         startDate
  ${tenderPeriod_startDate}=        polonex_convertdate   ${tenderPeriod_startDate}
  ${tenderPeriod_endDate}=   Get From Dictionary    ${ARGUMENTS[1].data.tenderPeriod}         endDate
  ${tenderPeriod_endDate}=        polonex_convertdate   ${tenderPeriod_endDate}
  #${quantity}=      Get From Dictionary   ${items[0]}         quantity
  #${countryName}=   Get From Dictionary   ${ARGUMENTS[1].data.procuringEntity.address}       countryName
  #${delivery_end_date}=      Get From Dictionary   ${items[0].deliveryDate}   endDate
  #${delivery_end_date}=      convert_date_to_slash_format   ${delivery_end_date}
  ${cpv_id}=        Get From Dictionary   ${items[0].classification}         id
  ${cpv_description}=           Get From Dictionary   ${items[0].classification}         description
  #${cpv_id1}=       Replace String        ${cpv_id}   -   _
  #${dkpp_desc}=     Get From Dictionary   ${items[0].additionalClassifications[0]}   description
  ${dkpp_id}=       Get From Dictionary   ${items[0].additionalClassifications[0]}   id
  ${dkpp_description}=      Get From Dictionary   ${items[0].additionalClassifications[0]}   description


	#${enquiry_end_date}=   Get From Dictionary         ${ARGUMENTS[1].data.enquiryPeriod}   endDate
	#${enquiry_end_date}=   convert_date_to_slash_format   ${enquiry_end_date}
	#${end_date}=      Get From Dictionary   ${ARGUMENTS[1].data.tenderPeriod}   endDate
	#${end_date}=      convert_date_to_slash_format   ${end_date}

  Змінити персональні дані    ${ARGUMENTS[1]}

  Selenium2Library.Switch Browser     ${ARGUMENTS[0]}

  Wait Until Page Contains Element  id=content

  Click Element  xpath=//*[text()='Мої закупівлі']
  Click Element  xpath=//*[text()=' Cтворити закупівлю']

  Click Element     //*[@name='procurementMethodType']
  Click Element     //*[@value='${procurementMethodType}']

  Run Keyword And Ignore Error    Click Element  //*[@class='modal-header dialog-header-wait']//button

  Input text                          //*[@name='title']    ${title}
  Input text                          //textarea[@name='description']    ${description}

  Input text                          //*[@name='value:amount']   ${value_amount}
  Click Element                       //*[@name='minimalStep:amount']

  #${minimalStep_amount}=   Convert To String     ${minimalStep_amount}

  Click Element                       //*[@name='autocomplete']
  Input text                          //*[@name='minimalStep:amount']   ${minimalStep_amount}
  #Click Element                       //*[@name='minimalStep:amount']

  #Dates
  Input text                          //*[@name='enquiryPeriod:startDate']   ${enquiryPeriod_startDate}
  Input text                          //*[@name='enquiryPeriod:endDate']   ${enquiryPeriod_endDate}

  Input text                          //*[@name='tenderPeriod:startDate']   ${tenderPeriod_startDate}
  Input text                          //*[@name='tenderPeriod:endDate']   ${tenderPeriod_endDate}
  #EndDates

  Click Element                       //*[text()='Додати предмет закупiвлi']


  Input text                          //*[@name='items:description[]']    ${items_description}
  Click Element                       //*[@name='items:classification:id[]']
  Sleep  2
    Input text                          //*[@name='cpv_search']    ${cpv_description}
    Sleep  2
    Click Element                       //*[@value='${cpv_id}']

  Click Element                       //*[@name='items:additionalClassifications:id[]']
  Sleep  2
    Input text                          //*[@name='dkpp_search']    ${dkpp_description}
    Sleep  2
    Click Element                       //*[@value='${dkpp_id}']

  # Select Код одиниці виміру (має відповідати стандарту UN/CEFACT, наприклад - KGM)
  Click Element                      //*[@name='items:unit:code[]']
    Sleep  2
    Click Element                      //*[@name='items:unit:code[]']/option[@value='${items_unit_code}']

  Input text                          //*[@name='items:quantity[]']    ${items_unit_quantity}

  Input text                          //*[@name='items:deliveryAddress:postalCode[]']    ${items_deliveryAddress_postalCode}
  Input text                          //*[@name='items:deliveryAddress:countryName[]']    ${items_deliveryAddress_countryName}
  Input text                          //*[@name='items:deliveryAddress:region[]']    ${items_deliveryAddress_region}
  Input text                          //*[@name='items:deliveryAddress:locality[]']    ${items_deliveryAddress_locality}
  Input text                          //*[@name='items:deliveryAddress:streetAddress[]']    ${items_deliveryAddress_streetAddress}

  Input text                          //*[@name='items:deliveryLocation:latitude[]']    ${items_deliveryLocation_latitude}
  Input text                          //*[@name='items:deliveryLocation:longitude[]']    ${items_deliveryLocation_longitude}

  Input text                          //*[@name='items:deliveryDate:endDate[]']    ${items_items_deliveryDate_endDate}
  #333Run Keyword If   '${procurementMethodType}' == ''   Підготувати інформацію для belowThreshold @{ARGUMENTS}
  #Run Keyword If   '${procurementMethodType}' == 'reporting'   Підготувати інформацію для reporting ${ARGUMENTS}

  Click Element                       //*[text()='Зберегти']
  Click Element                       //*[@class='alert alert-info'][last()]//a[@data-original-title="Акцептувати чернетку"]
  Click Element                       //*[@class='panel panel-default'][1]//*[@class='glyphicon glyphicon-ok-sign']
  ${tender_UAid}=  Get Text           //*[@class='panel panel-default'][1]//*[@class='label label-primary']
  [return]  ${tender_UAid}

Завантажити документ
[Arguments]  ${username}  ${file}  ${tender_uaid}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  file
  ...      ${ARGUMENTS[2]} ==  tender_uaid
  Click Element                       //*[text()='Мої закупівлі']
  Click Element                       //*[text()=' ${ARGUMENTS[2]}']//ancestor::*[3]//*[@class='glyphicon glyphicon-pencil']
  Click Element                       //*[text()='Додати файл']
  Завантажити документ до тендеру   ${ARGUMENTS[1]}
  Input Text                          //*[@name='document:description[]']     Test text
  Click Element                       //*[text()='Зберегти']
  Sleep  10

Завантажити документ до тендеру
  [Arguments]   ${file}
  Log  ${file}
  Choose File       //*[@name='document:files[]']     ${file}

Додати документ до тендеру
  [Arguments]   ${file}
  Click Element                       //*[text()='Додати файл']
  Завантажити документ до тендеру   ${file}
  Input Text                          //*[@name='document:description[]']     Test text

Змінити персональні дані
  [Arguments]   ${ARG}

  ${country} =  Get From Dictionary    ${ARG.data.procuringEntity.address}         countryName
  ${locality} =  Get From Dictionary    ${ARG.data.procuringEntity.address}         locality
  ${region} =  Get From Dictionary    ${ARG.data.procuringEntity.address}         region
  ${streetAddress} =  Get From Dictionary    ${ARG.data.procuringEntity.address}         streetAddress
  ${postalCode} =  Get From Dictionary    ${ARG.data.procuringEntity.address}         postalCode

  ${procuringEntity_name} =  Get From Dictionary    ${ARG.data.procuringEntity}         name

  ${contactPointName} =  Get From Dictionary    ${ARG.data.procuringEntity.contactPoint}         name
  ${contactPointTelephone} =  Get From Dictionary    ${ARG.data.procuringEntity.contactPoint}         telephone

  #Click Element   //*[@class = 'log']
  Click Element   //*[@href = '#info']
  Click Element   //*[text() = ' Редагувати дані']

  Click Element                          //*[@name='CountryUa']
  Click Element                          //*[@value='${country}']

  Click Element                          //*[@name='RegionUa']
  Click Element                          //*[@value='${region}']

  Input text                          //*[@name='SettlementUa']    ${locality}

  Input text                          //*[@name='NameUa']    ${procuringEntity_name}
  #Input text                          //*[@name='RegionUa']    ${region}
  #Input text                          //*[@name='AddressUa']    ${streetAddress}
  Input text                          //*[@name='ZipCode']    ${postalCode}

  Input text                          //*[@name='ContactPhoneNumber']    ${contactPointName}

  Input text                          //*[@name='ContactPhoneNumber']    ${contactPointTelephone}
  Input text                          //*[@name='ContactMobilePhoneNumber']    ${contactPointTelephone}
  Input text                          //*[@name='ContactFaxNumber']    ${contactPointTelephone}

  Click Element   //*[text() = 'Зберегти']
  Click Element   //*[@class='log']

Внести зміни в тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  #Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  #torgua.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Selenium2Library.Switch Browser     ${ARGUMENTS[0]}

  Wait Until Page Contains Element  id=content

  #Click Element                       //*[@class='log']
  #Click Element                       //*[text()='Мої закупівлі']
  #Click Element                       //*[text()='${ARGUMENTS[1]}']//ancestor::*[3]//*[@class='glyphicon glyphicon-pencil']

  #${tender_status}=  Get Text  xpath=//*[@id="mForm:data:status"]
  #${new_description}=  Convert To String   'Новое описания тендера'
  #Run Keyword If  '${tender_status}' == 'Період уточнень'  Input text  xpath=//*[@id="mForm:data:desc"]  ${new_description}

  #Input text                          //textarea[@name='description']     ${new_description}
  #Click Element                       //*[text()='Зберегти']
  #Sleep  10
  #Capture Page Screenshot
  #Click Element                       //*[text()='Мої закупівлі']
  #Click Element                       //*[text()='${ARGUMENTS[1]}']//ancestor::*[3]//*[@class='glyphicon glyphicon-pencil']

Задати питання до лоту
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = tenderUaId
  ...      ${ARGUMENTS[2]} = lot_id
  ...      ${ARGUMENTS[3]} = question

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  torgua.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Click Element  xpath=//a[text()='Обговорення']
  Click Element   xpath=//select[@name='questionOf']//option[@value='lot']
  Input text  name=title  ${ARGUMENTS[3]}
  Input text  name=description  ${ARGUMENTS[3]}
  Click Element  name=add-question

Відповісти на питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} = 0
  ...      ${ARGUMENTS[3]} = answer_data
  ${answer}=     Get From Dictionary  ${ARGUMENTS[3].data}  answer
  torgua.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Click Element                         xpath=//*[text()='Обговорення ']
  Sleep     4
  #Click Element                         xpath=//a[contains(@id, 'add_answer_btn_0')]
  #Sleep     4
  Input Text                            xpath=//*[@class='media well'][1]//*[@name='answer']        ${answer}
  Click Element                         xpath=//*[@class='media well'][1]//*[text()='Відповісти']

Задати питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderUaId
  ...      ${ARGUMENTS[2]} ==  questionId
  ${title}=        Get From Dictionary  ${ARGUMENTS[2].data}  title
  ${description}=  Get From Dictionary  ${ARGUMENTS[2].data}  description

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  torgua.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Click Element                       xpath=//*[text()='Обговорення ']
  Input text                          xpath=//*[@name='title']                 ${title}
  Input text                          xpath=//textarea[@name='description']                 ${description}
  Click Element                       xpath=//*[@name='add-question']

Подати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${test_bid_data}
  ${amount}=    Get From Dictionary     ${ARGUMENTS[2].data.value}         amount
  sleep  60
  torgua.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  sleep  15
  Click Element                     xpath=//*[@class='lots_comments']//button
  Input text    xpath=//input[@name='value:amount']                  ${amount}
  Click Element                     xpath=//*[@name='cq']
  Click Element                     xpath=//*[@name='ce']
  Click Element                     xpath=//button[text()='Подати заявку']

Змінити цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${test_bid_data}
  torgua.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Sleep    5
  Input text    xpath=//input[@name='amount']        510
  Sleep    3
  Click Element                      xpath=//div[3]/button

Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderId
  Switch browser   ${ARGUMENTS[0]}
  Go To  ${USERS.users['${ARGUMENTS[0]}'].homepage}
  Wait Until Page Contains Element  id=content
  Click Element  xpath=.//*[@class='dropdown-toggle']
  Click Element  xpath=//a[text()='Закупівлі']
  Input text  name=q  ${ARGUMENTS[1]}
  Click Element  xpath=//button[contains(text(), 'Пошук')]
  Click Element  xpath=.//*[@class='row lots']/a
  Wait Until Page Contains Element  id=content

Отримати посилання на аукціон для глядача
  [Arguments]  ${user}  ${tenderId}
  ${AuctionUrl} = torgua.Отримати посилання на аукціон ${user} ${tenderId}
  [return]  ${AuctionUrl}

Отримати посилання на аукціон для учасника
  [Arguments]  ${user}  ${tenderId}
  ${AuctionUrl} = torgua.Отримати посилання на аукціон ${user} ${tenderId}
  [return]  ${AuctionUrl}

Отримати посилання на аукціон
  [Arguments]  ${user}  ${tenderId}
  torgua.Пошук тендера по ідентифікатору ${user} ${tenderId}
  {AuctionUrl} = ${url} = Get Element Attribute xpath=(//div[@class='btn-defauld-torg tender']//a)@href
  xpath=(//table[@class='clean-table']/tbody/tr[4]/td/a)[1]@href
  #{AuctionUrl} = torgua.отримати інформацію про AuctionUrl
  [return] {AuctionUrl}

Оновити сторінку з тендером
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = tenderUaId

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  torgua.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Reload Page

отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  fieldname
  Switch browser   ${ARGUMENTS[0]}
  Run Keyword And Return  Отримати інформацію про ${ARGUMENTS[1]}

Отримати текст із поля і показати на сторінці
  [Arguments]   ${fieldname}
  sleep  1
  ${return_value}=   Get Text  ${locator.${fieldname}}
  [return]  ${return_value}

отримати інформацію про title
  ${title}=   Отримати текст із поля і показати на сторінці   title
  [return]  ${title}

отримати інформацію про AuctionUrl
  ${auctionUrl}=   Отримати текст із поля і показати на сторінці   auctionUrl
  [return]  ${auctionUrl}

отримати інформацію про description
  ${description}=   Отримати текст із поля і показати на сторінці   description
  [return]  ${description}

отримати інформацію про tenderId
  ${tenderId}=   Отримати текст із поля і показати на сторінці   tenderId
  [return]  ${tenderId}

отримати інформацію про value.amount
  ${valueAmount}=   Отримати текст із поля і показати на сторінці   value.amount
  ${valueAmount}=   Convert To Number   ${valueAmount.split(' ')[0]}
  [return]  ${valueAmount}

отримати інформацію про minimalStep.amount
  ${minimalStepAmount}=   Отримати текст із поля і показати на сторінці   minimalStep.amount
  ${minimalStepAmount}=   Convert To Number   ${minimalStepAmount.split(' ')[0]}
  [return]  ${minimalStepAmount}

Отримати інформацію про awards[1].complaintPeriod.endDate
  ${awardComplaintPeriodEndDate}=   Отримати текст із поля і показати на сторінці awards[1].complaintPeriod.endDate
  [return]  ${awardComplaintPeriodEndDate}

Отримати інформацію про items[1].description
  ${itemDescription}=   Отримати текст із поля і показати на сторінці   awards[1].complaintPeriod.description
  [return]  ${itemDescription}

отримати інформацію про enquiryPeriod.endDate
  ${enquiryPeriodEndDate}=   Отримати текст із поля і показати на сторінці   enquiryPeriod.endDate
  ${enquiryPeriodEndDate}=   polonex_convertdate   ${enquiryPeriodEndDate}
  [return]  ${enquiryPeriodEndDate}

отримати інформацію про tenderPeriod.endDate
  ${tenderPeriodEndDate}=   Отримати текст із поля і показати на сторінці   tenderPeriod.endDate
  ${tenderPeriodEndDate}=   polonex_convertdate    ${tenderPeriodEndDate}
  [return]  ${tenderPeriodEndDate}

отримати інформацію про items[0].deliveryAddress.countryName
  ${countryName}=   Отримати текст із поля і показати на сторінці   items[0].deliveryAddress.countryName
  [return]  ${countryName}

отримати інформацію про items[0].classification.scheme
  #${classificationScheme}=   Отримати текст із поля і показати на сторінці   items[0].classification.scheme
  [return]  CPV

отримати інформацію про items[0].additionalClassifications[0].scheme
  #${additionalClassificationsScheme}=   Отримати текст із поля і показати на сторінці   items[0].additionalClassifications[0].scheme
  [return]  ДКПП

отримати інформацію про questions[0].title
  sleep  1
  Click Element                       //*[@aria-controls='questions']
  ${questionsTitle}=   Отримати текст із поля і показати на сторінці   questions[0].title
  ${questionsTitle}=   Convert To Lowercase   ${questionsTitle}
  [return]  ${questionsTitle.capitalize().split('.')[0] + '.'}

отримати інформацію про questions[0].description
  ${questionsDescription}=   Отримати текст із поля і показати на сторінці   questions[0].description
  [return]  ${questionsDescription}

отримати інформацію про questions[0].date
  ${questionsDate}=   Отримати текст із поля і показати на сторінці   questions[0].date
  log  ${questionsDate}
  [return]  ${questionsDate}

отримати інформацію про questions[0].answer
  sleep  1
  #Click Element                       xpath=//a[@class='reverse tenderLink']
  #sleep  1
  Click Element                       xpath=//*[text() = 'Обговорення ']
  ${questionsAnswer}=   Отримати текст із поля і показати на сторінці   questions[0].answer
  [return]  ${questionsAnswer}

отримати інформацію про items[0].deliveryDate.endDate
  ${deliveryDateEndDate}=   Отримати текст із поля і показати на сторінці   items[0].deliveryDate.endDate
  ${deliveryDateEndDate}=   polonex_convertdate    ${deliveryDateEndDate}
  [return]  ${deliveryDateEndDate}

отримати інформацію про items[0].classification.id
  ${classificationId}=   Отримати текст із поля і показати на сторінці   items[0].classification.id
  [return]  ${classificationId}

отримати інформацію про items[0].classification.description
  ${classificationDescription}=   Отримати текст із поля і показати на сторінці     items[0].classification.description
  Run Keyword And Return If  '${classificationDescription}' == 'Картонки'    Convert To String  Cartons
  [return]  ${classificationDescription}

отримати інформацію про items[0].additionalClassifications[0].id
  ${additionalClassificationsId}=   Отримати текст із поля і показати на сторінці     items[0].additionalClassifications[0].id
  [return]  ${additionalClassificationsId}

отримати інформацію про items[0].additionalClassifications[0].description
  ${additionalClassificationsDescription}=   Отримати текст із поля і показати на сторінці     items[0].additionalClassifications[0].description
  [return]  ${additionalClassificationsDescription}

отримати інформацію про items[0].quantity
  ${itemsQuantity}=   Отримати текст із поля і показати на сторінці     items[0].quantity
  ${itemsQuantity}=   Convert To Integer    ${itemsQuantity}
  [return]  ${itemsQuantity}

отримати інформацію про items[0].unit.code
  ${unitCode}=   Отримати текст із поля і показати на сторінці     items[0].unit.code
  Run Keyword And Return If  '${unitCode}'== 'KGM (кілограми)'   Convert To String  KGM
  [return]  ${unitCode}

отримати інформацію про items[0].unit.name
  ${unitName}=   Отримати текст із поля і показати на сторінці     items[0].unit.name
  Run Keyword And Return If  '${unitName}' == 'KGM (кілограми)'    Convert To String  кілограми
  [return]  ${unitName}

Отримати інформацію про value.currency
  ${valueCurrency}=   Отримати текст із поля і показати на сторінці     value.currency
  [return]  ${valueCurrency}

Отримати інформацію про value.valueAddedTaxIncluded
  ${valueAddedTaxIncluded}=   Отримати текст із поля і показати на сторінці     value.valueAddedTaxIncluded
  Run Keyword And Return If  '${valueAddedTaxIncluded}'=='з ПДВ'   Convert To boolean  True
  [return]  ${valueAddedTaxIncluded}

Отримати інформацію про items[0].description
  ${itemsDescription}=   Отримати текст із поля і показати на сторінці     items[0].description
  [return]  ${itemsDescription}

отримати інформацію про procuringEntity.name
  ${procuringEntityName}=   Отримати текст із поля і показати на сторінці     procuringEntity.name
  [return]  ${procuringEntityName}

отримати інформацію про enquiryPeriod.startDate
  ${procuringEntityName}=   Отримати текст із поля і показати на сторінці     enquiryPeriod.startDate
  [return]  ${procuringEntityName}

отримати інформацію про tenderPeriod.startDate
  ${procuringEntityName}=   Отримати текст із поля і показати на сторінці     tenderPeriod.startDate
  [return]  ${procuringEntityName}

отримати інформацію про items[0].deliveryLocation.longitude
  ${deliveryLocationLongitude}=   Отримати текст із поля і показати на сторінці     items[0].deliveryLocation.longitude
  #${deliveryLocationLongitude}=   Convert To Number     ${deliveryLocationLongitude}
  #Run Keyword And Return  Convert To Number   ${deliveryLocationLongitude}
  [return]  ${deliveryLocationLongitude}

отримати інформацію про items[0].deliveryLocation.latitude
  ${deliveryLocationLatitude}=   Отримати текст із поля і показати на сторінці     items[0].deliveryLocation.latitude
  #${deliveryLocationLatitude}=   Convert To Number     ${deliveryLocationLatitude}
  #Run Keyword And Return  Convert To Number   ${deliveryLocationLatitude}
  [return]  ${deliveryLocationLatitude}

отримати інформацію про items[0].deliveryAddress.postalCode
  ${deliveryAddressPostalCode}=   Отримати текст із поля і показати на сторінці     items[0].deliveryAddress.postalCode
  [return]  ${deliveryAddressPostalCode}

отримати інформацію про items[0].deliveryAddress.locality
  ${deliveryAddressLocality}=   Отримати текст із поля і показати на сторінці     items[0].deliveryAddress.locality
  [return]  ${deliveryAddressLocality}

отримати інформацію про items[0].deliveryAddress.streetAddress
  ${deliveryAddressStreetAddress}=   Отримати текст із поля і показати на сторінці     items[0].deliveryAddress.streetAddress
  [return]  ${deliveryAddressStreetAddress}

отримати інформацію про items[0].deliveryAddress.region
  ${deliveryAddressRegion}=   Отримати текст із поля і показати на сторінці     items[0].deliveryAddress.region
  [return]  ${deliveryAddressRegion}
