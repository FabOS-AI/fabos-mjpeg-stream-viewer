<template>
    <div class="image">
      <img :src="src" @load="ready = true" v-show="ready">
      <slot v-if="!ready" />
    </div>
  </template>
  
  <script>
  export default {
    props: ['src'],
    data: () => ({
      ready: false
    }),
    watch: {
      src () { this.ready = false }
    }
  }
  </script>