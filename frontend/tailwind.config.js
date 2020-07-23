const { colors } = require('tailwindcss/defaultTheme');

module.exports = {
  important: true,
  theme: {
    extend: {
      colors: {
        "trivial": colors.blue,
        "easy": colors.green,
        "normal": colors.yellow,
        "hard": colors.red,
        "extreme": colors.purple,
        "lunatic": colors.gray,
      },
      transitionProperty: {
        width: "width",
        visibility: "visibility, opacity",
      },
      spacing: {
        full: "100%",
      },
    },
  },
  variants: {
    margin: ['responsive', 'first'],
    borderWidth: ['responsive', 'first'],
  },
  plugins: [],
}
