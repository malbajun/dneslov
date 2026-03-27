import BooleanBox from 'BooleanBox'
import TextField from 'TextField'
import SelectField from 'SelectField'
import DynamicField from 'DynamicField'
import Collection from 'Collection'
import Block from 'Block'
import HiddenField from 'HiddenField'
import TextArea from 'TextArea'
import Resource from 'Resource'
import JsonEditor from 'JsonEditor'
import SlugFlow from 'SlugFlow'

export function kindToKlass(kind) {
   const klassTable = {
      hidden: HiddenField,
      boolean: BooleanBox,
      tale: TextArea,
      json: JsonEditor,
      text: TextField,
      select: SelectField,
      dynamic: DynamicField,
      block: Block,
      uploader: Resource,
      collection: Collection,
      set: SlugFlow,
   }

   let klass = klassTable[kind]

   if (!klass) {
      console.error("Undefined klass for the kind: " + kind)
   }

   return klass
}
