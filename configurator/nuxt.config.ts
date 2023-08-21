// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  app: {
    baseURL: "/MISS-ELS/",
    head: {
      title: "MISS ELS VCF Configurator",
      htmlAttrs: {
        lang: "en",
      },
    },
  },
  css: ["~/assets/css/main.scss"],
  ssr: false,
  devtools: { enabled: true },
  modules: ["@nuxtjs/tailwindcss"],
});
