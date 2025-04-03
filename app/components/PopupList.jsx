import { Component } from 'react'
import PropTypes from 'prop-types'

export default class PopupList extends Component {
   static defaultProps = {
      name: null,
      list: [],
      onSelectItem: null,
   }

   static propTypes = {
      name: PropTypes.string.isRequired,
      list: PropTypes.array.isRequired,
      onSelectItem: PropTypes.func.isRequired,
   }

   static elementIdFromName(name) {
      const re = /[\._,]+/

      return name.replace(re, '-')
   }

   // system
   constructor(props) {
      super(props)

      this.onSelectFromList = this.onSelectFromList.bind(this)
   }

   onSelectFromList(e) {
      console.log("[onSelectFromList] <<<", e)
      let link = e.target.querySelector("a") || e.target

      this.props.onSelectItem(link.getAttribute("data-key"), link.getAttribute("data-value"))
      e.preventDefault()
   }

   // render
   render() {
      console.log("[render] * props:", this.props, "state: ", this.state)

      return (
         <div
            className='popup-list'>
            <ul
               className={'dynamic ' + PopupList.elementIdFromName(this.props.name) + ' collection'}>
               {this.props.list && this.props.list.map((record) =>
                  <li
                     className='collection-item'
                     onClick={this.onSelectFromList}>
                     <a
                        href="#!"
                        data-value={record.value}
                        data-key={record.text}>
                        {record.text}</a></li>
               )}</ul></div>)
   }
}
