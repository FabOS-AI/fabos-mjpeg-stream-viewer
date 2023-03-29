<template>
    <header>
        <h1>{{ title }}</h1>
        <Button text="Button Function" color = "green"/>
        <Button text="Weltuntergang" color = "red"/>
        <Button text="Refresh" color = "gray"/>
    </header>
</template>

<script>
import Button from './Button.vue';

export default {
    name: 'Header-page',
    props: {
        title: String
    },
    components: {
        Button,
    }
}
</script>

<style scoped>
header{
    /* display: flex; */
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    text-align: center;
}
</style>