import { Component } from 'react'
import PropTypes from 'prop-types'

export default class Chip extends Component {
   static defaultProps = {
      className: null,
      url: '',
      texts: [],
      data: null,
      color: null,
      action: null,
      onAct: null,
   }

   static propTypes = {
      className: PropTypes.string,
      url: PropTypes.string,
      text: PropTypes.string.isRequired,
      data: PropTypes.object,
      color: PropTypes.string,
      action: PropTypes.string,
      onAct: PropTypes.func,
   }

   state = {}

   static getDerivedStateFromProps(props, state) {
      if (props !== state.prevProps) {
         return {
            action: props.action,
            prevProps: props
         }
      }

      return null
   }

   // system
   constructor(props) {
      super(props)

      this.onLinkClick = this.onLinkClick.bind(this)
   }

   componentDidMount() {
      this.$link.addEventListener('click', this.onLinkClick)
   }

   componentWillUnmount() {
      this.$link.removeEventListener('click', this.onLinkClick)
   }

   className() {
      return 'chip ' + (this.props.className || '')
   }

   closeClassName() {
      return 'material-icons unfix ' + (this.state.action || '')
   }

   actionIcon() {
      return this.state.action == 'remove' && 'close' || this.state.action
   }

   renderText(text) {
      let parts = [], partsIn = []

      if (this.props.children) {
         parts = [this.props.children]
      }

      if (!text.isBlank()) {
         if (text.constructor.name == "Array") {
            partsIn = partsIn.concat(text)
         } else {
            partsIn = partsIn.concat([text])
         }

         parts = parts.concat(partsIn.map((textIn) => {
            if (this.props.url) {
               return <a href={this.properUrl()} target='_blank' >{textIn}</a>
            } else {
               return <span>{textIn}</span>
            }
         }))
      }

      return parts
   }

   hasDefaultText() {
      return !this.props.children && !this.props.url
   }

   // handlers
   onLinkClick(e) {
      if (e.target.href) {
          e.stopPropagation()
          e.preventDefault()
          window.open(this.props.url, '_blank')
      }
   }

   onAct(e) {
      e.stopPropagation()
      this.setState({ action: null })
      this.props.onAct(this.props.data)
   }

   properUrl() {
      let url = this.props.url.replace(/^http:\/\//, 'https://')

      return url
   }

   render() {
      console.debug("[render] **", { 'this.props': this.props, 'this.state': this.state })

      return (
         <div
            key={this.props.text + ' link'}
            ref={e => this.$link = e}
            className={this.className()}
            style={{ backgroundColor: '#' + this.props.color }} >
            {this.renderText(this.props.text)}
            {this.state.action &&
               <i
                  className={this.closeClassName()}
                  onClick={this.onAct.bind(this)} >{
                  this.actionIcon()}</i>}</div>)}}
