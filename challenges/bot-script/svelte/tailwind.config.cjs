 module.exports = {
   content: ["./src/**/*.{svelte,html}"],
   mode: "jit",
   darkMode: true, // or 'media' or 'class'
   theme: {
     extend: {
       fontFamily: {
         mono: ["VT323", "mono"],
       },
     },
   },
   variants: {
     extend: {
       dropShadow: ["hover", "focus"],
     },
   },
   plugins: [require("daisyui")],
   daisyui: {
     themes: ["forest", "dark"],
   },
 };
