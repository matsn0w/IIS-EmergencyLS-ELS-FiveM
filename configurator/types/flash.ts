import {patternType} from "~/types/patterns";
import {letterLightableId, numericalLightableId} from "~/types/lights";

export type flashType = {
  id: number
  pattern: patternType["name"]
  duration: number
  extras: numericalLightableId[]
  miscs: letterLightableId[]
}