import { Component } from 'react'

export default class Image extends Component {
   static defaultProps = {
      src: null,
      uid: null,
      alt: null,
      index: null,
      wrapperClassName: "",
      onLoad: null,
      onError: null,
      onClick: null,
   }

   state = {
      loaded: false,
      errored: false,
   }

   constructor(props) {
      super(props)

      this.onImageClick = this.onImageClick.bind(this)
      this.onImageCompleted = this.onImageCompleted.bind(this)
   }

   stateChanged() {
      if (this.state.errored && this.props.onError) {
         this.props.onError(this.props.index, this.props.uid, this.props.src)
      } else if (this.state.loaded && this.props.onLoad) {
         this.props.onLoad(this.props.index, this.props.uid, this.props.src)
      }
   }

   onImageCompleted(e) {
      let errored = false

      // All images with height below 300px we treat as invalid
      if (e.type === "error" || e.target.naturalHeight < 300) {
         errored = true
      }

      this.setState((prevState) => { return { loaded: !errored, errored: errored }}, this.stateChanged.bind(this))
   }

   onImageClick(e) {
      if (this.props.onClick) {
         this.props.onClick(this.props.uid, this.props.src)
      }

      e.preventDefault()
      e.stopPropagation()
   }

   render() {
      console.debug("[render] **", { 'this.props': this.props, 'this.state': this.state })

      return (
         !this.state.errored && <img
            alt={this.props.alt}
            src={this.props.src}
            className={this.props.wrapperClassName}
            data-index={this.props.index}
            onClick={this.onImageClick}
            onLoad={this.onImageCompleted}
            onError={this.onImageCompleted} />)
   }
}
