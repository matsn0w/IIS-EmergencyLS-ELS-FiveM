import c from"./Icon.f673f3ee.js";import{i,o as d,c as u,a as e,d as o,t as _,u as p,b as a,J as n}from"./entry.b4d8413c.js";import"./state.fffa2af1.js";import"./index.df58e121.js";const s="2.2.0",m={class:"background h-full w-full"},g={class:"buttons h-full flex flex-col lg:flex-row justify-center items-center gap-4 font-semibold text-white"},v=i({__name:"index",setup(x){const l=async()=>{await n(`https://github.com/matsn0w/MISS-ELS/releases/latest/download/MISS-ELS_v${s}.zip`,{external:!0})},r=async()=>{await n("https://github.com/matsn0w/MISS-ELS/releases/latest",{external:!0,open:{target:"_blank"}})};return(b,f)=>{const t=c;return d(),u("div",m,[e("div",g,[e("button",{class:"bg-blue-900 border border-gray-100 text-3xl rounded-lg shadow-lg flex items-center gap-3 p-4",type:"button",onClick:l},[o(" Download v"+_(p(s))+" ",1),a(t,{name:"uil:download-alt"})]),e("button",{class:"bg-gray-800 border border-gray-100 text-3xl rounded-lg shadow-lg flex items-center gap-3 p-4",type:"button",onClick:r},[o(" View latest release "),a(t,{name:"uil:external-link-alt"})])])])}}});export{v as default};
