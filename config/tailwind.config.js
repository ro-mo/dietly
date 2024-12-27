const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
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
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
