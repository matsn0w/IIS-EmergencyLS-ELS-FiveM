import {letterLightableId, lightableType, numericalLightableId} from "~/types/lights";

export type staticType = {
  id: numericalLightableId|letterLightableId|null,
  type: lightableType|null
  name: string|null
}