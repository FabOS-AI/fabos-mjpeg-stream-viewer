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

    async getAasDescriptor() {
      let shellRegistryBaseUrl = getEnv('VUE_APP_AAS_REGISTRY');
      let aasId = getEnv('VUE_APP_AAS_ID');
      let aasIdEncoded = btoa(aasId);

      let url = `${shellRegistryBaseUrl}/shell-descriptors/${aasIdEncoded}`
      this.updateMetaData('Shell Descriptor Endpoint', url)
      let shellRegistryResponse = await fetch(url).then(
        (response) => {
          return response.json()
        }).catch(exception => {
          console.error(`Failed to fetch AAS descriptor from registry '${url}' failed: \n` + exception)
          return null
        });
      return shellRegistryResponse
    },

    async getShell(shellEndpoint) {
      let shellResponse = await fetch(shellEndpoint).then(
          (response) => {
            return response.json()
          }).catch(exception => {
        console.error(`Failed to fetch AAS from '${shellEndpoint}' failed: \n` + exception)
        return null
      });
      return shellResponse
    },

    async getSubmodelDescriptor(submodelId) {
      let submodelRegistryBaseUrl = getEnv('VUE_APP_SUBMODEL_REGISTRY');
      let submodelIdEncoded = btoa(submodelId);

      let url = `${submodelRegistryBaseUrl}/submodel-descriptors/${submodelIdEncoded}`
      let submodelRegistryResponse = await fetch(url).then(
          (response) => {
            return response.json()
          }).catch(exception => {
        console.error(`Failed to fetch Submodel descriptor from registry '${url}': \n` + exception)
        return null
      });
      return submodelRegistryResponse
    },

    async getSubmodelValues(submodelEndpoint) {
      let url = `${submodelEndpoint}/$value`
      let submodelValuesResponse = await fetch(url).then(
          (response) => {
            return response.json()
          }).catch(exception => {
        console.error(`Failed to fetch Submodel value representation from '${submodelEndpoint}': \n` + exception)
        return null
      });
      return submodelValuesResponse
    },

    doRefresh(){
      this.getStreamUrl()
    },

    async getStreamUrl() {

      this.imgSrc = null

      let shellDescriptor = await this.getAasDescriptor();
      let aasEndpoint = null
      if (shellDescriptor !== null) {
        console.log("Shell descriptor:", shellDescriptor)
        aasEndpoint = shellDescriptor.endpoints[0].protocolInformation.href;
        this.updateMetaData("AAS Endpoint", aasEndpoint)
      } else {
        this.updateAlert(`Unable to fetch AAS descriptor from registry: ${getEnv('VUE_APP_AAS_REGISTRY')} for AAS with id: ${getEnv('VUE_APP_AAS_ID')}`)
        return;
      }

      let shell = await this.getShell(aasEndpoint);
      let submodelIds = [];
      if (shell !== null) {
        shell.submodels.forEach((submodelRef) => {
          submodelIds.push(submodelRef.keys[0].value)
        })
      } else {
        this.updateAlert(`Unable to fetch submodel refs of AAS '${aasEndpoint}`)
        return;
      }

      let cameraSubmodelId = null;
      let cameraSubmodelDescriptor = null;
      for await (const submodelId of submodelIds) {
        let submodelDescriptor = await this.getSubmodelDescriptor(submodelId)
        if (submodelDescriptor.semanticId !== null) {
          let semanticId = submodelDescriptor.semanticId.keys[0].value
          if (semanticId === "slm-camera") {
            cameraSubmodelId = submodelId;
            cameraSubmodelDescriptor = submodelDescriptor
          }
        }
      }

      let submodelValues = null;
      let submodelEndpoint = null;
      if (cameraSubmodelId !== null) {
        console.log("Found submodel with semanticId 'slm-camera':", cameraSubmodelDescriptor)
        this.updateMetaData("Camera Submodel ID", cameraSubmodelId)

        submodelEndpoint = cameraSubmodelDescriptor.endpoints[0].protocolInformation.href
        submodelValues = await this.getSubmodelValues(submodelEndpoint)
      } else {
        return;
      }

      if (submodelValues !== null) {
        if (Object.prototype.hasOwnProperty.call(submodelValues, 'Endpoint')) {
          this.updateMetaData("Submodel Values", submodelValues)
          this.imgSrc = submodelValues.Endpoint
          this.updateAlert(`Successfully loaded stream URL: '${this.imgSrc}'`, "success")
        } else {
          this.updateAlert("Failed to find property 'Endpoint' in submodel values submodel" + submodelValues)
        }
      }
      else {
        this.updateAlert(`Failed to fetch submodel values from '${submodelEndpoint}'`)
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
