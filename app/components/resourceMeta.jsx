import { matchEmptyObject } from 'matchers'

export const resourceMeta = {
   default: 'title',
   remoteName: 'resource',
   remoteNames: 'api/v0/resources',
   remoteCreate: 'api/v0/resources/create',
   remoteShow: 'api/v0/resources',
   title: 'Изнаходи',
   new: 'Новая изнаходь',
   update: 'Обнови изнаходь',
   create: 'Создай изнаходь',
   close: 'Закрой',
   remove: {
      title: 'Точно ли удалить изнаходь %default?',
      yes: "Да"
   },
   row: {
      id: {
         title: 'Оз',
      },
      thumb_url: {
         title: 'Рси',
         value: (context) => context.thumb_url && <img src={context.thumb_url} className='thumb' />,
      },
      type: {
         title: 'Тип',
      },
      title: {
         title: 'Заголовок',
      },
   },
   form: {
      type: {
         kind: 'select',
         title: 'Вид памяти',
         display_scheme: '12-3-2-2',
         codeNames: {
            '': 'Избери вид памяти...',
            'Resource::Book': 'Книга',
            'Resource::PageSet': 'Набор страниц',
            'Resource::Pictura': 'Картинка',
            'Resource::Site': 'Страница',
            'Resource::Sonus': 'Звук',
            'Resource::Virtual': 'Мнимь',
            'Resource::Volumen': 'Том',
         },
         validations: {
            'Пункт из списка должен быть выбран': matchEmptyObject,
         },
      },
      title: {
         kind: 'text',
         title: 'Заголовок',
         placeholder: 'Введи заголовок',
         display_scheme: '12-9-10-10',
         validations: {
            'Текст заголовка отсутствует': matchEmptyObject,
         }
      },
      resource: {
         kind: 'uploader',
         title: 'Изнаходь',
         source: "thumb_url",
         display_scheme: '12-12-12-12',
         placeholder: 'Загрузи ресурс',
         visible_if: { type: ["Resource::Book", "Resource::Pictura", "Resource::Sonus"] },
      },
      description: {
         kind: 'tale',
         title: 'Описание',
         placeholder: 'Введи описание',
         display_scheme: '12-12-12-12',
      },
   }
}
