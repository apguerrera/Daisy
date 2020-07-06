<template>
  <div class="content">
    <base-header class="pb-6">
      <div class="row align-items-center py-4">
        <div class="col-lg-6 col-7">
          <h6 class="h2 text-dark d-inline-block mb-0">Daisy</h6>
          <nav aria-label="breadcrumb" class="d-none d-md-inline-block ml-md-4">
            <route-bread-crumb></route-bread-crumb>
          </nav>
        </div>
      </div>
    </base-header>

    <div class="container-fluid mt--6 row justify-content-center">
      <div class="col-lg-6 card-wrapper ct-example">
        <div class="card-wrapper">
          <card>
            <el-tabs class="flex-sm-row flex-nowrap" v-model="activeTab">
              <el-tab-pane class="nav-item nav-link active" label="Generate Keypair" name="first">
                <validation-observer v-slot="{ handleSubmit }" @submit.prevent="checkEthConnection">
                  <form class="needs-validation" @submit.prevent="handleSubmit(generateKeypair)">
                    <div class="form-row justify-content-center">
                      <div class="col-md-5">
                        <base-input
                          inputClasses="text-center"
                          label="PIN"
                          name="pin"
                          v-model="pin"
                          placeholder="0000"
                          rules="required|digits:4"
                        />
                      </div>
                      <div class="col-md-12 text-center">
                        <base-button type="primary" native-type="submit">Generate Keypair</base-button>
                      </div>
                      <div class="col-md-12">
                        <h3>
                          Keypairs
                          <p class="text-muted">Private key: {{keypair.serializedPrivKey}}</p>
                          <p class="text-muted">Public key: {{keypair.serializedPubKey}}</p>
                        </h3>
                      </div>
                    </div>
                  </form>
                </validation-observer>
              </el-tab-pane>
              <el-tab-pane class="nav-item nav-link" label="Lock MKR" name="second">Lock MKR</el-tab-pane>
              <el-tab-pane class="nav-item nav-link" label="Change Pin" name="second">Change Pin</el-tab-pane>
              <el-tab-pane class="nav-item nav-link" label="Start Voting" name="second">Start Voting</el-tab-pane>
            </el-tabs>
          </card>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import { mapGetters } from "vuex";
import RouteBreadCrumb from "@/components/argon-core/Breadcrumb/RouteBreadcrumb";
import Tabs from "@/components/argon-core/Tabs/Tabs";
import Tab from "@/components/argon-core/Tabs/Tab";
import ethereumConnectionModalMixin from "@/components/petyl-core/modal/ethereumConnectionModalMixin";
import { genMaciKeypair } from "./maciKeygen";

export default {
  mixins: [ethereumConnectionModalMixin],
  layout: "DashboardLayout",
  components: {
    RouteBreadCrumb,
    Tabs,
    Tab
  },
  data() {
    return {
      activeTab: "first",
      pin: "",
      keypair: ""
    };
  },
  computed: {
    ...mapGetters({
      coinbase: "ethereum/coinbase"
    })
  },
  methods: {
    async generateKeypair() {
      if (this.isOk) {
        try {
          const signature = await web3.eth.personal.sign(
            web3.utils.sha3(this.pin),
            this.coinbase
          );
          const keypair = await genMaciKeypair(signature);
          this.keypair = keypair;
        } catch (err) {
          console.log(err);
        }
      }
    }
  }
};
</script>
<style>
</style>
