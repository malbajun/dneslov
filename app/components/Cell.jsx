import { Component } from 'react'
import PropTypes from 'prop-types'

export default class Cell extends Component {
   shouldComponentUpdate(nextProps, nextState) {
      return this.props.value !== nextProps.value
   }

   default() {
      return this.value(this.props.default)
   }

   t(title) {
      return title.replace(/%default/, () => { return this.default() })
   }

   value(name, element = this.props.meta[name]) {
      if (!element) {
         return null
      }

      return element.value ?
         element.value(this.props.value, this.props.text_languages, element.source, element.filter) : this.props.default
   }

   render() {
      console.log("[render] * props", this.props)

      try {
         return <span>{this.value(this.props.name, this.props.element)}</span>
      } catch {
         return <span>-</span>
      }
   }
}
