<template>
    <div>
      <img :src = "imgSrc" />
    </div>
</template>
  
  <script>

  import getEnv from '@/utils/env'

  export default {
    data() {
      return {
        imgSrc: ''
      }
    },
    methods: {
      async fetchStreamURL() {
        const url = getEnv('VUE_APP_AAS_SERVER_HOST') + '/shells/' + getEnv('VUE_APP_AAS_ID') + '/aas/submodels/OperationalData/submodel/submodelElements/Endpoint/value'
        const res = await fetch(url).then(
          (response) => {
            console.log("successful recieved response from AAS server ", response)
            return response.json()
          }).catch(exception => {
            console.error('stream url fetch failed: ' + exception)
            return null
          });
      }
    },
    async created() {
      
      this.imgSrc = await this.fetchStreamURL()
      
      console.log('StreamComponent')
      console.log(this.imgSrc)
    },
  }
  </script>
  
  <style scoped>
  img{
      height: auto ;
      width: 100%;
      object-fit: contain;
  }
  </style>