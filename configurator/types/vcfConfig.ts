import {Lightable, lightableType} from "~/types/lights";
import {staticType} from "~/types/static";
import {soundType} from "~/types/sounds";
import {patternType} from "~/types/patterns";
import {flashType} from "~/types/flash";

export type vcfConfig = {
  flashID: number
  configuration: {
    author: string|null
    description: string|null
    lightables: Lightable[]
    statics: staticType[]
    useServerSirens: boolean
    sounds: soundType[]
    patterns: patternType[]
    flashes: flashType[]
  }
}