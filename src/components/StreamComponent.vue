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
      <v-row>
        <h3>Request Meta data</h3>
      </v-row>
      <v-row>
        <v-table>
          <thead>
            <tr>
              <th class="text-left">
                Name
              </th>
              <th class="text-left">
                Property
              </th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Camera URL</td>
              <td>{{imgSrc}}</td>
            </tr>
            <tr 
            v-for="item in metaData"
            :key="item.name"
            >
          <td>{{ item.name }}</td>
          <td>{{ item.value }}</td>
        </tr>
          </tbody>
        </v-table>
      </v-row>
      <v-row> 
        <alert 
          :params="alertParams"
          :alert="visible">
        </alert>
      
      </v-row>
    </v-container>

  </div>
</template>
  
<script>

import getEnv from '@/utils/env'
import ImagePlaceholder from './ImagePlaceholder.vue'
import Alert from './Alert.vue'

export default {
  data() {
    return {
      imgSrc: null,
      metaData: [],
      alertParams:{
        title: null,
        text: "alert text",
        color: "warning",
        visible: false
      },
      visible: false
    }
  },
  components: {
    ImagePlaceholder,
    Alert
  },
  methods: {
    updateMetaData(mName, mValue){
      // TODO: Fix icons
      let mindex = null
      let data = {name: mName, value: mValue}
      mindex = this.metaData.findIndex((obj => obj.name ==data.name))
      if (mindex === -1){
        this.metaData.push(data)
      } else {
        this.metaData[mindex].value = data.value
      }
    },

  updateAlert(text, color = 'warning',title = null, visible='true') {
    this.alertParams.title = title
    this.alertParams.text = text
    this.alertParams.color = color
    this.alertParams.visible = visible
    if (color == "info" || color == "success"){
      console.log(text)
    } else if(color == "warning"){
      console.warn(text)
    } else {
      console.error(text)
    }
  },

    async discoverAasServer() {

      let url = getEnv('VUE_APP_AAS_REGISTRY') + '/api/v1/registry/' + getEnv('VUE_APP_AAS_ID')
      this.updateMetaData('AAS Registry and ID', url)
      let res = await fetch(url).then(
        (response) => {
          return response.json()
        }).catch(exception => {
          console.error(`AAS fetch for ID '${getEnv('VUE_APP_AAS_ID')}' from registry '${getEnv('VUE_APP_AAS_REGISTRY')}' failed: \n` + exception)
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
        let operationSubmodel = registryResponse.submodels.filter((sm) => {
          try {
            return sm.semanticId.keys[0].value === "fabos_camera"
          } catch (error) {
            console.error("error while filtering submodels: ", error);
            return false
          }
          
        })
        console.log("found submodel at registry:", operationSubmodel)

        if (typeof operationSubmodel !== "undefined") {

          let aasUrl = operationSubmodel[0].endpoints[0].address
          this.updateMetaData("aas URL", aasUrl)
          if (typeof aasUrl !== "undefined" && aasUrl.length > 0) {
            let submodel = await this.fetchStreamURL(aasUrl)

            if (Object.prototype.hasOwnProperty.call(submodel, 'Endpoint')) {

              console.log("found matching submodel:", submodel)
              this.updateMetaData("submodel", submodel)
              this.imgSrc = submodel.Endpoint
              // console.log(`loaded stream URL: '${this.imgSrc}'`)
              this.updateAlert(`loaded stream URL: '${this.imgSrc}'`, 'success')
            } else {
              this.updateAlert("fetched submodel has no property 'Endpoint': " + submodel)
            }
          } else {
            this.updateAlert("fetched submodel has no endpoint to access")
          }
        } else {
          this.updateAlert("did not find submodel 'OperationalData' in AAS from registry")
        }
      } else {
       this.updateAlert("did not receive any submodels from AAS registry for AAS with id: " + getEnv('VUE_APP_AAS_ID') + " at: " + getEnv('VUE_APP_AAS_REGISTRY'));
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
