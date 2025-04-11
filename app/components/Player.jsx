import { Component } from 'react'
import {Howl, Howler} from 'howler'

export default class Player extends Component {
   static defaultProps = {
      url: null,
      playing: false,
      onActivePlay: null
   }

   state = {
      playing: false,
   }

   static getDerivedStateFromProps(props, state) {
      if (props !== state.prevProps) {
         return {
            prevProps: props,
            playing: props.playing
         }
      }

      return null
   }

   constructor(props) {
      super(props)

      console.debug("[constructor] **", { 'props': props })
      this.onPlayClick = this.onPlayClick.bind(this)
      this.onEndPlay = this.onEndPlay.bind(this)
      this.onStopClick = this.onStopClick.bind(this)

      this.sound = new Howl({
         src: [props.url],
         html5: true,
         preload: false,
         onend: this.onEndPlay
      })
   }

   componentDidMount() {
      this.componentDidRender()
   }

    componentDidUpdate() {
      this.componentDidRender()
   }

   onEndPlay(rrr, eee) {
      this.setState({playing: false})
   }

   onPlayClick() {
      if (this.props.onActivePlay) {
         this.props.onActivePlay(this.props.url)
      } else {
         this.setState({playing: true})
      }
   }

   componentDidRender() {
      if (this.state.playing) {
         this.sound.play()
      } else {
         this.sound.stop()
      }
   }

   onStopClick() {
      this.setState({playing: false})
   }

   render() {
      console.debug("[render] **", { 'this.props': this.props, 'this.state': this.state })

      return (
         <span className="player">
            {this.state.playing && <span
               onClick={this.onStopClick}>
               <i className="material-icons small stop">stop</i></span>}
            {!this.state.playing && <span
               onClick={this.onPlayClick}>
               <i className="material-icons small play">play_circle_filled</i></span>}
         </span>)
   }
}
