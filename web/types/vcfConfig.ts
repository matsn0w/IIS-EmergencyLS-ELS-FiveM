import type {Lightable, lightableType} from "~/types/lights";
import type {staticType} from "~/types/static";
import type {soundType} from "~/types/sounds";
import type {patternType} from "~/types/patterns";
import type {flashType} from "~/types/flash";

export type vcfConfig = {
  flashID: number
  configuration: {
    author: string|null
    description: string|null
    version: string|null
    lightables: Lightable[]
    statics: staticType[]
    useServerSirens: boolean
    sounds: soundType[]
    patterns: patternType[]
    flashes: flashType[]
  }
}