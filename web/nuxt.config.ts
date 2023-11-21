import pkg from "./package.json";

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  app: {
    baseURL: "/MISS-ELS/",
    head: {
      title: "MISS-ELS",
      htmlAttrs: {
        lang: "en",
      },
    },
  },
  css: ["~/assets/css/main.scss"],
  ssr: false,
  devtools: { enabled: true },
  plugins: ["plugins/luxon"],
  modules: ["@nuxtjs/tailwindcss", "@nuxt/devtools", "nuxt-icon"],
  runtimeConfig: {
    public: {
      version: pkg.version,
    },
  },
});
