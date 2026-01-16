import { matchLanguages, matchAlphabeths, matchLetters, matchEmptyObject, matchCodes, matchEmptyCollection } from 'matchers'
import UrlRegexp from 'UrlRegexp'

export const userMeta = {
   default: 'user',
   remoteNames: 'api/v1/users',
   remoteName: 'user',
   // unoName: 'accounts.no',
   title: 'Настройки',
   new: 'Новая настройка',
   create: 'Сохранить',
   remove: {
      title: 'Точно ли удалить настройку %default?',
      yes: "Да"
   },
   form: {
      default_name: {
         kind: 'tale',
         title: 'Имя по-умолчанию',
         display_scheme: '12-12-12-12',
         placeholder: 'Введи имя',
      },
      user_names: {
         kind: 'collection',
         title: "Имена",
         action: "Добавь имя",
         display_scheme: '12-12-12-12',
         subscribeTo: '@default_name',
         validations: {
            'Минимум одно имя должно быть задано': (value, context) => {
               if (matchEmptyObject(context.default_name, context) && matchEmptyObject(value, context)) { return true }
            }
         },
         meta: {
            id: {
               kind: 'hidden',
            },
            nomen_id: {
               kind: 'dynamic',
               title: 'Имя',
               humanized_name: 'name',
               display_scheme: '12-4-4-2',
               placeholder: 'Начни ввод имени...',
               pathname: 'api/v0/names/ac',
               key_name: 'value',
               value_name: 'key',
               validations: {
                  'Имя должно быть задано':  matchEmptyObject,
               }
            },
            kind: {
               kind: 'select',
               title: 'Род имени',
               display_scheme: '12-2-2-1',
               codeNames: {
                  '': 'Избери род имени...',
                  'NameKind::First': 'Имя',
                  'NameKind::Paternal': 'Отчество / Родитель',
                  'NameKind::Family': 'Фамилия / Род',
               },
               validations: {
                  'Пункт из списка должен быть выбран': /^$/,
               }
            },
            way: {
               kind: 'select',
               title: 'Чин имени',
               display_scheme: '12-2-3-2',
               codeNames: {
                  '': 'Избери чин имени...',
                  'NameWay::Appellation': 'Наречение',
                  'NameWay::Baptism': 'Крещение',
                  'NameWay::Sobriquet': 'Позывной',
                  'NameWay::Self': 'Самоназванное',
                  'NameWay::Rasophorus': 'Рясофорное',
                  'NameWay::Monastic': 'Иноческое',
                  'NameWay::Schema': 'Схимное',
                  'NameWay::Bless': 'Благословенное',
                  'NameWay::Dedication': 'Посвящённое',
                  'NameWay::Repentance': 'Покаянное',
               },
               validations: {
                  'Пункт из списка должен быть выбран': /^$/,
               }
            },
            usage: {
               kind: 'select',
               title: 'Пространство имени',
               display_scheme: '12-4-3-2',
               codeNames: {
                  '': 'Избери пространство для имени...',
                  'NameUsage::Family': 'Семья',
                  'NameUsage::Church': 'Церковь',
                  'NameUsage::Society': 'Общество',
                  'NameUsage::Community': 'Сообщество',
                  'NameUsage::Army': 'Ополчение',
                  'NameUsage::Czardom': 'Царство',
                  'NameUsage::Brotherhood': 'Братство',
                  'NameUsage::Sisterhood': 'Сестричество',
               },
               validations: {
                  'Пункт из списка должен быть выбран': /^$/,
               }
            },
            source: {
               kind: 'select',
               title: 'Источник имени',
               display_scheme: '12-4-4-2',
               codeNames: {
                  '': 'Избери источник образования имени...',
                  'NameSource::Self': 'Сам',
                  'NameSource::Father': 'Отец',
                  'NameSource::Mother': 'Мать',
                  'NameSource::Husband': 'Муж',
                  'NameSource::Wife': 'Жена',
                  'NameSource::Foster': 'Приёмный',
                  'NameSource::Uncle': 'Дядя',
                  'NameSource::Godfather': 'Крёстный',
                  'NameSource::Godmother': 'Крёстная',
                  'NameSource::Brotherhood': 'Братия',
                  'NameSource::Spiritual': 'Духовный',
                  'NameSource::Saint': 'Святой',
                  'NameSource::Place': 'Место',
                  'NameSource::Gest': 'Подвиг',
                  'NameSource::Property': 'Свойство',
               },
               validations: {
                  'Пункт из списка должен быть выбран': /^$/,
               }
            },
            bindable_id: {
               kind: 'dynamic',
               title: 'Привязка',
               display_scheme: '12-7-7-2',
               pathname: 'api/v0/subjects/ac',
               humanized_name: 'bindable',
               key_name: 'value',
               value_name: 'key',
               placeholder: 'Начни ввод наименования привязки...',
            },
            main: {
               kind: 'boolean',
               name: 'main',
               title: 'Головное',
               display_scheme: '12-1-1-1',
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
               pathname: 'api/v0/subjects/ac',
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
               pathname: 'api/v0/subjects/ac',
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
      accounts: {
         kind: 'collection',
         title: 'Учётки',
         action: 'Добавь учётку',
         singlea: 'Мера',
         placeholder: 'Введи меру',
         display_scheme: '12-12-12-12',
         validations: {
            'Минимум одна учётка должна быть задана': (value, context) => { return matchEmptyObject(value, context) }
         },
         meta: {
            id: {
               kind: 'hidden',
            },
            no: {
               kind: 'tale',
               title: 'Учётка',
               placeholder: 'Введи учётку',
               display_scheme: '12-4-6-6',
               validations: {
                  'Намер учётки отсутствует': matchEmptyObject,
               }
            },
            type: {
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
            validated: {
               kind: 'boolean',
               title: 'Подтверждена',
               display_scheme: '12-4-3-3',
               readonly: true,
            },
         }
      },
   },
}
