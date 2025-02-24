/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {

    extend: {
      colors: {
        white: "#F6F4F3",
        black: "#242728",
        green: {
          500: "#4E7B51"
        }
      },
      fontFamily: {
        sans: ['"Roboto Condensed"', 'sans-serif'],
        display: ['Roboto Condensed', 'sans-serif'],
      },
      fontWeight: {
        bold: '700',
        regular: '400',
      },
      fontStyle: {
        italic: 'italic',
      },
    },
  },
  plugins: [
    function ({ addUtilities }) {
      addUtilities({
        '.text-stroke-4-black': {
          '-webkit-text-stroke-width': '4px',
          '-webkit-text-stroke-color': 'var(--black, #242728)',
        }
      })
    }
  ],
}

