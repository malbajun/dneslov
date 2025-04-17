import { Component } from 'react'

import Markdown from 'Markdown'

export default class Span extends Component {
   static defaultProps = {
      id: null,
      active: null,

      onCLick: null,
   }

   // system
   constructor(props) {
      super(props)

      this.onClick = this.onClick.bind(this)
   }

   // custom
   classNameForItem() {
      return 'span' + (this.props.active && "active" || "")
   }

   onClick(e) {
      if (this.props.onClick) {
         let res = this.props.onClick(this.props.id, e)

         if (res) {
            e.stopPropagation()
            e.preventDefault()
         }
      }
   }

   drawComponent(c) {
      let key = Object.keys(c).first(), valueName = Object.values(c).first(), value

      switch(valueName.constructor.name) {
      case 'Array':
         value = valueName.reduce((res, name) => res || this.props[name], null)
         break;
      default:
         value = this.props[valueName]
      }

      switch(key) {
      case 'md':
         return <Markdown source={value} />
      case 'span':
         return <span>{value}</span>
      default:
      }

      return null;
   }

   render() {
      console.log("[render] * this.props:", this.props)

      return (
         <li
            className={this.classNameForItem()}
            onClick={this.onClick} >
            <div
               className='spannable-header'
               key={'object-span-' + this.props.id}>
               {this.props.scheme.header?.map((c) => this.drawComponent(c))}</div>
            {this.props.scheme.body && this.props.scheme.body.isPresent() && <div
               className='spannable-body'>
               {this.props.scheme.body?.map((c) => this.drawComponent(c))}</div>}</li>)
   }
}
