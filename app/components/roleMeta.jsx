import { matchLanguages, matchAlphabeths, matchLetters, matchEmptyObject, matchCodes, matchEmptyCollection, matchValidJson } from 'matchers'
import { makeTweet, makeTitle, makeDescription } from 'makers'
import UrlRegexp from 'UrlRegexp'

export const roleMeta = {
   default: 'tweet',
   remoteNames: 'api/v1/roles',
   remoteName: 'role',
   title: 'Роли',
   new: 'Новая роль',
   update: 'Обнови роль',
   create: 'Создай роль',
   close: 'Закрой',
   remove: {
      title: 'Точно ли удалить роль %default?',
      yes: "Да"
   },
   row: {
      default: {
         title: 'thumb_up',
         value: (value) => { return value.default ? <i className='green small material-icons'>thumb_up</i> : "" },
      },
      tweet: {
         title: 'Сокращение',
         value: makeTweet,
         source: 'tweets',
      },
      permissions: {
         title: 'Разрешения',
         value: (value) => { return value.permissions.join(", ") },
      },
      members: {
         title: 'Членов',
         value: (value) => { return value.members.length },
      },
      title: {
         title: 'Заголовок',
         value: makeTitle,
         source: 'titles',
      },
      description: {
         title: 'Описание',
         value: makeDescription,
         source: 'descriptions',
      },
   },
   form: {
      id: {
         kind: 'hidden',
      },
      default: {
         kind: 'boolean',
         title: 'По-умолчанию',
         display_scheme: '12-4-3-3',
      },
      permissions: {
         kind: 'json',
         title: 'Разрешения',
         action: 'Добавь разрешение',
         display_scheme: '12-12-12-12',
         default: [], // default value
         validations: {
            'Минимум одно разрешение должно быть задана':  matchEmptyObject,
            'Текст имеет неверный формат JSON': matchValidJson
         }
      },
      tweets: {
         kind: 'collection',
         title: "Сокращения",
         action: "Добавь сокращение",
         filter: { type: "Tweet" },
         source: "descriptions",
         display_scheme: '12-12-12-12',
         validations: {
            "Должно быть задано как минимум одно сокращение": matchEmptyObject,
            "Языки в сокращеньях не могут совпадать": matchLanguages,
            "Азбуки в сокращеньях не могут совпадать": matchAlphabeths,
         },
         meta: {
            id: {
               kind: 'hidden',
            },
            text: {
               kind: 'text',
               title: 'Краткое имя',
               placeholder: 'Введи краткое имя',
               display_scheme: '12-12-6-6',
               subscribeTo: '@alphabeth_code',
               validations: {
                  "Краткое имя отсутствует": matchEmptyObject,
                  'Краткое имя содержит знаки вне перечня избранной азбуки': matchLetters,
                  "Пробелов и иных спецсимволов быть не должно": /\A\W\+\z/,
               }
            },
            language_code: {
               kind: 'dynamic',
               title: 'Язык',
               display_scheme: '12-6-3-3',
               pathname: 'short_subjects',
               humanized_name: 'language',
               context_value: { k: "Language" },
               key_name: 'value',
               value_name: 'key',
               placeholder: 'Начни ввод наименования языка...',
               subscribeTo: '@alphabeth_code',
               validations: {
                  'Избранный язык не соотвествует избранной азбуке': matchCodes,
                  'Язык из списка должен быть выбран': matchEmptyObject,
               }
            },
            alphabeth_code: {
               kind: 'dynamic',
               title: 'Азбука',
               display_scheme: '12-6-3-3',
               pathname: 'short_subjects',
               humanized_name: 'alphabeth',
               context_value: { k: "Alphabeth" },
               key_name: 'value',
               value_name: 'key',
               placeholder: 'Начни ввод наименования азбуки...',
               subscribeTo: '@language_code',
               validations: {
                  'Избранная азбука не соотвествует избранному языку': matchCodes,
                  'Азбука из списка должна быть выбрана': matchEmptyObject,
               }
            },
         }
      },
      titles: {
         kind: 'collection',
         title: 'Заголовки',
         action: 'Добавь заголовок',
         single: 'Заголовок',
         placeholder: 'Введи заголовок',
         display_scheme: '12-12-12-12',
         validations: {
            "Языки в заголовках не могут совпадать": matchLanguages,
            "Азбуки в заголовках не могут совпадать": matchAlphabeths,
            'Минимум один заголовок должен быть задан':  matchEmptyObject
         },
         meta: {
            id: {
               kind: 'hidden',
            },
            text: {
               kind: 'tale',
               title: 'Заголовок',
               placeholder: 'Введи заголовок',
               display_scheme: '12-12-12-12',
               subscribeTo: '@alphabeth_code',
               validations: {
                  "Заголовок отсутствует": matchEmptyObject,
                  'Заголовок содержит знаки вне перечня избранной азбуки': matchLetters,
               }
            },
            language_code: {
               kind: 'dynamic',
               title: 'Язык',
               display_scheme: '12-6-6-6',
               pathname: 'short_subjects',
               humanized_name: 'language',
               context_value: { k: "Language" },
               key_name: 'value',
               value_name: 'key',
               placeholder: 'Начни ввод наименования языка...',
               subscribeTo: '@alphabeth_code',
               validations: {
                  'Избранный язык не соотвествует избранной азбуке': matchCodes,
                  'Язык из списка должен быть выбран': matchEmptyObject,
               }
            },
            alphabeth_code: {
               kind: 'dynamic',
               title: 'Азбука',
               display_scheme: '12-6-6-6',
               pathname: 'short_subjects',
               humanized_name: 'alphabeth',
               context_value: { k: "Alphabeth" },
               key_name: 'value',
               value_name: 'key',
               placeholder: 'Начни ввод наименования азбуки...',
               subscribeTo: '@language_code',
               validations: {
                  'Избранная азбука не соотвествует избранному языку': matchCodes,
                  'Азбука из списка должна быть выбрана': matchEmptyObject,
               }
            },
         }
      },
      descriptions: {
         kind: 'collection',
         title: 'Описания',
         action: 'Добавь описание',
         single: 'Описание',
         placeholder: 'Введи описание',
         filter: { type: "Description" },
         display_scheme: '12-12-12-12',
         meta: {
            id: {
               kind: 'hidden',
            },
            text: {
               kind: 'tale',
               title: 'Описание',
               placeholder: 'Введи описание',
               display_scheme: '12-12-12-12',
               subscribeTo: '@alphabeth_code',
               validations: {
                  'Текст описания отсутствует': matchEmptyObject,
                  'Описание содержит знаки вне перечня избранной азбуки': matchLetters,
               }
            },
            language_code: {
               kind: 'dynamic',
               title: 'Язык',
               display_scheme: '12-6-6-6',
               pathname: 'short_subjects',
               humanized_name: 'language',
               context_value: { k: "Language" },
               key_name: 'value',
               value_name: 'key',
               placeholder: 'Начни ввод наименования языка...',
               subscribeTo: '@alphabeth_code',
               validations: {
                  'Избранный язык не соотвествует избранной азбуке': matchCodes,
                  'Язык из списка должен быть выбран': matchEmptyObject,
               }
            },
            alphabeth_code: {
               kind: 'dynamic',
               title: 'Азбука',
               display_scheme: '12-6-6-6',
               pathname: 'short_subjects',
               humanized_name: 'alphabeth',
               context_value: { k: "Alphabeth" },
               key_name: 'value',
               value_name: 'key',
               placeholder: 'Начни ввод наименования азбуки...',
               subscribeTo: '@language_code',
               validations: {
                  'Избранная азбука не соотвествует избранному языку': matchCodes,
                  'Азбука из списка должна быть выбрана': matchEmptyObject,
               }
            },
         }
      },
      members: {
         kind: 'collection',
         title: 'Члены',
         action: 'Добавь члена',
         display_scheme: '12-12-12-12',
         meta: {
            id: {
               kind: 'hidden',
            },
            name_id: {
               kind: 'dynamic',
               humanized_name: 'name',
               title: 'Имя',
               display_scheme: '12-3-3-4',
               placeholder: 'Начни ввод имени...',
               pathname: 'short_names',
               key_name: 'value',
               value_name: 'key',
            },
            account_no: {
               kind: 'tale',
               title: 'Учётка',
               placeholder: 'Введи учётку',
               display_scheme: '12-4-6-6',
               validations: {
                  'Намер учётки отсутствует': matchEmptyObject,
               }
            },
            account_type: {
               kind: 'select',
               title: 'Вид учётки',
               display_scheme: '12-4-3-3',
               codeNames: {
                  '': 'Избери вид учётки...',
                  'Account::Oid': 'Опознаватель',
                  'Account::Email': 'Почта',
                  'Account::Lj': 'Живой журнал',
                  'Account::Mailru': 'mail.ru',
                  'Account::Ok': 'Одноклассники',
                  'Account::Vk': 'Вконтакте',
                  'Account::X': 'Х',
               },
               validations: {
                  'Пункт из списка должен быть выбран': matchEmptyObject,
               },
            },
         }
      },
   },
}
