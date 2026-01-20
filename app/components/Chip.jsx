import { Component } from 'react'
import PropTypes from 'prop-types'

export default class Chip extends Component {
   static defaultProps = {
      className: null,
      url: '',
      texts: [],
      text: null,
      data: null,
      color: null,
      action: null,
      onAct: null,
   }

   static propTypes = {
      className: PropTypes.string,
      url: PropTypes.string,
      text: PropTypes.string,
      texts: PropTypes.array,
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
      var elems = document.querySelectorAll('.tooltipped');
      var _instances = M.Tooltip.init(elems, {});

      this.$link.addEventListener('click', this.onLinkClick)
   }

   componentWillUnmount() {
      this.$link.removeEventListener('click', this.onLinkClick)
   }

   className() {
      return 'chip ' + (this.props.className || '') + (this.props.tooltip ? ' tooltipped' : "")
   }

   closeClassName() {
      return 'material-icons unfix ' + (this.state.action || '')
   }

   actionIcon() {
      return this.state.action == 'remove' && 'close' || this.state.action
   }

   texts() {
      return this.props.text ? [this.props.text] : this.props.texts
   }

   renderText(text) {
      let parts = [], partsIn = []

      if (this.props.children) {
         parts = [this.props.children]
      }

      if (text && !text.isBlank()) {
         if (text.constructor.name == "Array") {
            partsIn = partsIn.concat(text)
         } else {
            partsIn = partsIn.concat([text])
         }

         parts = parts.concat(partsIn.map((textIn) => {
            return <span>{textIn}</span>
         }))
      }

      return parts
   }

   hasDefaultText() {
      return !this.props.children && !this.props.url
   }

   // handlers
   onLinkClick(e) {
      console.log("werewerew", this.props.url)
      if (this.props.url) {
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

   render() {
      console.debug("[render] **", { 'this.props': this.props, 'this.state': this.state })

      return (
         <div
            ref={e => this.$link = e}
            className={"chip-group"} >
            {this.texts().map((text) => <div
               className={this.className()}
               data-position="top"
               data-tooltip={this.props.tooltip || null}
               style={{ backgroundColor: '#' + this.props.color }} >
               {this.renderText(text)}
               {this.state.action &&
                  <i
                     className={this.closeClassName()}
                     onClick={this.onAct.bind(this)} >{
                     this.actionIcon()}</i>}</div>)}
         </div>
      )
   }
}
