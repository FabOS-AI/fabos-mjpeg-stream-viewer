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

    async discoverAasServer() {
        
        let url = getEnv('VUE_APP_AAS_REGISTRY_HOST') + '/api/v1/registry/' + getEnv('VUE_APP_AAS_ID')
        let res = await fetch(url).then(
          (response) => {
            return response.json()
          }).catch(exception => {
          console.error(`AAS fetch for ID '${getEnv('VUE_APP_AAS_ID')}' from registry '${getEnv('VUE_APP_AAS_REGISTRY_HOST')}' failed: \n` + exception)
            return null
          });
        return res
        
      },

      async fetchStreamURL(baseUrl) {
      
        const url = baseUrl + '/values'
        let res = await fetch(url).then(
          (response) => {
          //console.log("successful recieved submodel from AAS server ", response)
          let result = response.json()
          console.log("found submodel at AAS server:", result)
          return result
          }).catch(exception => {
            console.error('submodel fetch failed: ' + exception)
            return null
          });
        return res
    },

    doRefresh(){
      this.getStreamUrl()
    },

    async getStreamUrl() {

      this.imgSrc = null
      
      let registryResponse = await this.discoverAasServer()

      if (registryResponse != null) {

        console.log("found AAS at registry:", registryResponse)
        let operationSubmodel = registryResponse.submodels.filter((sm) => sm.idShort === "OperationalData")

        if (typeof operationSubmodel !== "undefined") {

          let aasUrl = operationSubmodel[0].endpoints[0].address
          if (typeof aasUrl !== "undefined" && aasUrl.length > 0) {
            let submodel = await this.fetchStreamURL(aasUrl)

            if (Object.prototype.hasOwnProperty.call(submodel, 'Endpoint')) {

              console.log("found matching submodel:", submodel)
            this.imgSrc = submodel.Endpoint
              console.log(`loaded stream URL: '${this.imgSrc}'`)
          } else {
            console.warn("fetched submodel has no property 'Endpoint': " + submodel);
          }
          } else {
            console.warn("fetched submodel has no endpoint to access");
        }
        } else {
          console.warn("did not find submodel 'OperationalData' in AAS from registry");
      }
      } else {
        console.warn("did not receive any submodels from AAS registry for AAS with id: " + getEnv('VUE_APP_AAS_ID') + " at: " + getEnv('VUE_APP_AAS_REGISTRY_HOST'));
      }
    }
  },
  async created() {
      
    this.getStreamUrl()
      
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