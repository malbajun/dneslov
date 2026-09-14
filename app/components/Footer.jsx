import { Component } from 'react'

export default class Footer extends Component {
   render() {
      return (
        <footer className="page-footer">
           <div className="container">
              <div className="row">
                 <div className="col l6 s12">
                    <h5 className="white-text">Днеслов</h5>
                    <p className="grey-text text-lighten-4">проект создания обединённой православной агиографической платформы.</p>
                    <ul>
                       <li><p className="grey-text text-lighten-4">Карта:</p></li>
                       <li><a className="grey-text text-lighten-4" target="_blank" href="/about">О проекте</a></li>
                       <li><a className="grey-text text-lighten-4" target="_blank" href="/rites">Чинопоследования</a></li>
                    </ul>
                 </div>
                 <div class="col l4 offset-l2 s12">
                    <h5 class="white-text">Ссылки</h5>
                    <ul>
                       <li><a className="grey-text text-lighten-3" target="_blank" href="https://t.me/dneslov_beseda">Беседа</a></li>
                       <li><a className="grey-text text-lighten-3" target="_blank" href="https://t.me/dneslov">Соцсети</a></li>
                       <li><a className="grey-text text-lighten-3" target="_blank" href="https://codeberg.org/znamenica/dneslov">Разработка</a></li>
                    </ul>
                 </div>
              </div>
           </div>
           <div className="footer-copyright">
              <div className="container">
                 © 2017-now Znamenica Foundation
              </div>
           </div>
        </footer>)
   }
}
