// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import VueFire from 'vuefire'
import Home from './components/Home'
import router from './router'

Vue.config.productionTip = false

Vue.use(VueFire)

/* eslint-disable no-new */
new Vue ({
  el: '#home',
  router,
  components: { Home },
  template: '<Home/>'
})
