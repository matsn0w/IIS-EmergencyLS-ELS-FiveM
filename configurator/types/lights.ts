export type lightableType = "extra"|"misc"
export type Color = "blue"|"amber"|"red"|"green"|"white"
export type numericalLightableId = 1|2|3|4|5|6|7|8|9|10|11|12
export type letterLightableId = "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j" | "k" | "l" | "m" | "n" | "o" | "p" | "q" | "r" | "s" | "t" | "u" | "v" | "w" | "x" | "y" | "z";
export type Lightable = {
  type: lightableType
  id: numericalLightableId|letterLightableId
  enabled: boolean
  allowEnv: boolean
  color: Color|null
}