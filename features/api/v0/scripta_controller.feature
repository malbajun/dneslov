# language: ru
@api @scriptum @controller
Свойство: Правач письм
   Предыстория:
      * єствує ѧзык "Русский" яко "ру"
      * єствує азбука "Русская азбука" яко "РУ"
      * єствує ѧзык "Древнерусский" яко "др"
      * єствує азбука "Древнерусская азбука" яко "ДР"
      * єствує ѧзык "Всисловенский" яко "вс"
      * єствує азбука "Всисловенщина" яко "НЦ"
      * єствує памѧть сꙛ даными:
         | id                 | 110100                               |
         | language_code      | вс                                   |
         | alphabeth_code     | НЦ                                   |
         | short_name         | Памѧть                               |
         | without_events     | true                                 |
      * єствує памѧть сꙛ даными:
         | id                 | 110101                               |
         | language_code      | ру                                   |
         | alphabeth_code     | РУ                                   |
         | short_name         | Память                               |
         | without_events     | true                                 |
      * єствує письмо сꙛ даными:
         | id                    | 210201                               |
         | title                 | Тропарь                              |
         | description           | Тропарь описалово                    |
         | type                  | Troparion                            |
         | language_code         | ру                                   |
         | alphabeth_code        | РУ                                   |
         | text                  | Текст тропаря                        |
         | hymnable_short_name   | Память                               |
         | author                | Автор тропаря                        |
         | ref_title             | Заглавь тропаря                      |
      * єствує письмо сꙛ даными:
         | id                    | 210202                               |
         | title                 | Кѫндак                               |
         | description           | Кѫндак описалово                     |
         | type                  | Kontakion                            |
         | language_code         | вс                                   |
         | alphabeth_code        | НЦ                                   |
         | text                  | Текст кѫндака                        |
         | hymnable_short_name   | Памѧть                               |
         | author                | Автор кѫндака                        |
         | ref_title             | Заглавь кѫндака                      |
      * сꙛбуке для правача сѫ таковы:
         | language              | ру                                   |
         | alphabeth             | РУ                                   |

   @get @collection @json
   Пример: Запрос к правачу письм в АПИ при отсутствии письм
      Пусть не єствує ни єдна письма
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/scripta.json"
      То добѫдꙛ кодъ поврата "204"

   @get @collection @json
   Пример: Користник добыває списъ письм
      Если запытаю добыванје из изо "/api/v0/scripta.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 210201
           title: Тропарь
           type: Troparion
           language_code: ру
           alphabeth_code: РУ
           bond_to_ref_title:
           root_ref_title: Тропарь
           resource_title:
         - id: 210202
           title: Кѫндак
           type: Kontakion
           language_code: вс
           alphabeth_code: НЦ
           bond_to_ref_title:
           root_ref_title: Кѫндак
           resource_title:
         """
      А добѫдꙛ охватъ "0-24/2"

   @get @collection @search @json
   Пример: Користник искає во спису письм по письмну опозонавателю
      Если запытаю добыванје из изо "/api/v0/scripta.json?uno=210201"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 210201
           title: Тропарь
           type: Troparion
           language_code: ру
           alphabeth_code: РУ
           bond_to_ref_title:
           root_ref_title: Тропарь
           resource_title:
         """
      А добѫдꙛ охватъ "0-24/1"

   @get @collection @search @json
   Пример: Користник искає во спису письм по запросу
      Если запытаю добыванје из изо "/api/v0/scripta.json?q=Тропарь"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 210201
           title: Тропарь
           type: Troparion
           language_code: ру
           alphabeth_code: РУ
           bond_to_ref_title:
           root_ref_title: Тропарь
           resource_title:
         """
      А добѫдꙛ охватъ "0-24/1"

   @get @collection @search @json
   Пример: Користник искає во спису письм по имени причѧстности письма
      Если запытаю добыванје из изо "/api/v0/scripta.json?q=Память"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 210201
           title: Тропарь
           type: Troparion
           language_code: ру
           alphabeth_code: РУ
           bond_to_ref_title:
           root_ref_title: Тропарь
           resource_title:
         """
      А добѫдꙛ охватъ "0-24/1"

   @get @collection @search @json
   Пример: Користник искає во спису письм по заглавку
      Если запытаю добыванје из изо "/api/v0/scripta.json?l=ру"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 210201
           title: Тропарь
           type: Troparion
           language_code: ру
           alphabeth_code: РУ
           bond_to_ref_title:
           root_ref_title: Тропарь
           resource_title:
         """
      А добѫдꙛ охватъ "0-24/1"

   @get @collection @search @json
   Пример: Користник искає во спису письм по взору письма
      Если сꙛбуке для правача сѫ таковы:
         | language        | вс                                   |
         | alphabeth       | НЦ                                   |
      И запытаю добыванје из изо "/api/v0/scripta.json?a=РУ"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 210201
           title: Тропарь
           type: Troparion
           language_code: ру
           alphabeth_code: РУ
           bond_to_ref_title:
           root_ref_title: Тропарь
           resource_title:
         """
      А добѫдꙛ охватъ "0-24/1"

   @get @collection @search @json
   Пример: Користник искає во спису письм по взору письма
      Если єствує письмо сꙛ даными:
         | id                    | 210203                               |
         | title                 | Кѡндак                               |
         | description           | Кѡндак описалово                     |
         | type                  | Kontakion                            |
         | language_code         | др                                   |
         | alphabeth_code        | ДР                                   |
         | text                  | Текст кѡндака                        |
         | hymnable_short_name   | Памѧть                               |
         | author                | Автор кѡндака                        |
         | ref_title             | Ꙁаглавь кѡндака                      |
      Если запытаю добыванје из изо "/api/v0/scripta.json?a=ДР&l=ру"
      То добѫдꙛ кодъ поврата "204"
      И добѫдꙛ пустъ выводъ
      А добѫдꙛ охватъ "0-24/0"

   @get @collection @search @json
   Пример: Користник искає во спису письм по типу и взору письма
      Если запытаю добыванје из изо "/api/v0/scripta.json?q=Кѫндак&a=ДР"
      То добѫдꙛ кодъ поврата "204"
      И добѫдꙛ пустъ выводъ
      А добѫдꙛ охватъ "0-24/0"

   @get @collection @json
   Пример: Запрос постраничный к правачу письм в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/scripta.json" сꙛ доводом "per=1"
      То добѫдꙛ кодъ поврата "206"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 210201
           title: Тропарь
           type: Troparion
           language_code: ру
           alphabeth_code: РУ
           bond_to_ref_title:
           root_ref_title: Тропарь
           resource_title:
         """
      А добѫдꙛ охватъ "0-0/2"
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/scripta.json" сꙛ доводом "per=1&p=2"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 210202
           title: Кѫндак
           type: Kontakion
           language_code: вс
           alphabeth_code: НЦ
           bond_to_ref_title:
           root_ref_title: Кѫндак
           resource_title:
         """
      А добѫдꙛ охватъ "1-1/2"
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/scripta.json" сꙛ доводом "per=1&p=3"
      То добѫдꙛ кодъ поврата "416"

   @get @collection @json @error @416
   Пример: Запрос к правачу письм в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/scripta.json" сꙛ доводом "page=111111"
      То добѫдꙛ кодъ поврата "416"
      И добѫдꙛ приблизнъ изводъ:
         """
         ---
         args:
           page: '111111'
         """

   @get @collection @json @error @416
   Пример: Запрос к правачу письм в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/scripta.json" сꙛ заглавјем:
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
   Пример: Користник створяє письмє
      Если сꙛбуке для правача сѫ таковы:
         | language           | др                                   |
         | alphabeth          | ДР                                   |
      Если запытаю створенје изо письма "/api/v0/scripta/create.json" сꙛ даными:
         | id                    | 210203                               |
         | title                 | Кѡндак                               |
         | description           | Кѡндак описалово                     |
         | type                  | Kontakion                            |
         | language_code         | др                                   |
         | alphabeth_code        | ДР                                   |
         | text                  | Текст кѡндака                        |
         | hymnable_short_name   | Памѧть                               |
         | author                | Автор кѡндака                        |
         | ref_title             | Ꙁаглавь кѡндака                      |
      То добѫдꙛ кодъ поврата "200"
      Если сѫбуке сѫ таковы:
         | language           | др                                   |
         | alphabeth          | ДР                                   |
      И изнахоѕь письма "210203" бѫдє яко:
         """
         ---
         id: 210203
         type: Kontakion
         language_code: др
         alphabeth_code: ДР
         text: Текст кѡндака
         author: Автор кѡндака
         root_ref_title: Кѡндак
         tone:
         title: Кѡндак
         root_id: 210203
         bind_kind_name: несвязана
         bond_to_id:
         bond_to_ref_title:
         prosomeion_id:
         prosomeion_ref_title:
         """


   @create @object @json @error @422
   Пример: Користник створяє письмє
      Если запытаю створенје изо письма "/api/v0/scripta/create.json" сꙛ даными:
         | id                    | 210203                               |
         | title                 | Кѡндак                               |
         | description           | Кѡндак описалово                     |
         | type                  | Kontakion                            |
         | language_code         | др                                   |
         | alphabeth_code        | ДР                                   |
         | hymnable_short_name   | Памѧть                               |
         | author                | Автор кѡндака                        |
         | ref_title             | Ꙁаглавь кѡндака                      |
      То добѫдꙛ кодъ поврата "422"
      А сѫбуке сѫ таковы:
         | language           | др                                   |
         | alphabeth          | ДР                                   |
      И добѫдꙛ выводъ:
         """
         ---
         status: 422
         errors:
         - Title contains invalid char(s) "ѡ" for the specified alphabeth "РУ"
         """
      А изнахоѕи письма "210203" не бѫдє


   @create @object @json @error @422
   Пример: Користник кушає створити погрѣшну письмє во вымолву, и не можє
      Если сꙛбуке для правача сѫ таковы:
         | language           | др                                   |
         | alphabeth          | ДР                                   |
      Если запытаю створенје изо письма "/api/v0/scripta/create.json" сꙛ даными:
         | id                    | 210203                               |
         | type                  |                                      |
         | text                  |                                      |
         | title                 |                                      |
         | description           | Кѡндак описалово                     |
         | language_code         | др                                   |
         | alphabeth_code        | ДР                                   |
         | hymnable_short_name   | Памѧть                               |
         | author                | Автор кѡндака                        |
         | ref_title             | Ꙁаглавь кѡндака                      |
      То добѫдꙛ кодъ поврата "422"
      А сѫбуке сѫ таковы:
         | language           | др                                   |
         | alphabeth          | ДР                                   |
      И добѫдꙛ выводъ:
         """
         ---
         status: 422
         errors:
         - Type can't be blank
         - Title can't be blank
         - Text can't be blank
         """
      А изнахоѕи письма "210203" не бѫдє


   @update @object @json @error @404
   Пример: Користник поновяє дане письма
      Если сѫбуке сѫ таковы:
         | language           | ру                                   |
         | alphabeth          | РУ                                   |
      И запытаю одсланје письма в изнаходь "/api/v0/scripta/210201.json" сꙛ даными:
         | id                    | 210203                               |
         | title                 | Кондак                               |
         | description           | Кондак описалово                     |
         | type                  | Kontakion                            |
         | language_code         | ру                                   |
         | alphabeth_code        | РУ                                   |
         | text                  | Текст кондака                        |
         | author                | Автор кондака                        |
         | ref_title             | Заглавь кондака                      |
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         id: 210201
         title: Кондак
         description: Кондак описалово
         author: Автор кондака
         type: Kontakion
         language_code: ру
         language: Русский
         alphabeth_code: РУ
         alphabeth: Русская азбука
         text: Текст кондака
         tone:
         bind_kind_name: несвязана
         bind_kind_humanized:
         bond_to_id:
         bond_to_ref_title:
         root_id: 210201
         root_ref_title: Кондак
         prosomeion_id:
         prosomeion_ref_title:
         resource_id:
         resource_title:
         target_events: []
         """
      Если запытаю добыванје из изо "/api/v0/scripta/210201.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         id: 210201
         title: Кондак
         description: Кондак описалово
         author: Автор кондака
         type: Kontakion
         language_code: ру
         language: Русский
         alphabeth_code: РУ
         alphabeth: Русская азбука
         text: Текст кондака
         tone:
         bind_kind_name: несвязана
         bind_kind_humanized:
         bond_to_id:
         bond_to_ref_title:
         root_id: 210201
         root_ref_title: Кондак
         prosomeion_id:
         prosomeion_ref_title:
         resource_id:
         resource_title:
         target_events: []
         """
      Если запытаю добыванје из изо "/api/v0/scripta/210203.json"
      То добѫдꙛ кодъ поврата "404"

   @get @object @json
   Пример: Користник добыває дане письма· иззначену озом
      Если сѫбуке сѫ таковы:
         | language           | ру                                   |
         | alphabeth          | РУ                                   |
      И запытаю добыванје из изо "/api/v0/scripta/210201.json"
      То добѫдꙛ выводъ:
         """
         ---
         id: 210201
         title: Тропарь
         description: Тропарь описалово
         author: Автор тропаря
         type: Troparion
         language_code: ру
         language: Русский
         alphabeth_code: РУ
         alphabeth: Русская азбука
         text: Текст тропаря
         tone:
         bind_kind_name: несвязана
         bind_kind_humanized:
         bond_to_id:
         bond_to_ref_title:
         root_id: 210201
         root_ref_title: Тропарь
         prosomeion_id:
         prosomeion_ref_title:
         resource_id:
         resource_title:
         target_events: []
         """

   @delete @object @json
   Пример: Користник изтьрає иззначену озом письмє 
      Если сꙛбуке для правача сѫ таковы:
         | language           | вс                                   |
         | alphabeth          | НЦ                                   |
      И запытаю изтрѣнје изо "/api/v0/scripta/210202.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         id: 210202
         title: Кѫндак
         type: Kontakion
         language_code: вс
         alphabeth_code: НЦ
         bond_to_ref_title:
         root_ref_title: Кѫндак
         resource_title:
         """
      И изнахоѕи письма "Мѣтаа" не бѫдє

   @get @collection @yaml
   Пример: Запрос к правачу письм в АПИ при отсутствии письм
      Пусть не єствує ни єдна письма
      Если покушаю створити "GET" запытъ до адреса "/api/v0/scripta.yaml"
      То не добѫдꙛ кодъ поврата
      А вывода не бѫдє

   @get @collection @json @error
   Пример: Запрос к правачу письм в АПИ при отсутствии письм
      Пусть не єствує ни єдна письма
      Если покушаю створити "GET" запытъ до адреса "/api/v0/scripta.jsonp"
      То не добѫдꙛ кодъ поврата
      А вывода не бѫдє
