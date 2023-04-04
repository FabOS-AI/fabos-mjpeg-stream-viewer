<template>
  <div>
    <!-- <v-app-bar :elevation="2"></v-app-bar> -->
    <!-- <img :src = "imgSrc" /> -->

    <v-container align="center" align-content="center" justify="center">
      <v-row align="center" align-content="center" justify="center">
        <v-col>
          <h1>MJPEG Camera Stream</h1>
        </v-col>
        <v-col>
          <v-btn @click="doRefresh" color="#00a0e3" class="text-white">Fetch AAS</v-btn>
        </v-col>
      </v-row>
      <v-row max-width="200px" align="center" align-content="center" justify="center">


        <image-placeholder :src="imgSrc">

          <v-card loading class="pa-10" max-width="400px" align="center" align-content="center" justify="center">

            <h3>Waiting for stream content ...</h3>
            <v-divider :thickness="15" class="border-opacity-0"></v-divider>
            <div width="200px" height="auto">
              <img src="https://www.fab-os.org/typo3conf/ext/theme_fabos/Resources/Public/Images/fabos_logo.svg"
                width="10px" height="10px" />
            </div>
          </v-card>
        </image-placeholder>

      </v-row>
    </v-container>

  </div>
</template>
  
<script>

import getEnv from '@/utils/env'
import ImagePlaceholder from './ImagePlaceholder.vue'

export default {
  data() {
    return {
      imgSrc: null,
    }
  },
  components: {
    ImagePlaceholder
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
img {
  height: auto;
  width: 100%;
  object-fit: contain;
}
</style>
