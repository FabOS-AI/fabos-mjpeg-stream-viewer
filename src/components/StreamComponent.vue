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
        imgSrc: '',
      }
    },
    methods: {

      async discoverAasServer(){
        
        let url = getEnv('VUE_APP_AAS_REGISTRY_HOST') + '/api/v1/registry/' + getEnv('VUE_APP_AAS_ID')

        let res = await fetch(url).then(
          (response) => {
            console.log("successful recieved response from AAS registry ", response)
            return response.json()
          }).catch(exception => {
            console.error('AAS fetch from registry failed: ' + exception)
            return null
          });
        return res
        
      },

      async fetchStreamURL(baseUrl) {
        // const url = getEnv('VUE_APP_AAS_SERVER_HOST') + '/shells/' + getEnv('VUE_APP_AAS_ID') + '/aas/submodels/OperationalData/submodel/submodelElements/Endpoint/value'
        const url = baseUrl + '/values'
        let res = await fetch(url).then(
          (response) => {
            console.log("successful recieved submodel from AAS server ", response)
            return response.json()
          }).catch(exception => {
            console.error('submodel fetch failed: ' + exception)
            return null
          });
        return res
      }
    },
    async created() {
      
      let registryResponse = await this.discoverAasServer()

      if (registryResponse != null){

        let operationSubmodel = registryResponse.submodels.filter((sm) => sm.idShort === "OperationalData")[0].endpoints[0].address

        if (typeof operationSubmodel !== "undefined"){

          let submodel = await this.fetchStreamURL(operationSubmodel)

          if (submodel.hasOwnProperty('Endpoint')){
            this.imgSrc = submodel.Endpoint
          } else {
            console.warn("fetched submodel has no property 'Endpoint': " + submodel);
          }

        }

      }

      
      
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