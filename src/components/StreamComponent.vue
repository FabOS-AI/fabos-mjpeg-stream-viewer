<template>
    <div>
      <img :src = "imgSrc" />
    </div>
</template>
  
  <script>
  export default {
    data() {
      return {
        imgSrc: ''
      }
    },
    methods: {
      async fetchStreamURL() {
        const url = process.env.VUE_APP_AAS_SERVER_HOST +'/shells/'+process.env.VUE_APP_AAS_ID+'/aas/submodels/OperationalData/submodel/submodelElements/Endpoint/value'
        const res = await fetch(url)
        const data = await res.json()
        return data
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