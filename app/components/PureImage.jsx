import { Component } from 'react'

export default class Image extends Component {
   static defaultProps = {
      src: null,
      uid: null,
      tooltip: null,
      index: null,
      wrapperClassName: "",
      onLoad: null,
      onError: null,
      onClick: null,

      i18n: {
         no_title: "Изображение без заголовка",
      }

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

   componentDidMount() {
      var elems = document.querySelectorAll('.tooltipped');
      var _instances = M.Tooltip.init(elems, {});
      this.$image.addEventListener('mousedown', this.onImageClick)
   }

   componentWillUnmount() {
      this.$image.removeEventListener('mousedown', this.onImageClick)
   }

   stateChanged() {
      if (this.state.errored && this.props.onError) {
         this.props.onError(this.props.index, this.props.uid, this.props.src)
      } else if (this.state.loaded && this.props.onLoad) {
         this.props.onLoad(this.props.index, this.props.uid, this.props.src)
      }
   }

   onImageCompleted(e) {
      let errored = false, loaded = true

      console.debug("[onImageCompleted] **", { 'image': e.target}, e.target.naturalHeight, e.target.naturalWidth)

      // NOTE: All images with height below 300px we treat as invalid
      if (e.type === "error" || e.target.naturalHeight < 300) {
         errored = true
      }

      this.setState((prevState) => { return {
         loaded: loaded,
         errored: errored,
         height: e.target.naturalHeight,
         width: e.target.naturalWidth,
      }}, this.stateChanged.bind(this))
   }

   onImageClick(e) {
      console.debug("[onImageClick] <<<", e)

      if ((e.buttons == 1 || e.buttons == 4) && this.props.onClick) {
         this.props.onClick(this.props.uid, this.props.src, e.buttons == 4)
      }

      e.preventDefault()
      e.stopPropagation()
   }

   render() {
      console.debug("[render] **", { 'this.props': this.props, 'this.state': this.state })

      return (
         !this.state.errored &&
            <img
               ref={e => this.$image = e}
               src={this.props.src}
               className={this.props.wrapperClassName + " tooltipped"}
               data-index={this.props.index}
               data-position="top"
               data-tooltip={this.props.tooltip || this.props.i18n.no_title}
               height={this.state.height}
               width={this.state.width}
               onLoad={this.onImageCompleted}
               onError={this.onImageCompleted} />
       )
   }
}
