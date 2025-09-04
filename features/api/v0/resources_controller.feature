# language: ru
@api @resource @controller
Свойство: Правач изнахоѕєј
   Предыстория:
      * єствує изнахоѕь сꙛ даными:
         | id              | 300100                               |
         | path            | Путь                                 |
         | props           | {'text': 'Текст'}                    |
         | title           | Титуло                               |
         | description     | Описалово                            |
         | resource_path   | features/fixtures/bee.mp3                                          |
      * єствує изнахоѕь сꙛ даными:
         | id              | 300101                               |
         | type            | Resource::Virtual                    |
         | path            | Путь1                                |
         | props           | {'text': 'Текст1'}                   |
         | title           | Титулово                             |
         | description     | Описало                              |
         | resource_path   | features/fixtures/ice_rock_drop.mp3  |

   @get @collection @json
   Пример: Запрос к контроллеру изнахоѕєј в ИЗО при отсутствии изнахоѕєј
      Пусть не єствує ни єдне изнахоѕи
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/resources.json"
      То добѫдꙛ кодъ поврата "204"

   @get @collection @json
   Пример: Користник добыває списъ изнахоѕєј
      Если запытаю добыванје из изо "/api/v0/resources.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 300101
           title: Титулово
           thumb_url:
           type: Resource::Virtual
         - id: 300100
           title: Титуло
           thumb_url:
           type: Resource
         """
      А добѫдꙛ охватъ "0-9/2"

   @get @collection @search @json
   Пример: Користник искає во спису изнахоѕєј по изнаходну опозонавателю
      Если запытаю добыванје из изо "/api/v0/resources.json?uno=300101"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 300101
           title: Титулово
           thumb_url:
           type: Resource::Virtual
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @search @json
   Пример: Користник искає во спису изнахоѕєј по типу
      Если запытаю добыванје из изо "/api/v0/resources.json?q=Титулово"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 300101
           title: Титулово
           thumb_url:
           type: Resource::Virtual
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @search @json
   Пример: Користник искає во спису изнахоѕєј по тыпу изнахоѕи
      Если запытаю добыванје из изо "/api/v0/resources.json?t=Resource"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 300100
           title: Титуло
           thumb_url:
           type: Resource
         """
      А добѫдꙛ охватъ "0-9/1"

   Пример: Користник искає во спису изнахоѕєј по описанју
      Если запытаю добыванје из изо "/api/v0/resources.json?d=Описалово"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 300100
           title: Титуло
           thumb_url:
           type: Resource
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @search @json
   Пример: Користник искає во спису изнахоѕєј по типу и взору изнахоѕи
      Если запытаю добыванје из изо "/api/v0/resources.json?t=Building&k=Kind"
      То добѫдꙛ кодъ поврата "204"
      И добѫдꙛ пустъ выводъ
      А добѫдꙛ охватъ "0-9/0"

   @get @collection @search @json
   Пример: Користник искає во спису изнахоѕєј по изнаходну едозу
      Если запытаю добыванје из изо "/api/v0/resources.json?uno=Титуло"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 300100
           title: Титуло
           thumb_url:
           type: Resource
         - id: 300101
           title: Титулово
           thumb_url:
           type: Resource::Virtual
         """
      А добѫдꙛ охватъ "0-9/2"

   @get @collection @json
   Пример: Запрос постраничный к контроллеру изнахоѕєј в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/resources.json" сꙛ доводом "per=1"
      То добѫдꙛ кодъ поврата "206"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 300101
           title: Титулово
           thumb_url:
           type: Resource::Virtual
         """
      А добѫдꙛ охватъ "0-0/2"
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/resources.json" сꙛ доводом "per=1&p=2"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 300100
           title: Титуло
           thumb_url:
           type: Resource
         """
      А добѫдꙛ охватъ "1-1/2"
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/resources.json" сꙛ доводом "per=1&p=3"
      То добѫдꙛ кодъ поврата "416"

   @get @collection @json @error @416
   Пример: Запрос к контроллеру изнахоѕєј в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/resources.json" сꙛ доводом "page=111111"
      То добѫдꙛ кодъ поврата "416"
      И добѫдꙛ приблизнъ изводъ:
         """
         ---
         args:
           page: '111111'
         """

   @get @collection @json @error @416
   Пример: Запрос к контроллеру изнахоѕєј в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/resources.json" сꙛ заглавјем:
         """
         ---
         Range: records=100000-200000
         """
      То добѫдꙛ кодъ поврата "416"
      И добѫдꙛ приблизнъ изводъ:
         """
         ---
         """


   @create @object @json
   Пример: Користник створяє изнахоѕѣ
      Если запытаю створенје изнахоѕи в изо "/api/v0/resources/create.json" сꙛ даными:
         | id              | 103                                  |
         | type            | Resource::Virtual                    |
         | path            | путь                                 |
         | props           | {"text":"Текст"}                     |
         | title           | Изнаходь 1                           |
         | description     | Описание                             |
         | language        | ру                                   |
         | alphabeth       | РО                                   |
         | resource_path   | features/fixtures/hey_cartoon.mp3    |
         | data            | цццц                                 |
      То добѫдꙛ кодъ поврата "200"
      И изо изнахоѕи "Изнаходь 1" бѫдє яко:
         """
         ---
         id: 103
         path: путь
         props:
           text: Текст
         type: Resource::Virtual
         thumb_url:
         data: !binary |-
           0YbRhtGG0YY=
         """

   @create @object @json @error @422
   Пример: Користник кушає створити погрѣшну изнахоѕѣ, и не можє
      Если запытаю створенје изнахоѕи в изо "/api/v0/resources/create.json" сꙛ даными:
         | id              | 103                                  |
         | type            | Resource::Virtual                    |
         | path            | путь                                 |
         | props           | {"text":"Текст"}                     |
         | title           | Изнаходь 1                           |
         | description     | Описание                             |
         | language        | ру                                   |
         | alphabeth       | РО                                   |
         | resource_path   |                                      |
         | data            | цццц                                 |
      То добѫдꙛ кодъ поврата "422"
      И добѫдꙛ выводъ:
         """
         ---
         errors:
         - Resource can't be blank
         """
      А изо изнахоѕи "103" не бѫдє

   @update @object @json @error @404
   Пример: Користник поновяє дане изнахоѕи
      Если запытаю одсланје изнахоѕи в изо "/api/v0/resources/300100.json" сꙛ даными:
         | id              | 103                                  |
         | type            | Resource::Virtual                    |
         | path            | путь                                 |
         | props           | {"text":"Текст"}                     |
         | title           | Изнаходь 1                           |
         | description     | Описание                             |
         | resource        | fake                                 |
         | language        | ру                                   |
         | alphabeth       | РО                                   |
         | data            | цццц                                 |
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         id: 300100
         title: Изнаходь 1
         description: Описание
         uri: blob:fake
         props:
           text: Текст
         path: путь
         type: Resource::Virtual
         digest: b5d54c39e66671c9731b9f471e585d8262cd4f54963f0c93082d8dcf334d4c78
         data: цццц
         thumb_url:
         """
      Если запытаю добыванје из изо "/api/v0/resources/300100.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         id: 300100
         title: Изнаходь 1
         description: Описание
         uri: blob:fake
         props:
           text: Текст
         path: путь
         type: Resource::Virtual
         digest: b5d54c39e66671c9731b9f471e585d8262cd4f54963f0c93082d8dcf334d4c78
         data: цццц
         thumb_url:
         """
      Если запытаю добыванје из изо "/api/v0/resources/103.json"
      То добѫдꙛ кодъ поврата "404"

   @get @object @json
   Пример: Користник добыває дане изо· иззначену краткꙛ именем
      Если запытаю добыванје из изо "/api/v0/resources/300100.json"
      То добѫдꙛ выводъ яко:
         """
         ---
         id: 300100
         title: Титуло
         description: Описалово
         props:
           text: Текст
         path: Путь
         type: Resource
         data: ''
         thumb_url:
         """

   @delete @object @json
   Пример: Користник изтьрає иззначену плашкој изо
      Если запытаю изтрѣнје изо "/api/v0/resources/300100.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ яко:
         """
         ---
         id: 300100
         title: Титуло
         description: Описалово
         props:
           text: Текст
         path: Путь
         type: Resource
         data: ''
         thumb_url:
         """
      И изнахоѕь "300100" не будє єствовати
      Если запытаю добыванје из изо "/api/v0/resources/300100.json"
      То добѫдꙛ кодъ поврата "404"

   @get @collection @json @error
   Пример: Запрос к контроллеру изнахоѕєј в АПИ при отсутствии изнахоѕєј
      Пусть не єствує ни єдне изнахоѕи
      Если покушаю створити "GET" запытъ до адреса "/api/v0/resources.jsonp"
      То не добѫдꙛ кодъ поврата
      А вывода не бѫдє
