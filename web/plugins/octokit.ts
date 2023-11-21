import { Octokit } from "octokit";

export default defineNuxtPlugin((nuxtApp) => {
  const octokit = new Octokit();

  return {
    provide: {
      octokit,
    },
  };
});
