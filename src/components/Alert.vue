<template>
    <div>
      <v-alert
        :v-model="alert"
        variant="tonal"
        closable
        close-label="Close Alert"
        :color="params.color"
        :title="params.title"
      >
        {{params.text}}
      </v-alert>
  
    </div>
  </template>

<script>

export default {
    name: alert,
    props:{
        params: Object,
    },
    data: () => ({
        alert : false,
    }),

}
</script>
<style scoped>
div {
  margin: auto;
}
</style>