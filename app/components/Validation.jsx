import { merge } from 'merge-anything'

const Validation = {
   getValidations() {
      if (!this.validations) {
         this.validations = this.props.validations || {}
      }

      console.debug("[getValidations] > ", this.validations, this.props.validations)

      return this.validations
   },

   getErrorText(valueIn, contextIn = {}) {
      let context = merge(this.props.validation_context || {}, contextIn),
          errors = [],
          value = valueIn === undefined || valueIn === null ? '' : valueIn

      Object.entries(this.getValidations()).forEach(([e, rule]) => {
         console.debug("[getErrorText] > rule:", rule.constructor.name, "value:", value.constructor.name, "error:", e)
         switch(rule.constructor.name) {
         case 'RegExp':
            switch(value.constructor.name) {
            case 'Object':
               let error = Object.values(value).reduce((res, v) => {
                  return res ||
                     typeof v.match !== "undefined" &&
                     v.match(rule) && e }, undefined)

               if (error) {
                  errors.push(e)
               }
               break
            case 'String':
               if (typeof value.match !== "undefined" && value.match(rule)) {
                  errors.push(e)
               }
            case 'Number':
               if (typeof value.match !== "undefined" && value.toString().match(rule)) {
                  errors.push(e)
               }
            }
            break
         case 'Array':
            if (rule[0] === '!' && !value.match(rule[1])) {
               errors.push(e)
            }
            break
         case 'Function':
            console.debug("[getErrorText] > valueIn", valueIn, "context:", context)
            if (rule(valueIn, context, this.state)) {
               errors.push(e)
            }
         }
      })

      console.debug("[getErrorText] >>> ", errors[0])

      return errors[0]
   },
}

export default Validation
