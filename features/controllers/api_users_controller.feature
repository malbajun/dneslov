# language: ru
@api @user @controller @json
Свойство: Правач ужилов
   Предыстория:
      * є ужил сꙛ токнами и даными:
         | id           | 200001                                           |
         | password     | Picture8$                                        |
         | settings     | {name: "Ужил", last_name: "Пользов", sex: "m"}   |
      * є учетка для ужила "200001" сꙛ даными:
         | no           | uzsilo                                           |
         | type         | Account::Uid                                     |

   @get @collection
   Пример: Запрос к контроллеру ужилов в АПИ при отсутствии ужилов
      Пусть не єствує ни єдна ужила
      Если сдѣлаю "GET" запытъ до адреса "/api/v1/users.json"
      То добѫдꙛ кодъ поврата "204"


   @get @collection
   Пример: Запрос к контроллеру ужилов в АПИ
      Пусть сѫ "4" ужилов
      Если сдѣлаю "GET" запытъ до адреса "/api/v1/users.json"
      То добѫдꙛ кодъ поврата "200"

   @get @collection
   Пример: Користник добыває списъ ужилов
      Если запытаю добыванје из изнахоѕи "/api/v1/users.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         - uid: uzsilo#Account::Uid
           name:
         """
      А добѫдꙛ охватъ "0-9/1"

   @get @collection
   Пример: Запрос постраничный к контроллеру ужилов в АПИ
      Пусть сѫ ужили:
         """
         ---
         - id: 200002
           "no": uzsilo0@mail.ru
           type: Account::Email
           password: Picture8$
           settings: {name: "Ужил", last_name: "Пользов", sex: "m"}
         - id: 200003
           "no": uzsilo1@mail.ru
           type: Account::Email
           password: Picture8$
           settings: {name: "Ужил1", last_name: "Пользов1", sex: "f"}
         - id: 200004
           "no": uzsilo2
           type: Account::Uid
           password: Picture8$
           settings: {name: "Ужил2", last_name: "Пользов2", sex: "b"}
         """
      Если сдѣлаю "GET" запытъ до адреса "/api/v1/users.json" сꙛ доводом "per=3"
      То добѫдꙛ кодъ поврата "206"
      И добѫдꙛ приблизнъ изводъ:
         """
         ---
         - uid: "uzsilo#Account::Uid"
           name:
         - uid: "uzsilo0@mail.ru#Account::Email"
           name: uzsilo0@mail.ru
         - uid: "uzsilo1@mail.ru#Account::Email"
           name: uzsilo1@mail.ru
         """
      А добѫдꙛ охватъ "0-2/4"
      Если сдѣлаю "GET" запытъ до адреса "/api/v1/users.json" сꙛ доводом "per=3&page=2"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ приблизнъ изводъ:
         """
         ---
         - uid: "uzsilo2#Account::Uid"
           name:
         """
      А добѫдꙛ охватъ "3-5/4"

   @get @collection @error @416
   Пример: Запрос к контроллеру ужилов в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v1/users.json" сꙛ доводом "page=111111"
      То добѫдꙛ кодъ поврата "416"
      И добѫдꙛ приблизнъ изводъ:
         """
         ---
         args:
           page: '111111'
         """

   @get @collection @error @416
   Пример: Запрос к контроллеру ужилов в АПИ
      Если сдѣлаю "GET" запытъ до адреса "/api/v1/users.json" сꙛ заглавјем:
         """
         ---
         Range: records=100000-200000
         """
      То добѫдꙛ кодъ поврата "416"
      И добѫдꙛ приблизнъ изводъ:
         """
         ---
         args: {}
         """


   @create @object
   Пример: Користник створяє ужилъ
      Если мрозим час на "2024-01-14 05:15:55 +0300"
      И запытаю створенје изнахоѕи ужила "/api/v1/users/create.json" сꙛ даными:
         | no                    | uzsilo@mail.ru                                   |
         | type                  | Account::Email                                   |
         | password              | Picture8#                                        |
         | password_confirmation | Picture8#                                        |

      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         user_names: []
         descriptions: []
         accounts:
         - 'no': uzsilo@mail.ru
           type: Account::Email
           validated: false
         """
      И изнахоѕь ужила "uzsilo@mail.ru" бѫдє яко:
         """
         ---
         encrypted_password: 158e4a4ccd7d30d6672fc0ec9088b76e994918ff3222270ecb619283bc469dc6
         salt:
         last_login_at:
         last_active_at:
         """
      И завѣрям одсланје писма для ужила "uzsilo@mail.ru" сꙛ завѣрным токном
      И поновям дане наряде в "/api/v1/session.json" сꙛ завѣрным токном для ужила "uzsilo@mail.ru"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ приблизнъ изводъ:
         """
         ---
         session_token:
           type: Token::Session
           expires_at: '2024-01-14 06:15:55 +0300'
         refresh_token:
           type: Token::Refresh
           expires_at: '2024-02-14 05:15:55 +0300'
         """

   @create @object @error @422
   Пример: Користник кушає створити подвојнъ ужилъ, и не можє
      Если запытаю створенје изнахоѕи ужила "/api/v1/users/create.json" сꙛ даными:
         | no                    | uzsilo                                           |
         | type                  | Account::Uid                                     |
         | settings              | {name: "Ужня", last_name: "Пользця", sex: "f"}   |
         | password              | Picture8#                                        |
         | password_confirmation | Picture8#                                        |
      То добѫдꙛ кодъ поврата "422"
      И добѫдꙛ выводъ:
         """
         ---
         args: {}
         error:
         - Accounts no has already been taken
         """
      А изнахоѕи ужила "Ужил 1" не бѫдє
      И одсланја писма для ужила "Ужил 1" сꙛ завѣрным токном не бѫдє

   @create @object @error @422
   Пример: Користник кушає створити безлазинков ужилъ, и не можє
      Если запытаю створенје изнахоѕи ужила "/api/v1/users/create.json" сꙛ даными:
         | no              | uzsilo1                                          |
         | type            | Account::Uid                                     |
         | settings        | {name: "Ужня", last_name: "Пользця", sex: "f"}   |
         | password        | Picture8#                                        |
      То добѫдꙛ кодъ поврата "422"
      И добѫдꙛ выводъ:
         """
         ---
         args: {}
         error:
         - Encrypted password can't be blank
         """
      А изнахоѕи ужила "Ужил 1" не бѫдє
      И одсланја писма для ужила "uzsilo" сꙛ завѣрным токном не бѫдє

   @update @object @error @404
   Пример: Користник поновяє дане ужила
      Если запытаю одсланје ужила в изнаходь "/api/v1/users/uzsilo.json" сꙛ даными:
         | no              | uzsilo1                                          |
         | type            | Account::Uid                                     |
         | default_name    | имя                                              |
         | Authorization:  | Validate wwwwwww                                 |
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         user_names: []
         descriptions: []
         accounts:
         - 'no': uzsilo1
           type: Account::Uid
           validated: false
         """
      Если запытаю добыванје из изнахоѕи "/api/v1/users/uzsilo1.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         user_names: []
         descriptions: []
         accounts:
         - 'no': uzsilo1
           type: Account::Uid
           validated: false
         """
      Если запытаю добыванје из изнахоѕи "/api/v1/users/uzsilo.json"
      То добѫдꙛ кодъ поврата "404"

   @get @object
   Пример: Користник добыває дане ужила
      Если запытаю добыванје из изнахоѕи "/api/v1/users/uzsilo.json"
      То добѫдꙛ выводъ:
         """
         ---
         user_names: []
         descriptions: []
         accounts:
         - 'no': uzsilo
           type: Account::Uid
           validated: false
         """

   @delete @object
   Пример: Користник изтьрає иззначенъ ужилъ
      Если запытаю изтрѣнје изнахоѕи "/api/v1/users/uzsilo.json"
      То добѫдꙛ кодъ поврата "200"
      И добѫдꙛ выводъ:
         """
         ---
         user_names: []
         descriptions: []
         accounts:
         - 'no': uzsilo
           type: Account::Uid
           validated: false
         """
      И ужил "Ужил" не будє єствовати

   @get @collection @error
   Пример: Запрос к контроллеру ужилов в АПИ при отсутствии ужилов
      Пусть не єствує ни єдна ужила
      Если покушаю створити "GET" запытъ до адреса "/api/v1/users.jsonp"
      То не добѫдꙛ кодъ поврата
      А вывода не бѫдє
