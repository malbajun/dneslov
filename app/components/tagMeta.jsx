import { matchLetters, matchEmptyObject } from 'matchers'
import UrlRegexp from 'UrlRegexp'

export const tagMeta = {
   default: 'appellation',
   remoteNames: 'api/v0/tags',
   remoteShow: 'api/v0/tags',
   remoteName: 'tag',
   title: 'Метки',
   new: 'Новая метка',
   update: 'Обнови метку',
   create: 'Создай метку',
   close: 'Закрой',
   remove: {
      title: 'Точно ли удалить метку %default?',
      yes: "Да"
   },
   row: {
      id: {
         title: 'Оз',
      },
      kind: {
         title: 'Вид',
      },
      appellation: {
         title: 'Чири́к',
      },
      tagged_count: {
         title: 'Число помеченных',
      },
   },
   form: {
      id: {
         kind: 'hidden',
      },
      kind: {
         kind: 'select',
         title: 'Вид метки',
         default: 'обычна',
         humanized_default: 'Обычна',
         codeNames: {
            '': 'Избери вид метки...',
            'обычна': 'Обычна',
            'поместна': 'Поместна',
         },
         display_scheme: '12-3-3-3',
         subscribeTo: ['@bond_to_id', '@year_date'],
         validations: {
            'Пункт из списка должен быть выбран': matchEmptyObject,
         }
      },
      appellation: {
         kind: 'text',
         title: 'Чири́к',
         placeholder: 'Введи чири́к',
         display_scheme: '12-9-9-9',
         subscribeTo: '@alphabeth_code',
         validations: {
            "Чири́к отсутствует": matchEmptyObject,
            'Чири́к содержит знаки вне перечня избранной азбуки': matchLetters,
         }
      },
      title: {
         kind: 'text',
         title: 'Заголовок',
         placeholder: 'Введи заголовок',
         display_scheme: '12-12-12-12',
         subscribeTo: '@alphabeth_code',
         validations: {
            "Заголовок отсутствует": matchEmptyObject,
            'Заголовок содержит знаки вне перечня избранной азбуки': matchLetters,
         }
      },
      description: {
         kind: 'tale',
         title: 'Описание',
         placeholder: 'Введи описание',
         display_scheme: '12-12-12-12',
         subscribeTo: '@alphabeth_code',
         validations: {
            "Описание отсутствует": matchEmptyObject,
            'Описание содержит знаки вне перечня избранной азбуки': matchLetters,
         }
      },
   },
}
