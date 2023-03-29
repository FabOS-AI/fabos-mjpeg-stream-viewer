<template>
     <button @click="onClick()" :style="{
        background: color}"  class="btn"> {{text}} </button>
</template>

<script>
export default {
    name: 'cam-button',
    props:{
        text: String,
        color: String
    },
    methods: {
        onClick() {
            console.log('click')
        }
    }
}
</script>