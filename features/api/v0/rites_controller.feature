# language: ru
@api @rite @controller
Свойство: Правач чинов
   Предыстория:
      * єствує ѧзык "Русский" яко "ру"
      * єствує азбука "Российская" яко "РО"
      * є вид квѧзке чина "несвязан"
      * є чин сꙛ даными:
         | id              | 200001                                           |
         | language_code   | ру                                               |
         | alphabeth_code  | РО                                               |
         | title           | Чин                                              |
         | text            | Текст                                            |
         | abbreviation    | Аббр                                             |
         | bind_kind_rite  | несвязан                                         |
      * єствує памѧть "Памѧтно"
      * є чин сꙛ даными:
         | id              | 200012                                           |
         | language_code   | ру                                               |
         | alphabeth_code  | РО                                               |
         | title           | Гласно                                           |
         | text            | Текст                                            |
         | abbreviation    | Аббрб                                            |
         | bind_kind_rite  | несвязан                                         |
      * єствує сꙛбытие "Сꙛбытие" сꙛ озом "200201" ѫ памѧти "Памѧтно"
      * є чин сꙛ даными:
         | id              | 200013                                           |
         | language_code   | ру                                               |
         | alphabeth_code  | РО                                               |
         | title           | Звѫкъ                                            |
         | description     | Буковка                                          |
         | text            | Текст                                            |
         | abbreviation    | Аббрф                                            |
         | bind_kind_rite  | несвязан                                         |
      * єствує памѧть сꙛ даными:
         | id           | 101                                  |
         | short_name   | Памѧтна Ѫ                            |
         | title        | Титуло                               |
         | slug         | слуг                                 |
      * є чин сꙛ даными:
         | id              | 200014                                           |
         | language_code   | ру                                               |
         | alphabeth_code  | РО                                               |
         | title           | Гласно 1                                         |
         | text            | Текст                                            |
         | abbreviation    | Аббра                                            |
         | bind_kind_rite  | несвязан                                         |
      * єствує сꙛбытие "Сꙛбытие" сꙛ озом "200202" ѫ памѧти "Памѧтна Ѫ"
      * є чин сꙛ даными:
         | id              | 200015                                           |
         | language_code   | ру                                               |
         | alphabeth_code  | РО                                               |
         | title           | Гѫдьба                                           |
         | description     | Гѫдьба а꙯                                         |
         | text            | Текст                                            |
         | abbreviation    | Аббр1                                            |
         | bind_kind_rite  | несвязан                                         |
      * є письмо сꙛ даными:
         | id              | 200021                                           |
         | type            | Troparion                                        |
         | text            | Тропарь для чтения вслух чтобы наговорить        |
         | language_code   | ру                                               |
         | alphabeth_code  | РО                                               |
         | title           | Тропарь                                          |
         | description     | Тропарь для / чтения вслух // чтобы наговорити   |

   @get @collection @json
   Пример: Запрос к контроллеру чинов в АПИ при отсутствии чинов
      Пусть не єствує ни єдна чина
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/rites.json"
      То добѫдꙛ кодъ поврата "204"


   @get @collection @json
   Пример: Запрос к контроллеру чинов в АПИ
      Пусть сѫ "1" чинъ
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/rites.json"
      То добѫдꙛ кодъ поврата "200"

   @get @collection @json
   Пример: Користник добыває списъ чинов
      Если запытаю добыванје из изнахоѕи "/api/v0/rites.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200015
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title:
           abbreviation: Аббр1
         - id: 200014
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title: Гласно 1
           abbreviation: Аббра
         - id: 200013
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title:
           abbreviation: Аббрф
         - id: 200012
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title: Гласно
           abbreviation: Аббрб
         - id: 200001
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title: Чин
           abbreviation: Аббр
         """
      А добѫдꙛ охватъ "0-9/5"

   @get @collection @search @json
   Пример: Користник искає во спису чинов по чиновому едозу (єдином опозонавателю) во взору id
      Если запытаю добыванје из изнахоѕи "/api/v0/rites.json?uno=200012"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200012
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title: Гласно
           abbreviation: Аббрб
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @search @json
   Пример: Користник искає во спису чинов по чиновому едозу (єдином опозонавателю) в
 о взору скраченја
      Если запытаю добыванје из изнахоѕи "/api/v0/rites.json?uno=Аббра"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200014
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title: Гласно 1
           abbreviation: Аббра
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection @search @json
   Пример: Користник искає во спису чинов по ѧзыку
      Если запытаю добыванје из изнахоѕи "/api/v0/rites.json?l=Русский"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200015
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title:
           abbreviation: Аббр1
         - id: 200014
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title: Гласно 1
           abbreviation: Аббра
         - id: 200013
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title:
           abbreviation: Аббрф
         - id: 200012
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title: Гласно
           abbreviation: Аббрб
         - id: 200001
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title: Чин
           abbreviation: Аббр
         """
      А добѫдꙛ охватъ "0-9/5"

   @get @collection @search @json
   Пример: Користник искає во спису чинов по азбуцѣ
      Если запытаю добыванје из изнахоѕи "/api/v0/rites.json?a=Российская"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200015
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title:
           abbreviation: Аббр1
         - id: 200014
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title: Гласно 1
           abbreviation: Аббра
         - id: 200013
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title:
           abbreviation: Аббрф
         - id: 200012
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title: Гласно
           abbreviation: Аббрб
         - id: 200001
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title: Чин
           abbreviation: Аббр
         """
      А добѫдꙛ охватъ "0-9/5"

   @get @collection @search @json
   Пример: Користник искає во спису личинок по памѧтному едозу
      Если запытаю добыванје из изнахоѕи "/api/v0/rites.json?a=Английская"
      То добѫдꙛ кодъ поврата "204"
      И добѫдꙛ пустъ выводъ
      А добѫдꙛ охватъ "0-9/0"

   @get @collection @json
   Пример: Запрос постраничный к контроллеру чинов в АПИ
      Пусть сѫ чини:
         """
         ---
         - id: 200004
           language_code: ру
           alphabeth_code: РО
           title: Титуло
           description: Описалово
           abbreviation: Аббрнов
         """
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/rites.json" сꙛ доводом "per=3"
      То добѫдꙛ кодъ поврата "206"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200004
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title: Титуло
           abbreviation: Аббрнов
         - id: 200015
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title:
           abbreviation: Аббр1
         - id: 200014
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title: Гласно 1
           abbreviation: Аббра
         """
      А добѫдꙛ охватъ "0-2/6"
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/rites.json" сꙛ доводом "per=3&p=2"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - id: 200013
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title:
           abbreviation: Аббрф
         - id: 200012
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title: Гласно
           abbreviation: Аббрб
         - id: 200001
           language: Русский
           language_code: ру
           alphabeth: Российская
           alphabeth_code: РО
           title: Чин
           abbreviation: Аббр
         """
      А добѫдꙛ охватъ "3-5/6"
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/rites.json" сꙛ доводом "per=3&p=3"
      То добѫдꙛ кодъ поврата "416"

   @get @collection @error @416 @json
   Пример: Запрос к контроллеру чинов в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/rites.json" сꙛ доводом "page=111111"
      То добѫдꙛ кодъ поврата "416"
      И добѫдꙛ приблизнъ изводъ:
         """
         ---
         args:
           page: '111111'
         """

   @get @collection @error @416 @json
   Пример: Запрос к контроллеру чинов в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v0/rites.json" сꙛ заглавјем:
         """
         ---
         Range: records=100000-200000
         """
      То добѫдꙛ кодъ поврата "416"
      И добѫдꙛ приблизнъ изводъ:
         """
         ---
         """

   @create @object @xform
   Пример: Користник створяє чинъ
      Если запытаю створенје изнахоѕи чина "/api/v0/rites/create.json" сꙛ даными:
         | id              | 200016                                           |
         | language        | Русский                                          |
         | alphabeth       | Российская                                       |
         | title           | Титу                                             |
         | description     | Опи                                              |
         | text            | Текст                                            |
         | abbreviation    | Аббр2                                            |
         | bind_kind_rite  | несвязан                                         |
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         id: 200016
         language: Русский
         language_code: ру
         alphabeth: Российская
         alphabeth_code: РО
         title: Титу
         description: Опи
         abbreviation: Аббр2
         text: Текст
         bind_kind_rite: несвязан
         bond_to_uno:
         root_uno:
         """
      И изнахоѕь чина "Аббр2" бѫдє яко:
         """
         ---
         id: 200016
         language_code: ру
         alphabeth_code: РО
         abbreviation: Аббр2
         text: Текст
         bind_kind_rite: несвязан
         """

   @create @object @error @422 @xform
   Пример: Користник кушає створити подвојну чинъ, и не можє
      Если запытаю створенје изнахоѕи чина "/api/v0/rites/create.json" сꙛ даными:
         | id              | 200017                                           |
         | language_code   | ру                                               |
         | alphabeth_code  | РО                                               |
         | title           | Гудьба                                           |
         | description     | Гудьба а                                         |
         | text            | Текст                                            |
         | abbreviation    | Аббр1                                            |
         | bind_kind_rite  | несвязан                                         |
      То добѫдꙛ кодъ поврата "422"
      И добѫдꙛ выводъ:
         """
         ---
         errors:
         - Abbreviation has already been taken
         """
      А изнахоѕи чина "200017" не бѫдє

   @update @object @error @404 @xform
   Пример: Користник поновяє данє чинъ
      Если запытаю одсланје чинъ в изнаходь "/api/v0/rites/Аббр1.json" сꙛ даными:
         | id              | 200017                                           |
         | language_code   | ру                                               |
         | alphabeth_code  | РО                                               |
         | title           | Гудьба                                           |
         | description     | Гудьба а                                         |
         | text            | Текст                                            |
         | abbreviation    | Аббр1                                            |
         | bind_kind_rite  | несвязан                                         |
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         id: 200017
         language: Русский
         language_code: ру
         alphabeth: Российская
         alphabeth_code: РО
         title: Гудьба
         description: Гудьба а
         abbreviation: Аббр1
         text: Текст
         bind_kind_rite: несвязан
         bond_to_uno:
         root_uno:
         """
      Если запытаю добыванје из изнахоѕи "/api/v0/rites/200017.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         id: 200017
         language: Русский
         language_code: ру
         alphabeth: Российская
         alphabeth_code: РО
         title: Гудьба
         description: Гудьба а
         abbreviation: Аббр1
         text: Текст
         bind_kind_rite: несвязан
         bond_to_uno:
         root_uno:
         """
      Если запытаю добыванје из изнахоѕи "/api/v0/rites/200015.json"
      То добѫдꙛ кодъ поврата "404"

   @get @object @json
   Пример: Користник добыває данє чина
      Пусть є письмо сꙛ даными:
         | id              | 200020                                        |
         | type            | Scriptum                                      |
         | text            | Текст для чтения вслух чтобы наговорить       |
         | language_code   | ру                                            |
         | alphabeth_code  | РО                                            |
         | title           | Текст для чтения вслух чтобы наговорить       |
         | description     | Текст для / чтения вслух / чтобы наговорить   |
      Пусть є чин сꙛ даными:
         | id              | 200020                                           |
         | language_code   | ру                                               |
         | alphabeth_code  | РО                                               |
         | title           | Гласново                                         |
         | description     | описалово                                        |
         | text            | Текстово                                         |
         | abbreviation    | Аббрбк                                           |
         | bind_kind_rite  | несвязан                                         |    
      Если запытаю добыванје из изнахоѕи "/api/v0/rites/200020.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         id: 200020
         language: Русский
         language_code: ру
         alphabeth: Российская
         alphabeth_code: РО
         title: Гласново
         description: описалово
         abbreviation: Аббрбк
         text: Текстово
         bind_kind_rite: несвязан
         bond_to_uno:
         root_uno:
         """

   @get @object @json
   Пример: Користник добыває данє чина
      Если запытаю добыванје из изнахоѕи "/api/v0/rites/Аббрф.json"
      То добѫдꙛ выводъ:
         """
         ---
         id: 200013
         language: Русский
         language_code: ру
         alphabeth: Российская
         alphabeth_code: РО
         title:
         description: Буковка
         abbreviation: Аббрф
         text: Текст
         bind_kind_rite: несвязан
         bond_to_uno:
         root_uno:
         """

   @delete @object @json
   Пример: Користник изтьрає иззначенє чинъ
      Если чин "Аббр1" єствує
      И запытаю изтрѣнје изнахоѕи "/api/v0/rites/200015.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         id: 200015
         language: Русский
         language_code: ру
         alphabeth: Российская
         alphabeth_code: РО
         title:
         description:
         abbreviation: Аббр1
         text: Текст
         bind_kind_rite: несвязан
         bond_to_uno:
         root_uno:
         """
      И чин "Аббр1" не будє єствовати

   @get @collection @error @json
   Пример: Запрос к контроллеру чинов в АПИ при отсутствии чинов
      Пусть не єствує ни єдна чина
      Если покушаю створити "GET" запытъ до адреса "/api/v0/rites.jsonp"
      То не добѫдꙛ кодъ поврата
      А вывода не бѫдє
