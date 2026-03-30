# language: ru
@api @event @controller
Свойство: Правач сꙛбытєв
   Предыстория:
      * єствує ѧзык "Русский" яко "ру"
      * єствує азбука "Русская" яко "РУ"
      * єствує ѧзык "Всисловенский" яко "вс"
      * єствує азбука "Всисловенщина" яко "НЦ"
      * єствує взор сꙛбытя "Сꙛбытя взор" яко "Event"
      * єствує памѧть сꙛ даными:
         | id                 | 100100                               |
         | language_code      | вс                                   |
         | alphabeth_code     | НЦ                                   |
         | short_name         | Памѧть                               |
         | without_events     | true                                 |
      * єствує памѧть сꙛ даными:
         | id                 | 100101                               |
         | language_code      | ру                                   |
         | alphabeth_code     | РУ                                   |
         | short_name         | Память                               |
         | without_events     | true                                 |
      * єствує сꙛбытє сꙛ даными:
         | id                 | 200201                               |
         | title              | Событье                              |
         | description        | Описалово Событья                    |
         | kind_code          | Event                                |
         | language_code      | ру                                   |
         | alphabeth_code     | РУ                                   |
         | happened_at        | "1001"                               |
         | memory_short_name  | Память                               |
      * єствує сꙛбытє сꙛ даными:
         | id                 | 200202                               |
         | title              | Сꙛбытје                              |
         | description        | Описалово Сꙛбытјя                    |
         | kind_code          | Event                                |
         | language_code      | вс                                   |
         | alphabeth_code     | НЦ                                   |
         | happened_at        | "2002"                               |
         | memory_short_name  | Памѧть                               |
      * сꙛбуке для правача сѫ таковы:
         | language        | ру                                   |
         | alphabeth       | РУ                                   |

   @get @collection @json
   Пример: Запрос к правачу сꙛбытєв в АПИ при отсутствии сꙛбытєв
      Пусть не єствує ни єдне сꙛбытя
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/events.json"
      То добѫдꙛ кодъ поврата "204"

   @get @collection @json
   Пример: Користник добыває списъ сꙛбытєв
      Если запытаю добыванје из изо "/api/v0/events.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200201
           title: Событье
           description: Описалово Событья
           memory_short_name: Память
           happened_at: '1001'
           kind_code: Event
         - id: 200202
           title:
           description:
           memory_short_name:
           happened_at: '2002'
           kind_code: Event
         """
      А добѫдꙛ охватъ "0-9/2"

   @get @collection @search @json
   Пример: Користник искає во спису сꙛбытєв по сꙛбытну опозонавателю
      Если запытаю добыванје из изо "/api/v0/events.json?id=200201"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200201
           title: Событье
           description: Описалово Событья
           memory_short_name: Память
           happened_at: '1001'
           kind_code: Event
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @search @json
   Пример: Користник искає во спису сꙛбытєв по типу
      Если запытаю добыванје из изо "/api/v0/events.json?q=Событье"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200201
           title: Событье
           description: Описалово Событья
           memory_short_name: Память
           happened_at: '1001'
           kind_code: Event
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @search @json
   Пример: Користник искає во спису сꙛбытєв по заглавку
      Если запытаю добыванје из изо "/api/v0/events.json?l=ру"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200201
           title: Событье
           description: Описалово Событья
           memory_short_name: Память
           happened_at: '1001'
           kind_code: Event
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @search @json
   Пример: Користник искає во спису сꙛбытєв по взору сꙛбытя
      Если сꙛбуке для правача сѫ таковы:
         | language        | вс                                   |
         | alphabeth       | НЦ                                   |
      И запытаю добыванје из изо "/api/v0/events.json?a=РУ"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200201
           title:
           description:
           memory_short_name:
           happened_at: '1001'
           kind_code: Event
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @search @json
   Пример: Користник искає во спису сꙛбытєв по взору сꙛбытя
      Если запытаю добыванје из изо "/api/v0/events.json?a=ДР&l=ру"
      То добѫдꙛ кодъ поврата "204"
      И добѫдꙛ пустъ выводъ
      А добѫдꙛ охватъ "0-9/0"

   @get @collection @search @json
   Пример: Користник искає во спису сꙛбытєв по типу и взору сꙛбытя
      Если запытаю добыванје из изо "/api/v0/events.json?q=Сꙛбытье&a=ДР"
      То добѫдꙛ кодъ поврата "204"
      И добѫдꙛ пустъ выводъ
      А добѫдꙛ охватъ "0-9/0"

   @get @collection @json
   Пример: Запрос постраничный к правачу сꙛбытєв в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/events.json" сꙛ доводом "per=1"
      То добѫдꙛ кодъ поврата "206"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200202
           title:
           description:
           memory_short_name:
           happened_at: '2002'
           kind_code: Event
         """
      А добѫдꙛ охватъ "0-0/2"
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/events.json" сꙛ доводом "per=1&p=2"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200201
           title: Событье
           description: Описалово Событья
           memory_short_name: Память
           happened_at: '1001'
           kind_code: Event
         """
      А добѫдꙛ охватъ "1-1/2"
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/events.json" сꙛ доводом "per=1&p=3"
      То добѫдꙛ кодъ поврата "416"

   @get @collection @json @error @416
   Пример: Запрос к правачу сꙛбытєв в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/events.json" сꙛ доводом "page=111111"
      То добѫдꙛ кодъ поврата "416"
      И добѫдꙛ приблизнъ изводъ:
         """
         ---
         args:
           page: '111111'
         """

   @get @collection @json @error @416
   Пример: Запрос к правачу сꙛбытєв в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/events.json" сꙛ заглавјем:
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
   Пример: Користник створяє сꙛбытё
      Если сꙛбуке для правача сѫ таковы:
         | language        | вс                                   |
         | alphabeth       | НЦ                                   |
      Если запытаю створенје изо сꙛбытя "/api/v0/events/create.json" сꙛ даными:
         | id                 | 200203                               |
         | title              | Сꙛбытје                              |
         | description        | Описалово Сꙛбытјя                    |
         | kind_code          | Event                                |
         | language_code      | вс                                   |
         | alphabeth_code     | НЦ                                   |
         | happened_at        | "2002"                               |
         | memory_short_name  | Памѧть                               |
      То добѫдꙛ кодъ поврата "200"
      А сѫбуке сѫ таковы:
         | language        | вс                                   |
         | alphabeth       | НЦ                                   |
      И изнахоѕь сꙛбытя "200203" бѫдє яко:
         """
         ---
         id: 200203
         happened_at: 2002
         memory_id: 100100
         kind_code: Event
         memory_short_name: Памѧть
         description: Описалово Сꙛбытјя
         """

   @create @object @json @error @422
   Пример: Користник кушає створити погрѣшну сꙛбытё во вымолву, и не можє
      Если запытаю створенје изо сꙛбытя "/api/v0/events/create.json" сꙛ даными:
         | id                 | 200203                               |
         | title              | wrong                                |
         | description        | Описалово Сꙛбытјя                    |
         | kind_code          | Event                                |
         | language_code      | ру                                   |
         | alphabeth_code     | РУ                                   |
         | happened_at        | "2002"                               |
         | memory_short_name  | Памятя                               |
      То добѫдꙛ кодъ поврата "422"
      А сѫбуке сѫ таковы:
         | language        | ру                                   |
         | alphabeth       | РУ                                   |
      И добѫдꙛ выводъ:
         """
         ---
         status: 422
         errors:
         - Titles text contains invalid char(s) "gnorw" for the specified alphabeth "РУ"
         - Titles is invalid
         - Memory can't be blank
         """
      А изнахоѕи сꙛбытя "10003" не бѫдє

   @create @object @json @error @422
   Пример: Користник кушає створити погрѣшну сꙛбытё во заглавку, и не можє
      Если запытаю створенје изо сꙛбытя "/api/v0/events/create.json" сꙛ даными:
         | id                 | 200203                               |
         | title              | wrong                                |
         | description        | Описалово Событія                    |
         | kind_code          | Event                                |
         | language_code      | ру                                   |
         | alphabeth_code     | РУ                                   |
         | happened_at        | "2002"                               |
         | memory_short_name  | Память                               |
      То добѫдꙛ кодъ поврата "422"
      А сѫбуке сѫ таковы:
         | language        | ру                                   |
         | alphabeth       | РУ                                   |
      И добѫдꙛ выводъ:
         """
         ---
         status: 422
         errors:
         - Titles text contains invalid char(s) "gnorw" for the specified alphabeth "РУ"
         - Titles is invalid
         """
      А изнахоѕи сꙛбытя "10003" не бѫдє

   @create @object @json @error @200
   Пример: Користник кушає створити волне сꙛбытё во описаню, и можє
      Если запытаю створенје изо сꙛбытя "/api/v0/events/create.json" сꙛ даными:
         | id                 | 200203                               |
         | title              | Титуля                               |
         | description        | not wrong                            |
         | kind_code          | Event                                |
         | language_code      | ру                                   |
         | alphabeth_code     | РУ                                   |
         | happened_at        | "2002"                               |
         | memory_short_name  | Память                               |
      То добѫдꙛ кодъ поврата "200"
      А сѫбуке сѫ таковы:
         | language        | ру                                   |
         | alphabeth       | РУ                                   |
      И добѫдꙛ выводъ:
         """
         ---
         id: 200203
         title: Титуля
         description: not wrong
         memory_short_name: Память
         happened_at: '2002'
         kind_code: Event
         """
      А изнахоѕь сꙛбытя "200203" бѫдє єствовати

   @update @object @json @error @404
   Пример: Користник поновяє дане сꙛбытя
      Если сѫбуке сѫ таковы:
         | language        | ру                                   |
         | alphabeth       | РУ                                   |
      И запытаю одсланје сꙛбытя в изнаходь "/api/v0/events/200201.json" сꙛ даными:
         | id                 | 200203                               |
         | title              | Титуля                               |
         | description        | not wrong                            |
         | kind_code          | Event                                |
         | language_code      | ру                                   |
         | alphabeth_code     | РУ                                   |
         | happened_at        | "2002"                               |
         | memory_short_name  | Память                               |
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         id: 200201
         title: Титуля
         description: not wrong
         memory_short_name: Память
         happened_at: '2002'
         kind_code: Event
         """
      Если запытаю добыванје из изо "/api/v0/events/200201.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         id: 200201
         title: Титуля
         description: not wrong
         memory_short_name: Память
         happened_at: '2002'
         kind_code: Event
         """
      Если запытаю добыванје из изо "/api/v0/events/200203.json"
      То добѫдꙛ кодъ поврата "404"

   @get @object @json
   Пример: Користник добыває дане сꙛбытя· иззначену озом
      Если сѫбуке сѫ таковы:
         | language        | ру                                   |
         | alphabeth       | РУ                                   |
      И запытаю добыванје из изо "/api/v0/events/200201.json"
      То добѫдꙛ выводъ:
         """
         ---
         id: 200201
         title: Событье
         description: Описалово Событья
         memory_short_name: Память
         happened_at: '1001'
         kind_code: Event
         """

   @delete @object @json
   Пример: Користник изтьрає иззначену озом сꙛбытё 
      Если сꙛбуке для правача сѫ таковы:
         | language        | вс                                   |
         | alphabeth       | НЦ                                   |
      И запытаю изтрѣнје изо "/api/v0/events/200202.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         id: 200202
         title: Сꙛбытје
         description: Описалово Сꙛбытјя
         memory_short_name: Памѧть
         happened_at: '2002'
         kind_code: Event
         """
      И изнахоѕи сꙛбытя "Мѣтаа" не бѫдє

   @get @collection @json @error
   Пример: Запрос к правачу сꙛбытєв в АПИ при отсутствии сꙛбытєв
      Пусть не єствує ни єдне сꙛбытя
      Если покушаю створити "GET" запытъ до адреса "/api/v0/events.jsonp"
      То не добѫдꙛ кодъ поврата
      А вывода не бѫдє
