const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
  ],
  theme: {
    extend: {
      colors: {
        marmorean: {
          50: "#FFF8E1", // crema chiaro
          100: "#FFECB3", // crema
          200: "#FFE082", // oro pallido
          300: "#FFD54F", // oro chiaro
          400: "#FFCA28", // oro medio
          500: "#FFC107", // oro standard
          600: "#FFB300", // oro intenso
          700: "#FFA000", // oro ambrato
          800: "#FF8F00", // oro scuro
          900: "#FF6F00", // oro brunito
        },
      },
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
      animation: {
        "appear-then-fade": "appear-then-fade 5s 300ms both",
      },
      keyframes: {
        "appear-then-fade": {
          "0%, 100%": { opacity: 0, transform: "translateY(100%)" },
          "1%, 80%": { opacity: 1, transform: "translateY(0)" },
        },
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
  ],
};
