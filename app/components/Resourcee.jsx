import { Component } from 'react'
import { mixin } from 'lodash-decorators'
import PropTypes from 'prop-types'

import Memory from 'Memory'
import Carousel from 'Carousel'
import MemorySpans from 'MemorySpans'
import Name from 'Name'
import Description from 'Description'
import GetSlugColor from 'mixins/GetSlugColor'
import Player from 'Player'
import Markdown from 'Markdown'
import MetaTags from 'react-meta-tags'
import { getUrlsFrom } from 'support'

@mixin(GetSlugColor)
export default class Resourcee extends Component {
   static defaultProps = {
      type: null,
      title: null,
      description: null,
      path: null,
      props: {},
      digest: null,
      uri: null,
      thumb_url: null,
      data: null,
      uid: null,

//      onLoadRequest: null,
//
      i18n: {
//         gallery: "Выставка",
      }
   }

   static propTypes = {
      type: PropTypes.string.isRequired,
      title: PropTypes.string,
      description: PropTypes.string,
      path: PropTypes.string,
      props: PropTypes.object,
      digest: PropTypes.string.isRequired,
      uri: PropTypes.string.isRequired,
      thumb_url: PropTypes.string.isRequired,
      data: PropTypes.blob,
      uid: PropTypes.string.isRequired,
      id: PropTypes.number.isRequired,
   }

   getKeywords() {
   }

   getSlugColor(type) {
   }

   getTextFromType(type) {
   }

   onImageClick() {
   }

   render() {
      console.log("[render] *", { 'this.props': this.props })

      return [
         <MetaTags>
            <meta
               id="meta-title"
               name="title"
               content={this.props.title} />
            <meta
               id="meta-keywords"
               name="keywords"
               content={this.getKeywords()} />
            <meta
               id="meta-description"
               name="description"
               content={this.props.description} /></MetaTags>,
         <div className='row resource'>
            <div className='col'>
               <div className='row'>
                  <span
                     className='title'>
                     {this.props.title}</span></div></div>
            {this.props.thumb_url &&
               <div className='col x2 l3 m6 s12 large-thumb'>
                     <img
                        src={this.props.thumb_url}
                        onClick={this.onImageClick} /></div>}</div>,
            <div className='col s12 scriptum'>
               <Markdown source={this.props.description} /></div>]
   }
}
