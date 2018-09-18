<!-- LOGOS APP VIEW -->

<template>
  <div class="container">
    <div class="page-header">
      <h1>LOLOLOLOLOLOLOL</h1>
    </div>

    <div class="panel panel-default">
      <div class="panel-heading">
        <h3>Add an Article</h3>
      </div>
      <div class="panel-body">
        <form id="addArticle" class="row" v-on:submit.prevent="postArticle">
          <div class="form-group">
            <label for="articleTitle">Title:</label>
            <input type="text" id="articleTitle" class="form-control" v-model="newArticle.title">
          </div>
          <div class="form-group">
            <label for="articleLocation">Location:</label>
            <input type="text" id="articleLocation" class="form-control" v-model="newArticle.location">
          </div>
          <div class="form-group">
            <label for="articleBody">Body:</label>
            <input type="text" id="articleBody" class="form-control" v-model="newArticle.body">
          </div>
          <input id="submit" type="submit" class="btn btn-primary" value="Post">
          </form>
      </div>
    </div>

    <div class="panel panel-default">
      <div class="panel-heading">
        <h3>Articles</h3>
      </div>
      <div class="panel-body">
        <table class="table table-striped">
          <thead>
            <tr>
              <th>
                Title:
              </th>
              <th>
                Author:
              </th>
              <th>
                Body:
              </th>
              <th>
                Location:
              </th>
              <th>
                Date Added:
              </th>
              <th>
                View Count:
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="storie in stories">
              <td>
                {{ storie.title }}
              </td>
              <td>
                {{ storie.author }}
              </td>
              <td>
                {{ storie.body }}
              </td>
              <td>
                {{ storie.location }}
              </td>
              <td>
                {{ storie.dateAdded }}
              </td>
              <td>
                {{ storie.viewCount }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <router-view/>
  </div>
</template>

<script>

var firebase = require('firebase/app');
require('firebase/auth');
require('firebase/database');

let config = {
    apiKey: "AIzaSyCA5R7pUDrcpBbhxQ1dk4jLeeZiwl7sV3c",
    authDomain: "web-app-testing-3309d.firebaseapp.com",
    databaseURL: "https://web-app-testing-3309d.firebaseio.com",
    projectId: "web-app-testing-3309d",
    storageBucket: "web-app-testing-3309d.appspot.com",
    messagingSenderId: "832434382294"
  };

let app = firebase.initializeApp(config);

let db = app.database();

let usersRef = db.ref('users');
let storiesRef = db.ref('stories');

export default {
  name: 'App',
  firebase: {
    users: usersRef,
    stories: storiesRef
  },
  data (){
    return {
      newArticle: {
        title: '',
        body: '',
        location: ''
      }
    }
  },
  methods: {
    postArticle: function(){
      storiesRef.push(this.newArticle);
      this.newArticle.title = '';
      this.newArticle.body = '';
      this.newArticle.location = '';
    }
  } 
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
  margin-top: 60px;
}

#articleBody{
  height: 200px;
}

form{
  padding-left: 5%;
  padding-right: 5%;
}

#submit{ 
margin-bottom: 2%;
}
</style>
