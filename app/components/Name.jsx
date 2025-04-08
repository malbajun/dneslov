import { Component } from 'react'
import PropTypes from 'prop-types'
import { generateFullName } from 'mixins/namegen'

export default class Name extends Component {
   static defaultProps = {
      names: [],
      klugs: [],
      short_name: null,
      defaultNameInCalendary: null,
   }

   static propTypes = {
      names: PropTypes.array.isRequired,
   }

   static getDerivedStateFromProps(props, state) {
      if (props !== state.prevProps) {
         let fullName = generateFullName(props.names, props.klugs)

         return {
            prevProps: props,
            fullName: fullName,
            autoName: props.short_name || fullName || props.defaultNameInCalendary,
         }
      }

      return null
   }

   state = {}

   properUrl() {
      let url = this.props.url.replace(/^http:\/\//, 'https://')

      return url
   }

   render() {
      console.log("[render] *", { 'this.props': this.props, 'this.state': this.state })

      return (
         <span
            className='name'>
            {this.props.url &&
               <a
                  href={this.properUrl()}
                  target='_self' >
                  {this.state.autoName}</a>}
            {! this.props.url && this.state.autoName}</span>
      )
   }
}
