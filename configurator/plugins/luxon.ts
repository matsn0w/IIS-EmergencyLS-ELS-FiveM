import {DateTime} from "luxon";

export default defineNuxtPlugin(() => {
    return {
        provide: {
            luxon: () => DateTime
        }
    }
})