<template>
  <header class="absolute left-0 top-0 w-full z-20">
    <div
      class="flex justify-end items-center text-white font-semibold gap-4 p-4"
    >
      <NuxtLink
        class="flex items-center gap-2 px-5 py-2 rounded-lg text-white bg-neutral-800 border border-gray-400 hover:bg-transparent"
        to="/configurator"
      >
        VCF Configurator
        <Icon name="mdi:file-code-outline" size="" />
      </NuxtLink>

      <NuxtLink
        to="https://github.com/matsn0w/MISS-ELS"
        target="_blank"
        class="hover:opacity-70"
      >
        <Icon name="mdi:github" size="36" />
      </NuxtLink>

      <NuxtLink
        to="https://matsn0w.dev/discord"
        target="_blank"
        class="hover:opacity-70"
      >
        <Icon name="ic:baseline-discord" size="36" />
      </NuxtLink>
    </div>
  </header>

  <main class="h-screen overflow-hidden flex justify-center items-center z-10">
    <slot />
  </main>
</template>
