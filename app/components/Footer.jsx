import { Component } from 'react'

export default class Footer extends Component {
   render() {
      return (
        <footer class="page-footer">
           <div class="container">
              <div class="row">
                 <div class="col l6 s12">
                    <h5 class="white-text">Днеслов</h5>
                    <p class="grey-text text-lighten-4">проект создания обединённой православной агиографической платформы.</p>
                    <ul>
                       <li><p class="grey-text text-lighten-4">Карта:</p></li>
                       <li><a class="grey-text text-lighten-4" target="_blank" href="/about">О проекте</a></li>
                       <li><a class="grey-text text-lighten-4" target="_blank" href="/rites">Чинопоследования</a></li>
                    </ul>
                 </div>
                 <div class="col l4 offset-l2 s12">
                    <h5 class="white-text">Ссылки</h5>
                    <ul>
                       <li><a class="grey-text text-lighten-3" target="_blank" href="https://t.me/dneslov_beseda">Беседа</a></li>
                       <li><a class="grey-text text-lighten-3" target="_blank" href="https://t.me/dneslov">Соцсети</a></li>
                       <li><a class="grey-text text-lighten-3" target="_blank" href="https://codeberg.org/znamenica/dneslov">Разработка</a></li>
                    </ul>
                 </div>
              </div>
           </div>
           <div class="footer-copyright">
              <div class="container">
                 © 2017-now Znamenica Foundation
              </div>
           </div>
        </footer>)
   }
}
