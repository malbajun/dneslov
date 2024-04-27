import { matchLanguages, matchAlphabeths, matchLetters, matchEmptyObject, matchCodes, matchEmptyCollection } from 'matchers'
import UrlRegexp from 'UrlRegexp'

export const userMeta = {
   default: 'user',
   remoteNames: 'backdrops',
   remoteName: 'backdrop',
   title: 'Настройки',
   new: 'Новая настройка',
   create: 'Сохранить',
   remove: {
      title: 'Точно ли удалить настройку %default?',
      yes: "Да"
   },
   form: {
      user_names: {
         kind: 'collection',
         title: "Имена",
         action: "Добавь имя",
         display_scheme: '12-12-12-12',
         subscribeTo: '@quantity',
         validations: {
            'Минимум одно имя должно быть задано': (value, context) => {
               if (!context.quantity && matchEmptyObject(value, context)) { return true }
            }
         },
         meta: {
            id: {
               kind: 'hidden',
            },
            name: {
               kind: 'tale',
               title: 'Имя',
               display_scheme: '12-6-5-5',
               placeholder: 'Введи имя',
               subscribeTo: '@alphabeth_code',
               validations: {
                  'Имя должно быть задано':  matchEmptyObject,
               }
            },
            language_code: {
               kind: 'dynamic',
               title: 'Язык',
               display_scheme: '12-6-2-2',
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
               display_scheme: '12-6-2-2',
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
            state_code: {
               kind: 'dynamic',
               title: 'Род имени',
               placeholder: 'Начни ввод наименования рода имени...',
               display_scheme: '12-6-3-3',
               pathname: 'short_subjects',
               humanized_name: 'state_name',
               context_value: { k: "UserNameKind" },
               key_name: 'value',
               value_name: 'key',
               validations: {
                  'Пункт из списка должен быть выбран': /^$/,
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
      accounts: {
         kind: 'collection',
         title: 'Учётки',
         action: 'Добавь учётку',
         singlea: 'Мера',
         placeholder: 'Введи меру',
         display_scheme: '12-12-12-12',
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
                  'Oid': 'Опознаватель',
                  'Email': 'Почта',
                  'LJ': 'Живой журнал',
                  'Mailru': 'mail.ru',
                  'Ok': 'Одноклассники',
                  'Vk': 'Вконтакте',
                  'X': 'Х',
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
